import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late final List<_AppointmentPet> _pets = <_AppointmentPet>[
    const _AppointmentPet(name: 'Luna', species: 'Perro', breed: 'Labrador', code: 'PET-001'),
    const _AppointmentPet(name: 'Mia', species: 'Gato', breed: 'Angora', code: 'PET-014'),
    const _AppointmentPet(name: 'Rocky', species: 'Perro', breed: 'Criollo', code: 'PET-019'),
  ];

  late final List<_AppointmentRequest> _requests = <_AppointmentRequest>[
    const _AppointmentRequest(
      petName: 'Luna',
      type: 'Control general',
      date: '18/03/2026',
      time: '09:30',
      status: _AppointmentStatus.pending,
      note: 'En espera de revision del veterinario.',
    ),
    const _AppointmentRequest(
      petName: 'Mia',
      type: 'Vacunacion',
      date: '12/03/2026',
      time: '15:00',
      status: _AppointmentStatus.confirmed,
      note: 'Confirmada por el veterinario y lista para atencion.',
    ),
    const _AppointmentRequest(
      petName: 'Rocky',
      type: 'Desparasitacion',
      date: '06/03/2026',
      time: '11:00',
      status: _AppointmentStatus.rejected,
      note: 'Reprogramada por disponibilidad de agenda.',
    ),
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController(text: 'Control general');
  final TextEditingController _notesController = TextEditingController();

  int _selectedPetIndex = 0;
  String _selectedType = 'Control general';
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;

  @override
  void initState() {
    super.initState();
    _preferredDate = DateTime.now().add(const Duration(days: 7));
    _preferredTime = const TimeOfDay(hour: 9, minute: 30);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  _AppointmentPet get _selectedPet => _pets[_selectedPetIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas medicas'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          _modeBanner(),
          const SizedBox(height: 16),
          Text(
            'Mascota a atender',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
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
                  setState(() {
                    _selectedPetIndex = index;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          _requestFormCard(),
          const SizedBox(height: 16),
          _requestPreviewCard(),
          const SizedBox(height: 16),
          Text(
            'Solicitudes recientes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ..._requests
              .map((request) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _requestCard(request),
                  ))
              .toList(growable: false),
          const SizedBox(height: 6),
          Text(
            'Flujo de aprobacion',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _flowCard(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _glassChip(Icons.calendar_month_rounded, 'Citas'),
                  const Spacer(),
                  const NetworkAvatar(imageUrl: AppMedia.profileHero, size: 48),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solicitud de citas',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Formulario visual para agendar atenciones medicas con peticion, revision y confirmacion.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.93),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _glassChip(Icons.pets_rounded, _selectedPet.name),
                  _glassChip(Icons.schedule_rounded, _formatDate(_preferredDate)),
                  _glassChip(Icons.timelapse_rounded, _formatTime(_preferredTime)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.info.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Esta vista esta modelada. Luego el formulario real enviara la solicitud al backend y el veterinario la aprobara o rechazara.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestFormCard() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Formulario de solicitud', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de cita',
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              items: const <String>[
                'Control general',
                'Vacunacion',
                'Desparasitacion',
                'Cirugia',
                'Urgencia controlada',
              ]
                  .map((value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedType = value;
                  _reasonController.text = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Ingresa el motivo de la cita';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha preferida',
                        prefixIcon: Icon(Icons.event_rounded),
                      ),
                      child: Text(_formatDate(_preferredDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora preferida',
                        prefixIcon: Icon(Icons.schedule_rounded),
                      ),
                      child: Text(_formatTime(_preferredTime)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                prefixIcon: Icon(Icons.comment_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitModel,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Solicitar cita'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestPreviewCard() {
    final pet = _selectedPet;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.activeSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.preview_rounded, color: AppColors.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Vista previa de la solicitud', style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _previewRow('Mascota', '${pet.name} (${pet.code})'),
          _previewRow('Tipo', _selectedType),
          _previewRow('Fecha', _formatDate(_preferredDate)),
          _previewRow('Hora', _formatTime(_preferredTime)),
          _previewRow('Estado', 'Pendiente de revision'),
          const SizedBox(height: 10),
          Text(
            'El backend luego validara disponibilidad, veterinario asignado y confirmacion de agenda.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(_AppointmentRequest request) {
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
                imageUrl: AppMedia.petImageFor(name: request.petName),
                size: 54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${request.petName} - ${request.type}', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${request.date} | ${request.time}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _statusPill(request.status.label, request.status.color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _flowCard() {
    final steps = <_FlowStep>[
      const _FlowStep(
        title: 'Solicitud enviada',
        subtitle: 'El usuario completa el formulario desde la app.',
        icon: Icons.send_rounded,
        color: AppColors.brand,
      ),
      const _FlowStep(
        title: 'Revision veterinaria',
        subtitle: 'El veterinario revisa agenda y motivo de la cita.',
        icon: Icons.rate_review_rounded,
        color: AppColors.warning,
      ),
      const _FlowStep(
        title: 'Confirmacion o rechazo',
        subtitle: 'La solicitud cambia de estado y se notifica al usuario.',
        icon: Icons.verified_rounded,
        color: AppColors.success,
      ),
      const _FlowStep(
        title: 'Atencion',
        subtitle: 'La cita se atiende en la fecha y hora confirmadas.',
        icon: Icons.medical_services_rounded,
        color: AppColors.accent,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(22),
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
            color: step.color.withOpacity(0.12),
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

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.brand),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _glassChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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
    setState(() {
      _preferredDate = selected;
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? TimeOfDay.now(),
    );

    if (!mounted || selected == null) return;
    setState(() {
      _preferredTime = selected;
    });
  }

  void _submitModel() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulario modelado. Luego se conectara al backend de citas.'),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Sin hora';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _AppointmentPet {
  const _AppointmentPet({
    required this.name,
    required this.species,
    required this.breed,
    required this.code,
  });

  final String name;
  final String species;
  final String breed;
  final String code;
}

class _AppointmentRequest {
  const _AppointmentRequest({
    required this.petName,
    required this.type,
    required this.date,
    required this.time,
    required this.status,
    required this.note,
  });

  final String petName;
  final String type;
  final String date;
  final String time;
  final _AppointmentStatus status;
  final String note;
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

enum _AppointmentStatus {
  pending('Pendiente', AppColors.warning, Icons.hourglass_top_rounded),
  confirmed('Confirmada', AppColors.success, Icons.verified_rounded),
  rejected('Rechazada', AppColors.error, Icons.cancel_rounded);

  const _AppointmentStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}
