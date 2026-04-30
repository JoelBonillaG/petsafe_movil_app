import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';
import 'package:petsafe_movil_app/features/history/data/encounter_models.dart';
import 'package:petsafe_movil_app/features/history/data/encounter_repository_factory.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_models.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_repository_factory.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_models.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_repository.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_repository_factory.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  VaccinationRepository? _vaccinationRepository;

  List<PetProfile> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 0;

  VaccinationPlan? _plan;
  VaccinationApplicationsResult? _applications;
  bool _isLoadingVaccinations = false;
  String? _vaccinationError;

  List<ClientEncounter> _encounters = [];
  bool _isLoadingEncounters = false;
  String? _encounterError;

  bool _isDownloadingPdf = false;
  bool _wasTickerActive = false;

  PetProfile? get _selectedPet =>
      _pets.isNotEmpty ? _pets[_selectedIndex] : null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isNowActive = TickerMode.of(context);
    if (isNowActive && !_wasTickerActive) {
      _refresh();
    }
    _wasTickerActive = isNowActive;
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final petsRepo = await PetsRepositoryFactory.create();
      final vaccinationRepo = VaccinationRepositoryFactory.create();
      final result = await petsRepo.loadPets(limit: 100);
      if (!mounted) return;
      setState(() {
        _vaccinationRepository = vaccinationRepo;
        _pets = result.pets;
        _selectedIndex = 0;
        _isLoading = false;
      });
      if (_pets.isNotEmpty) {
        await Future.wait([
          _loadVaccinations(_pets[0].id),
          _loadEncounters(_pets[0].id),
        ]);
      }
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = e.message; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('ApiFailure: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    final pet = _selectedPet;
    if (pet == null) return;
    await Future.wait([
      _loadVaccinations(pet.id),
      _loadEncounters(pet.id),
    ]);
  }

  Future<void> _loadVaccinations(int patientId) async {
    final repo = _vaccinationRepository;
    if (repo == null) return;
    setState(() {
      _isLoadingVaccinations = true;
      _vaccinationError = null;
      _plan = null;
      _applications = null;
    });
    var planLoaded = false;
    var applicationsLoaded = false;
    String? loadError;

    try {
      final plan = await repo.loadPatientPlan(patientId);
      if (!mounted) return;
      setState(() {
        _plan = plan;
      });
      planLoaded = true;
    } catch (_) {
      loadError = 'No se pudo cargar el historial de vacunacion.';
    }

    try {
      final applications = await repo.loadPatientApplications(patientId);
      if (!mounted) return;
      setState(() {
        _applications = applications;
      });
      applicationsLoaded = true;
    } catch (_) {
      loadError = 'No se pudo cargar el historial de vacunacion.';
    }

    if (!mounted) return;
    setState(() {
      _vaccinationError = (planLoaded || applicationsLoaded) ? null : loadError;
      _isLoadingVaccinations = false;
    });
  }

  Future<void> _loadEncounters(int patientId) async {
    final service = EncounterRepositoryFactory.create();
    setState(() {
      _isLoadingEncounters = true;
      _encounterError = null;
      _encounters = [];
    });
    try {
      final result = await service.getClientHistory(patientId);
      if (!mounted) return;
      setState(() {
        _encounters = result.encounters;
        _isLoadingEncounters = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _encounterError = 'No se pudo cargar las consultas.';
        _isLoadingEncounters = false;
      });
    }
  }

  void _onPetSelected(int index) {
    setState(() => _selectedIndex = index);
    final pet = _pets[index];
    Future.wait([_loadVaccinations(pet.id), _loadEncounters(pet.id)]);
  }

  Future<void> _downloadPdf(int patientId) async {
    if (_isDownloadingPdf) return;
    setState(() => _isDownloadingPdf = true);
    try {
      final sessionStorage = FlutterSecureSessionStorage(const FlutterSecureStorage());
      final token = await sessionStorage.readAccessToken();
      final apiClient = ApiClient();
      final response = await apiClient.dio.get<List<int>>(
        '/reports/patients/$patientId/clinical-history/pdf',
        options: Options(
          responseType: ResponseType.bytes,
          headers: token != null && token.isNotEmpty
              ? <String, dynamic>{'Authorization': 'Bearer $token'}
              : null,
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) throw Exception('PDF vacio');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/historial-clinico-$patientId.pdf');
      await file.writeAsBytes(bytes);
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el PDF: ${result.message}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo descargar el historial. Verifica tu conexion.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FeaturePageScaffold(
        title: 'Historial clinico',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _pets.isEmpty) {
      return FeaturePageScaffold(
        title: 'Historial clinico',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary, height: 1.45)),
                const SizedBox(height: 20),
                OutlinedButton.icon(onPressed: _bootstrap,
                    icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar')),
              ],
            ),
          ),
        ),
      );
    }

    final pet = _selectedPet;

    return FeaturePageScaffold(
      title: 'Historial clinico',
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            _heroCard(),
            const SizedBox(height: 16),
            Text('Selecciona una mascota', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (_pets.isEmpty)
              Text('No tienes mascotas registradas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.generate(_pets.length, (index) {
                  final item = _pets[index];
                  return ChoiceChip(
                    label: Text(item.name),
                    selected: index == _selectedIndex,
                    onSelected: (_) => _onPetSelected(index),
                  );
                }),
              ),
            if (pet != null) ...[
              const SizedBox(height: 16),
              _petCard(pet),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isDownloadingPdf ? null : () => _downloadPdf(pet.id),
                  icon: _isDownloadingPdf
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.picture_as_pdf_rounded),
                  label: Text(_isDownloadingPdf ? 'Descargando...' : 'Descargar historial PDF'),
                ),
              ),
              const SizedBox(height: 20),
              _sectionHeader('Consultas', Icons.medical_services_rounded, AppColors.brand),
              const SizedBox(height: 10),
              _encountersSection(),
              const SizedBox(height: 20),
              _sectionHeader('Vacunacion', Icons.vaccines_rounded, AppColors.success),
              const SizedBox(height: 10),
              _vaccinationSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  // ── Encounters ────────────────────────────────────────────────────────────

  Widget _encountersSection() {
    if (_isLoadingEncounters) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.brand)));
    }
    if (_encounterError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_encounterError!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      );
    }
    if (_encounters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medical_services_outlined, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text('Sin consultas registradas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return Column(
      children: _encounters
          .map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _encounterCard(e)))
          .toList(growable: false),
    );
  }

  Widget _encounterCard(ClientEncounter e) {
    return GestureDetector(
      onTap: () => _showEncounterDetail(e),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.activeSoft, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.medical_services_rounded, color: AppColors.brand, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_formatDate(e.startTime), style: Theme.of(context).textTheme.titleSmall),
                    if (e.vetName != null)
                      Text('Dr. ${e.vetName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.activeSoft, borderRadius: BorderRadius.circular(999)),
                  child: Text(e.statusLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.brand, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            if (e.consultationReason != null) ...[
              const SizedBox(height: 8),
              Text(e.consultationReason!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary, height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (e.treatmentsCount > 0) _tag('${e.treatmentsCount} trat.', Icons.medication_rounded),
                if (e.vaccinationsCount > 0) ...[
                  const SizedBox(width: 8),
                  _tag('${e.vaccinationsCount} vac.', Icons.vaccines_rounded),
                ],
                if (e.dewormingsCount > 0) ...[
                  const SizedBox(width: 8),
                  _tag('${e.dewormingsCount} despar.', Icons.bug_report_rounded),
                ],
                const Spacer(),
                Text('Ver detalle →',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.brand, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showEncounterDetail(ClientEncounter e) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).padding.bottom),
          children: [
            Center(child: Container(width: 44, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Text('Consulta del ${_formatDate(e.startTime)}',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            if (e.vetName != null) ...[
              const SizedBox(height: 4),
              Text('Dr. ${e.vetName}',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 16),
            if (e.consultationReason != null) ...[
              Text('Motivo', style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(e.consultationReason!, style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 12),
            ],
            if (e.generalNotes != null) ...[
              Text('Notas generales', style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(e.generalNotes!, style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 12),
            ],
            if (e.treatments.isNotEmpty) ...[
              Text('Tratamientos', style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...e.treatments.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.medication_rounded, size: 18, color: AppColors.brand),
                    const SizedBox(width: 10),
                    Expanded(child: Text(t.name, style: Theme.of(ctx).textTheme.bodyMedium)),
                    Text(t.status, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ]),
                ),
              )),
            ],
            if (e.vaccinations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Vacunas aplicadas', style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...e.vaccinations.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.vaccines_rounded, size: 18, color: AppColors.brand),
                    const SizedBox(width: 10),
                    Expanded(child: Text(v.vaccineName ?? 'Vacuna', style: Theme.of(ctx).textTheme.bodyMedium)),
                    if (v.batchNumber != null)
                      Text('Lote: ${v.batchNumber}',
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ]),
                ),
              )),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
            ),
          ],
        ),
      ),
    );
  }

  // ── Vaccinations ──────────────────────────────────────────────────────────

  Widget _vaccinationSection() {
    if (_isLoadingVaccinations) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.brand)));
    }
    if (_vaccinationError != null && _plan == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_vaccinationError!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      );
    }
    final plan = _plan;
    final applications = _applications;

    if (plan == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No hay plan de vacunacion registrado.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _metricCard('Aplicadas', plan.appliedCount.toString(), Icons.check_circle_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('Pendientes', plan.pendingCount.toString(), Icons.schedule_rounded)),
          ],
        ),
        if (plan.schemeName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.activeSoft, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.vaccines_rounded, size: 16, color: AppColors.brand),
              const SizedBox(width: 8),
              Expanded(child: Text('Esquema: ${plan.schemeName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.brand, fontWeight: FontWeight.w600))),
            ]),
          ),
        ],
        if (plan.doses.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Plan de dosis', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          ...plan.doses.map((dose) => Padding(
              padding: const EdgeInsets.only(bottom: 10), child: _doseCard(dose))),
        ],
        if (applications != null && applications.applications.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Aplicaciones registradas', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          ...applications.applications.map((app) => Padding(
              padding: const EdgeInsets.only(bottom: 10), child: _applicationCard(app))),
        ],
      ],
    );
  }

  Widget _doseCard(VaccinationPlanDose dose) {
    Color statusColor;
    IconData statusIcon;
    if (dose.isApplied) { statusColor = AppColors.success; statusIcon = Icons.check_circle_rounded; }
    else if (dose.isOverdue) { statusColor = AppColors.error; statusIcon = Icons.cancel_rounded; }
    else if (dose.isSkipped) { statusColor = AppColors.textSecondary; statusIcon = Icons.remove_circle_rounded; }
    else { statusColor = AppColors.warning; statusIcon = Icons.schedule_rounded; }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceStrong, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Icon(statusIcon, color: statusColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dose.vaccineName, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(dose.doseLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            if (dose.scheduledDate != null)
              Text('Programada: ${_formatDate(dose.scheduledDate!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            if (dose.appliedDate != null)
              Text('Aplicada: ${_formatDate(dose.appliedDate!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
          child: Text(dose.statusLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _applicationCard(VaccinationApplication app) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceStrong, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.activeSoft, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.vaccines_rounded, color: AppColors.brand, size: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.vaccineName, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(_formatDate(app.applicationDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            if (app.batchNumber != null)
              Text('Lote: ${app.batchNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            if (app.nextDoseDate != null)
              Text('Proxima: ${_formatDate(app.nextDoseDate!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.brand, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _heroCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.border)),
      child: NetworkImageCard(
        imageUrl: AppMedia.historyHero,
        height: 200,
        borderRadius: 28,
        showBorder: false,
        showShadow: true,
        overlayGradient: const LinearGradient(
          colors: [Color(0xCC2F605E), Color(0x991E3A8A), Color(0x331F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foreground: Padding(
          padding: const EdgeInsets.all(18),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Historial clínico',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Consultas, vacunaciones y tratamientos.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _petCard(PetProfile pet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceStrong, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.activeSoft, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.pets_rounded, color: AppColors.brand)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${pet.speciesLabel} | ${pet.breedLabel} | ${pet.ageLabel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ]),
        ),
        Column(children: [
          Text(pet.conditions.length.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.brand)),
          Text('cond.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceStrong, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppColors.brand),
        const SizedBox(height: 10),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
