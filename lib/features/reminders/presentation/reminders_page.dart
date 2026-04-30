import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_models.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_repository_factory.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_models.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_repository_factory.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_models.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_repository_factory.dart';

// ── Reminder model ────────────────────────────────────────────────────────────

enum _ReminderKind { vaccineOverdue, vaccinePending, appointmentConfirmed, appointmentPending }

class _Reminder {
  const _Reminder({
    required this.kind,
    required this.petName,
    required this.title,
    required this.subtitle,
    this.date,
  });

  final _ReminderKind kind;
  final String petName;
  final String title;
  final String subtitle;
  final DateTime? date;

  Color get color {
    switch (kind) {
      case _ReminderKind.vaccineOverdue:      return AppColors.error;
      case _ReminderKind.vaccinePending:      return AppColors.warning;
      case _ReminderKind.appointmentConfirmed: return AppColors.success;
      case _ReminderKind.appointmentPending:  return AppColors.brand;
    }
  }

  IconData get icon {
    switch (kind) {
      case _ReminderKind.vaccineOverdue:      return Icons.vaccines_rounded;
      case _ReminderKind.vaccinePending:      return Icons.vaccines_outlined;
      case _ReminderKind.appointmentConfirmed: return Icons.event_available_rounded;
      case _ReminderKind.appointmentPending:  return Icons.event_note_rounded;
    }
  }

  String get kindLabel {
    switch (kind) {
      case _ReminderKind.vaccineOverdue:      return 'Vacuna vencida';
      case _ReminderKind.vaccinePending:      return 'Vacuna pendiente';
      case _ReminderKind.appointmentConfirmed: return 'Cita confirmada';
      case _ReminderKind.appointmentPending:  return 'Cita por confirmar';
    }
  }

  int get sortOrder {
    switch (kind) {
      case _ReminderKind.vaccineOverdue:      return 0;
      case _ReminderKind.appointmentConfirmed: return 1;
      case _ReminderKind.vaccinePending:      return 2;
      case _ReminderKind.appointmentPending:  return 3;
    }
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<_Reminder> _reminders = [];
  bool _isLoading = true;
  String? _error;

  bool _wasTickerActive = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isNowActive = TickerMode.of(context);
    if (isNowActive && !_wasTickerActive) {
      _load();
    }
    _wasTickerActive = isNowActive;
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final petsRepo = await PetsRepositoryFactory.create();
      final vaccinationRepo = VaccinationRepositoryFactory.create();
      final appointmentRepo = AppointmentRepositoryFactory.create();

      final petsResult = await petsRepo.loadPets(limit: 100);
      final pets = petsResult.pets;

      final reminders = <_Reminder>[];

      // Vacunas por cada mascota
      for (final pet in pets) {
        try {
          final plan = await vaccinationRepo.loadPatientPlan(pet.id);
          for (final dose in plan.doses) {
            if (dose.isApplied || dose.isSkipped) continue;
            reminders.add(_Reminder(
              kind: dose.isOverdue ? _ReminderKind.vaccineOverdue : _ReminderKind.vaccinePending,
              petName: pet.name,
              title: dose.vaccineName,
              subtitle: dose.doseLabel,
              date: dose.scheduledDate,
            ));
          }
        } catch (_) {}
      }

      // Solicitudes de cita
      try {
        final requests = await appointmentRepo.loadMine();
        for (final r in requests) {
          if (r.status == AppointmentRequestStatus.rechazada ||
              r.status == AppointmentRequestStatus.cancelada) continue;
          final petName = r.patientName ?? 'Mascota';
          final dateStr = r.preferredDate != null ? _parseDate(r.preferredDate!) : null;
          reminders.add(_Reminder(
            kind: r.status == AppointmentRequestStatus.confirmada
                ? _ReminderKind.appointmentConfirmed
                : _ReminderKind.appointmentPending,
            petName: petName,
            title: r.status == AppointmentRequestStatus.confirmada
                ? 'Cita confirmada'
                : 'Solicitud pendiente',
            subtitle: r.reason,
            date: dateStr,
          ));
        }
      } catch (_) {}

      // Orden: vencidas → confirmadas → pendientes vacuna → pendientes cita
      // Dentro de cada grupo: por fecha ascendente (más próximas primero)
      reminders.sort((a, b) {
        final kindCmp = a.sortOrder.compareTo(b.sortOrder);
        if (kindCmp != 0) return kindCmp;
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return a.date!.compareTo(b.date!);
      });

      if (mounted) {
        setState(() {
          _reminders = reminders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar los recordatorios.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: 'Recordatorios',
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.brand));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary, height: 1.45)),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reminders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          Text('Todo al día', textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('No tienes vacunas vencidas ni citas pendientes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary, height: 1.45)),
        ],
      );
    }

    // Agrupa por kind
    final groups = <_ReminderKind, List<_Reminder>>{};
    for (final r in _reminders) {
      groups.putIfAbsent(r.kind, () => []).add(r);
    }

    final sections = <Widget>[const SizedBox(height: 20)];
    for (final kind in _ReminderKind.values) {
      final items = groups[kind];
      if (items == null || items.isEmpty) continue;
      sections.add(_sectionHeader(items.first));
      for (final item in items) {
        sections.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _reminderCard(item),
        ));
      }
      sections.add(const SizedBox(height: 8));
    }
    sections.add(const SizedBox(height: 28));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: sections,
    );
  }

  Widget _sectionHeader(_Reminder sample) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(sample.icon, size: 16, color: sample.color),
          const SizedBox(width: 6),
          Text(
            sample.kindLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: sample.color),
          ),
        ],
      ),
    );
  }

  Widget _reminderCard(_Reminder r) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: r.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: r.color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: r.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(r.icon, color: r.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(r.title,
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    if (r.date != null)
                      Text(_formatDate(r.date!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: r.color, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(r.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.pets_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(r.petName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) {
      final days = diff.inDays.abs();
      return days == 0 ? 'Hoy' : 'Hace $days d';
    }
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Mañana';
    if (diff.inDays < 7) return 'En ${diff.inDays} días';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  DateTime? _parseDate(String isoDate) {
    return DateTime.tryParse(isoDate);
  }
}
