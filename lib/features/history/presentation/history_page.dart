import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
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

  int _selectedIndex = 0;

  _HistoryPet get _selectedPet => _pets[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    final pet = _selectedPet;

    return FeaturePageScaffold(
      title: 'Historial clinico',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _heroCard(pet),
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
          SizedBox(
            width: double.infinity,
            child: _metricCard('Procedimientos', pet.procedures.toString(), Icons.healing_rounded),
          ),
          const SizedBox(height: 16),
          Text(
            'Historial en PDF',
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
                label: const Text('Ver historial PDF'),
              ),
              OutlinedButton.icon(
                onPressed: _showPendingAction,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Exportar PDF'),
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
                  'Revisa el historial clinico de tu mascota y exportalo en PDF.',
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
                    Text('Expediente de ${pet.name}', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.species} | ${pet.breed} | Ultima visita ${pet.lastVisit}',
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
                  'Resumen clinico',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  pet.summary,
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


  void _showPdfPreview() {
    final pet = _selectedPet;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  28 + MediaQuery.of(context).padding.bottom,
                ),
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

