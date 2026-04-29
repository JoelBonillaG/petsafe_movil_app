import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_models.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_repository.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_repository_factory.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_models.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_repository_factory.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late final AppointmentRepository _repo;

  List<PetProfile> _pets = [];
  List<AppointmentRequest> _requests = [];

  bool _isLoadingPets = false;
  bool _isLoadingRequests = true;
  bool _isSending = false;
  String? _requestsError;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  int _selectedPetIndex = 0;
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;

  DateTime? _lastLoaded;
  bool _wasTickerActive = false;
  static const _staleDuration = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    _repo = AppointmentRepositoryFactory.create();
    _preferredDate = DateTime.now().add(const Duration(days: 7));
    _preferredTime = const TimeOfDay(hour: 9, minute: 30);
    _loadPets();
    _loadRequests();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isNowActive = TickerMode.of(context);
    if (isNowActive && !_wasTickerActive) {
      final stale = _lastLoaded == null ||
          DateTime.now().difference(_lastLoaded!) > _staleDuration;
      if (stale) _loadRequests();
    }
    _wasTickerActive = isNowActive;
  }

  Future<void> _loadPets() async {
    setState(() => _isLoadingPets = true);
    try {
      final repo = await PetsRepositoryFactory.create();
      final result = await repo.loadPets(limit: 100);
      if (mounted) {
        setState(() {
          _pets = result.pets;
          _selectedPetIndex = 0;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingPets = false);
    }
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoadingRequests = true;
      _requestsError = null;
    });
    try {
      final items = await _repo.loadMine();
      if (mounted) setState(() {
        _requests = items;
        _lastLoaded = DateTime.now();
      });
    } catch (_) {
      if (mounted) setState(() => _requestsError = 'No se pudieron cargar las solicitudes.');
    } finally {
      if (mounted) setState(() => _isLoadingRequests = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  PetProfile? get _selectedPet =>
      _pets.isNotEmpty ? _pets[_selectedPetIndex] : null;

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: 'Citas medicas',
      appBarActions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _showAppointmentsFlowInfo,
              tooltip: 'Ver flujo de citas',
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: AppColors.warning,
              ),
            ),
          ),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            _heroCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showRequestModal,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Solicitar cita'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Solicitudes recientes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _buildRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_isLoadingRequests) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.brand),
        ),
      );
    }

    if (_requestsError != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(_requestsError!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'No tienes solicitudes aun',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _requests
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _showRequestDetail(r),
                  child: _requestCard(r),
                ),
              ))
          .toList(growable: false),
    );
  }

  Future<void> _showRequestModal() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return FractionallySizedBox(
              heightFactor: 0.92,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(sheetContext).padding.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solicitar cita medica',
                        style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionar mascota',
                              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_isLoadingPets)
                              const CircularProgressIndicator(color: AppColors.brand)
                            else if (_pets.isEmpty)
                              Text(
                                'No tienes mascotas registradas.',
                                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List<Widget>.generate(_pets.length, (index) {
                                  final item = _pets[index];
                                  final selected = index == _selectedPetIndex;
                                  return ChoiceChip(
                                    label: Text(item.name),
                                    selected: selected,
                                    onSelected: (_) {
                                      setState(() => _selectedPetIndex = index);
                                      setSheetState(() {});
                                    },
                                  );
                                }),
                              ),
                            const SizedBox(height: 18),
                            Text(
                              'Motivo de la cita',
                              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _reasonController,
                              minLines: 5,
                              maxLines: 8,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                hintText: 'Describe por que necesitas la cita medica para tu mascota',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.edit_note_rounded),
                              ),
                              validator: (value) {
                                final reason = value?.trim() ?? '';
                                if (reason.isEmpty) return 'Ingresa el motivo de la cita';
                                if (reason.length < 10) return 'Escribe un poco mas de detalle (minimo 10 caracteres)';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Fecha preferida',
                              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                await _pickDate();
                                setSheetState(() {});
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Seleccionar fecha',
                                  prefixIcon: Icon(Icons.event_rounded),
                                ),
                                child: Text(_formatDate(_preferredDate)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Hora preferida',
                              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                await _pickTime();
                                setSheetState(() {});
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Seleccionar hora',
                                  prefixIcon: Icon(Icons.schedule_rounded),
                                ),
                                child: Text(_formatTime(_preferredTime)),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isSending ? null : () => Navigator.pop(sheetContext),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isSending
                                        ? null
                                        : () {
                                            if (!_formKey.currentState!.validate()) return;
                                            // Cierra modal inmediatamente — previene doble tap
                                            Navigator.pop(sheetContext);
                                            _submitRequest(sheetContext);
                                          },
                                    icon: const Icon(Icons.send_rounded),
                                    label: const Text('Enviar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
        imageUrl: AppMedia.clinicHero,
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
                  'Citas médicas',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El cuidado empieza solicitando su próxima cita.',
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

  Widget _requestCard(AppointmentRequest request) {
    final petName = request.patientName ?? 'Sin mascota';
    final dateStr = _formatPreferredDate(request.preferredDate);
    final timeStr = request.preferredTime != null
        ? '${request.preferredTime!.substring(0, 5)}'
        : null;
    final metaStr = [dateStr, if (timeStr != null) timeStr].join(' | ');
    final note = request.staffNotes?.isNotEmpty == true
        ? request.staffNotes!
        : request.reason;

    return Container(
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
              NetworkAvatar(
                imageUrl: AppMedia.petImageFor(name: petName),
                size: 54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metaStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _statusPill(request.status.label, request.status.color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showRequestDetail(AppointmentRequest r) {
    final petName = r.patientName ?? 'Sin mascota';
    final dateStr = _formatPreferredDate(r.preferredDate);
    final timeStr = r.preferredTime != null ? r.preferredTime!.substring(0, 5) : null;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalle de solicitud',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  _statusPill(r.status.label, r.status.color),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow(ctx, 'Mascota', petName),
              if (r.preferredDate != null) ...[
                const SizedBox(height: 8),
                _detailRow(ctx, 'Fecha preferida', '$dateStr${timeStr != null ? '  ·  $timeStr' : ''}'),
              ],
              const SizedBox(height: 12),
              Text('Motivo', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(r.reason, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45)),
              if (r.staffNotes != null && r.staffNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Nota del veterinario', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.activeSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brand.withOpacity(0.2)),
                  ),
                  child: Text(r.staffNotes!, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45)),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(BuildContext ctx, String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(label, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          flex: 6,
          child: Text(value, textAlign: TextAlign.right, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _flowStepCard(_FlowStep step) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: step.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(step.icon, color: step.color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                step.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAppointmentsFlowInfo() {
    final steps = <_FlowStep>[
      const _FlowStep(
        title: 'Completa la solicitud',
        subtitle: 'Ingresa motivo, fecha y hora desde el formulario.',
        icon: Icons.send_rounded,
        color: AppColors.brand,
      ),
      const _FlowStep(
        title: 'Revision veterinaria',
        subtitle: 'El veterinario valida agenda y prioridad del caso.',
        icon: Icons.rate_review_rounded,
        color: AppColors.warning,
      ),
      const _FlowStep(
        title: 'Confirmacion de cita',
        subtitle: 'Recibes la fecha y hora final segun disponibilidad del veterinario.',
        icon: Icons.verified_rounded,
        color: AppColors.success,
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 + MediaQuery.of(sheetContext).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Flujo de citas medicas',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Sigue este flujo para solicitar y confirmar una cita.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceStrong,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: steps
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _flowStepCard(step),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (!mounted || selected == null) return;
    setState(() => _preferredDate = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? TimeOfDay.now(),
    );
    if (!mounted || selected == null) return;
    setState(() => _preferredTime = selected);
  }

  Future<void> _submitRequest(BuildContext sheetContext) async {
    if (_isSending) return;
    setState(() => _isSending = true);
    try {
      final payload = CreateAppointmentRequestPayload(
        reason: _reasonController.text.trim(),
        patientId: _selectedPet?.id,
        preferredDate: _preferredDate != null ? _toIsoDate(_preferredDate!) : null,
        preferredTime: _preferredTime != null ? _toIsoTime(_preferredTime!) : null,
      );

      final created = await _repo.create(payload);
      if (!mounted) return;

      setState(() {
        _requests.insert(0, created);
        _reasonController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;
      String msg = 'No se pudo enviar la solicitud. Intenta de nuevo.';
      try {
        final dynamic err = (e as dynamic).response?.data;
        if (err is Map && err['message'] != null) {
          msg = err['message'].toString();
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatPreferredDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Sin fecha preferida';
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Sin hora';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _toIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _toIsoTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _FlowStep {
  const _FlowStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
