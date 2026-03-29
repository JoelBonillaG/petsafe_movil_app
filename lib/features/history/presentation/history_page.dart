import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final List<_HistoryPet> _pets = <_HistoryPet>[
    const _HistoryPet(
      name: 'Luna',
      code: 'PET-001',
      species: 'Perro',
      breed: 'Labrador',
      lastUpdate: '12/03/2026',
      lastVisit: '08/03/2026',
      summary:
          'Control general estable, plan de seguimiento en 30 dias y vacunas al dia.',
      totalPages: 6,
      consults: 8,
      vaccines: 5,
      dewormings: 3,
      procedures: 2,
      color: AppColors.brand,
    ),
    const _HistoryPet(
      name: 'Mia',
      code: 'PET-014',
      species: 'Gato',
      breed: 'Angora',
      lastUpdate: '21/02/2026',
      lastVisit: '20/02/2026',
      summary:
          'Historia con controles periodicos, desparasitacion reciente y observacion nutricional.',
      totalPages: 4,
      consults: 6,
      vaccines: 4,
      dewormings: 2,
      procedures: 1,
      color: AppColors.accent,
    ),
    const _HistoryPet(
      name: 'Rocky',
      code: 'PET-019',
      species: 'Perro',
      breed: 'Criollo',
      lastUpdate: '05/01/2026',
      lastVisit: '28/12/2025',
      summary:
          'Registro con tratamiento ortopedico, control de peso y seguimiento de recuperacion.',
      totalPages: 5,
      consults: 10,
      vaccines: 6,
      dewormings: 4,
      procedures: 4,
      color: AppColors.primary,
    ),
  ];

  late final List<_TimelineEvent> _timeline = <_TimelineEvent>[
    const _TimelineEvent(
      title: 'Consulta general',
      subtitle: 'Evaluacion completa, signos vitales y recomendaciones de cuidado.',
      date: '08/03/2026',
      icon: Icons.medical_services_rounded,
      color: AppColors.brand,
    ),
    const _TimelineEvent(
      title: 'Vacunacion',
      subtitle: 'Aplicacion registrada y proxima dosis sugerida en control posterior.',
      date: '14/02/2026',
      icon: Icons.vaccines_rounded,
      color: AppColors.success,
    ),
    const _TimelineEvent(
      title: 'Desparasitacion',
      subtitle: 'Evento registrado con proxima fecha recomendada por seguimiento.',
      date: '10/01/2026',
      icon: Icons.bug_report_rounded,
      color: AppColors.warning,
    ),
    const _TimelineEvent(
      title: 'Procedimiento',
      subtitle: 'Registro de intervencion y notas medicas anexas al expediente.',
      date: '28/12/2025',
      icon: Icons.healing_rounded,
      color: AppColors.accent,
    ),
  ];

  int _selectedIndex = 0;

  _HistoryPet get _selectedPet => _pets[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    final pet = _selectedPet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial clinico'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _heroCard(pet),
          const SizedBox(height: 16),
          _modeBanner(),
          const SizedBox(height: 16),
          Text(
            'Selecciona una mascota',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(_pets.length, (index) {
              final item = _pets[index];
              final selected = index == _selectedIndex;
              return ChoiceChip(
                label: Text(item.name),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          _pdfPreviewCard(pet),
          const SizedBox(height: 16),
          Text(
            'Resumen del expediente',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _metricCard('Consultas', pet.consults.toString(), Icons.medical_services_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('Vacunas', pet.vaccines.toString(), Icons.vaccines_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCard('Desparasitacion', pet.dewormings.toString(), Icons.bug_report_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('Procedimientos', pet.procedures.toString(), Icons.healing_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Linea de tiempo clinica',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ..._timeline
              .map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _timelineCard(event),
                  ))
              .toList(growable: false),
          const SizedBox(height: 6),
          Text(
            'Acciones de historial',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: _showPdfPreview,
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Vista previa PDF'),
              ),
              OutlinedButton.icon(
                onPressed: _showPendingAction,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Exportar PDF'),
              ),
              OutlinedButton.icon(
                onPressed: _showPendingAction,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Compartir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroCard(_HistoryPet pet) {
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
                  _glassChip(Icons.description_rounded, 'Historial clinico'),
                  const Spacer(),
                  _glassChip(Icons.picture_as_pdf_rounded, '${pet.totalPages} paginas'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expediente de ${pet.name}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vista de consulta y exportacion en PDF para el expediente de ${pet.name}.',
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
                children: <Widget>[
                  _glassChip(Icons.pets_rounded, pet.name),
                  _glassChip(Icons.badge_outlined, pet.code),
                  _glassChip(Icons.calendar_month_rounded, 'Actualizado ${pet.lastUpdate}'),
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
              'Esta pantalla esta modelada para visualizacion. Mas adelante conectaremos la lectura real del historial y la exportacion a PDF desde el backend.',
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

  Widget _pdfPreviewCard(_HistoryPet pet) {
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
          NetworkImageCard(
            imageUrl: AppMedia.petImageFor(name: pet.name, species: pet.species),
            height: 140,
            borderRadius: 18,
            showBorder: false,
            showShadow: false,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.activeSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Documento PDF', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Vista preliminar del archivo clinico antes de exportarlo.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expediente de ${pet.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.species} | ${pet.breed} | Ultima visita ${pet.lastVisit}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 14),
                _pdfSection('1. Resumen general', pet.summary),
                const SizedBox(height: 12),
                _pdfSection('2. Consultas y tratamientos', 'Consultas, medicamentos, procedimientos y planes de seguimiento.'),
                const SizedBox(height: 12),
                _pdfSection('3. Vacunas y control preventivo', 'Vacunacion, desparasitacion y futuras fechas sugeridas.'),
                const SizedBox(height: 12),
                _pdfSection('4. Notas clinicas', 'Alergias, observaciones y recomendaciones medicas registradas.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pdfSection(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.activeSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.article_outlined, size: 16, color: AppColors.brand),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
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

  Widget _timelineCard(_TimelineEvent event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(event.icon, color: event.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      event.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
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

  void _showPdfPreview() {
    final pet = _selectedPet;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                  const SizedBox(height: 18),
                  Text(
                    'Vista previa PDF',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modelo visual del documento que luego generara el backend.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 18),
                  _pdfPreviewCard(pet),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPendingAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcion modelada. Luego se conectara al backend.'),
      ),
    );
  }
}

class _HistoryPet {
  const _HistoryPet({
    required this.name,
    required this.code,
    required this.species,
    required this.breed,
    required this.lastUpdate,
    required this.lastVisit,
    required this.summary,
    required this.totalPages,
    required this.consults,
    required this.vaccines,
    required this.dewormings,
    required this.procedures,
    required this.color,
  });

  final String name;
  final String code;
  final String species;
  final String breed;
  final String lastUpdate;
  final String lastVisit;
  final String summary;
  final int totalPages;
  final int consults;
  final int vaccines;
  final int dewormings;
  final int procedures;
  final Color color;
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color color;
}
