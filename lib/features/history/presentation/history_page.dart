import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_models.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_repository_factory.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_models.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_repository.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_repository_factory.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  VaccinationRepository? _vaccinationRepository;
  List<PetProfile> _pets = <PetProfile>[];
  bool _isLoading = false;
  String? _errorMessage;

  int _selectedIndex = 0;

  VaccinationPlan? _plan;
  VaccinationApplicationsResult? _applications;
  bool _isLoadingVaccinations = false;
  String? _vaccinationError;

  PetProfile? get _selectedPet =>
      _pets.isNotEmpty ? _pets[_selectedIndex] : null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
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
        await _loadVaccinations(_pets[0].id);
      }
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('ApiFailure: ', '');
        _isLoading = false;
      });
    }
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

    try {
      final results = await Future.wait([
        repo.loadPatientPlan(patientId),
        repo.loadPatientApplications(patientId),
      ]);
      if (!mounted) return;
      setState(() {
        _plan = results[0] as VaccinationPlan;
        _applications = results[1] as VaccinationApplicationsResult;
        _isLoadingVaccinations = false;
      });
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _vaccinationError = e.message;
        _isLoadingVaccinations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _vaccinationError = 'No se pudo cargar el historial de vacunacion.';
        _isLoadingVaccinations = false;
      });
    }
  }

  void _onPetSelected(int index) {
    setState(() => _selectedIndex = index);
    final pet = _pets[index];
    _loadVaccinations(pet.id);
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
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _bootstrap,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pet = _selectedPet;

    return FeaturePageScaffold(
      title: 'Historial clinico',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          Text(
            'Selecciona una mascota',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          if (_pets.isEmpty)
            Text(
              'No tienes mascotas registradas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.generate(_pets.length, (index) {
                final item = _pets[index];
                final selected = index == _selectedIndex;
                return ChoiceChip(
                  label: Text(item.name),
                  selected: selected,
                  onSelected: (_) => _onPetSelected(index),
                );
              }),
            ),
          if (pet != null) ...[
            const SizedBox(height: 16),
            _pdfPreviewCard(pet),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    'Condiciones',
                    pet.conditions.length.toString(),
                    Icons.monitor_heart_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard(
                    'Peso actual',
                    pet.weightLabel,
                    Icons.scale_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Vacunacion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _vaccinationSection(),
          ],
        ],
      ),
    );
  }

  Widget _vaccinationSection() {
    if (_isLoadingVaccinations) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(color: AppColors.brand),
            SizedBox(height: 12),
            Text('Cargando historial de vacunacion...'),
          ],
        ),
      );
    }

    if (_vaccinationError != null && _plan == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.warning.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _vaccinationError!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final plan = _plan;
    final applications = _applications;

    if (plan == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No hay plan de vacunacion registrado.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'Aplicadas',
                plan.appliedCount.toString(),
                Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                'Pendientes',
                plan.pendingCount.toString(),
                Icons.schedule_rounded,
              ),
            ),
          ],
        ),
        if (plan.schemeName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.activeSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.vaccines_rounded, size: 16, color: AppColors.brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esquema: ${plan.schemeName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (plan.doses.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Plan de dosis',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          ...plan.doses.map((dose) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _doseCard(dose),
          )),
        ],
        if (applications != null && applications.applications.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Aplicaciones registradas',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          ...applications.applications.map((app) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _applicationCard(app),
          )),
        ],
      ],
    );
  }

  Widget _doseCard(VaccinationPlanDose dose) {
    Color statusColor;
    IconData statusIcon;
    if (dose.isApplied) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
    } else if (dose.isOverdue) {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_rounded;
    } else if (dose.isSkipped) {
      statusColor = AppColors.textSecondary;
      statusIcon = Icons.remove_circle_rounded;
    } else {
      statusColor = AppColors.warning;
      statusIcon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dose.vaccineName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  dose.doseLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (dose.scheduledDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Programada: ${_formatDate(dose.scheduledDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (dose.appliedDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Aplicada: ${_formatDate(dose.appliedDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              dose.statusLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _applicationCard(VaccinationApplication app) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.activeSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.vaccines_rounded, color: AppColors.brand, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.vaccineName, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  _formatDate(app.applicationDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (app.batchNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Lote: ${app.batchNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (app.nextDoseDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Proxima: ${_formatDate(app.nextDoseDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: NetworkImageCard(
        imageUrl: AppMedia.historyHero,
        height: 250,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial clínico',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Revisa el historial de vacunacion y condiciones de tu mascota.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.93),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pdfPreviewCard(PetProfile pet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.activeSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.pets_rounded, color: AppColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expediente de ${pet.name}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${pet.speciesLabel} | ${pet.breedLabel} | ${pet.ageLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.brand),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
