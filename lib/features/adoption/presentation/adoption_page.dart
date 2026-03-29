import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';

class AdoptionPage extends StatefulWidget {
  const AdoptionPage({super.key});

  @override
  State<AdoptionPage> createState() => _AdoptionPageState();
}

class _AdoptionPageState extends State<AdoptionPage> {
  late final List<_AdoptionPet> _pets = <_AdoptionPet>[
    const _AdoptionPet(
      name: 'Nala',
      species: 'Gata',
      breed: 'Criolla',
      age: '8 meses',
      sex: 'Hembra',
      size: 'Pequena',
      location: 'Quito',
      story:
          'Es una gata tranquila y curiosa que disfruta los espacios calmados y la compania cercana.',
      traits: <String>['Sociable', 'Juguetona', 'Esterilizada'],
      compatibility: 'Ideal para hogares tranquilos y familias con experiencia en gatos.',
      filter: 'Gatos',
      color: AppColors.accent,
    ),
    const _AdoptionPet(
      name: 'Toby',
      species: 'Perro',
      breed: 'Criollo',
      age: '1 ano',
      sex: 'Macho',
      size: 'Mediano',
      location: 'Guayaquil',
      story:
          'Tiene energia media, le gustan los paseos y responde muy bien al refuerzo positivo.',
      traits: <String>['Amigable', 'Activo', 'Vacunado'],
      compatibility: 'Buen candidato para familia activa o casa con patio.',
      filter: 'Perros',
      color: AppColors.brand,
    ),
    const _AdoptionPet(
      name: 'Coco',
      species: 'Perro',
      breed: 'Labrador',
      age: '6 meses',
      sex: 'Macho',
      size: 'Mediano',
      location: 'Cuenca',
      story:
          'Cachorro afectuoso, muy sociable y con gran facilidad para aprender rutinas.',
      traits: <String>['Cachorro', 'Sociable', 'Listo para adoptar'],
      compatibility: 'Ideal para familias que quieran acompañarlo en su etapa de aprendizaje.',
      filter: 'Cachorros',
      color: AppColors.success,
    ),
    const _AdoptionPet(
      name: 'Lola',
      species: 'Gata',
      breed: 'Angora',
      age: '2 anos',
      sex: 'Hembra',
      size: 'Pequena',
      location: 'Ambato',
      story:
          'Le gusta observar desde lugares altos y se adapta bien a rutinas calmadas.',
      traits: <String>['Independiente', 'Elegante', 'Vacunada'],
      compatibility: 'Se adapta bien a apartamentos y espacios interiores.',
      filter: 'Adultos',
      color: AppColors.primary,
    ),
  ];

  final List<String> _filters = <String>['Todos', 'Perros', 'Gatos', 'Cachorros', 'Adultos'];

  String _selectedFilter = 'Todos';

  List<_AdoptionPet> get _visiblePets {
    if (_selectedFilter == 'Todos') {
      return _pets;
    }
    return _pets.where((pet) => pet.filter == _selectedFilter).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visiblePets = _visiblePets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopcion'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _heroCard(visiblePets.length),
          const SizedBox(height: 16),
          _modeBanner(),
          const SizedBox(height: 16),
          Text(
            'Filtros rapidos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filters.map((filter) {
              final selected = filter == _selectedFilter;
              return FilterChip(
                label: Text(filter),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 16),
          Text(
            'Catalogo disponible',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          if (visiblePets.isEmpty)
            _emptyState()
          else
            ...visiblePets
                .map(
                  (pet) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _petCard(pet),
                  ),
                )
                .toList(growable: false),
          const SizedBox(height: 6),
          Text(
            'Proceso de adopcion',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _processCard(),
        ],
      ),
    );
  }

  Widget _heroCard(int visibleCount) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: NetworkImageCard(
        imageUrl: AppMedia.adoptionHero,
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
                  _glassChip(Icons.favorite_rounded, 'Adopcion'),
                  const Spacer(),
                  const NetworkAvatar(imageUrl: AppMedia.profileHero, size: 48),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mascotas con historia',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explora perfiles visuales con fotos reales, filtros rapidos y un flujo de adopcion mas humano.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.93),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _glassChip(Icons.pets_rounded, '${_pets.length} en total'),
                  const SizedBox(width: 8),
                  _glassChip(Icons.visibility_rounded, '$visibleCount visibles'),
                  const SizedBox(width: 8),
                  _glassChip(Icons.verified_rounded, 'Perfil de adopcion'),
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
              'Vista modelada con datos estaticos. Luego conectaremos el catalogo real y el flujo de solicitud de adopcion.',
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

  Widget _petCard(_AdoptionPet pet) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showDetails(pet),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworkImageCard(
                  imageUrl: AppMedia.adoptionImageFor(pet.name),
                  height: 94,
                  width: 94,
                  borderRadius: 22,
                  showBorder: false,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(pet.name, style: theme.textTheme.titleMedium)),
                          _statusPill(pet.filter),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet.species} - ${pet.breed}',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(Icons.cake_outlined, pet.age),
                          _chip(Icons.wc_rounded, pet.sex),
                          _chip(Icons.straighten_rounded, pet.size),
                          _chip(Icons.place_rounded, pet.location),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pet.story,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pet.traits.map((trait) => _traitChip(trait)).toList(growable: false),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetails(pet),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Ver ficha'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showPendingAction,
                    icon: const Icon(Icons.favorite_border_rounded),
                    label: const Text('Me interesa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
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

  Widget _traitChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _statusPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.activeSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.brand,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          NetworkImageCard(
            imageUrl: AppMedia.dogHeroTwo,
            height: 120,
            borderRadius: 22,
            showBorder: false,
            showShadow: false,
          ),
          const SizedBox(height: 14),
          Text(
            'No hay mascotas para ese filtro.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Cambia el filtro para ver otros perfiles de adopcion disponibles.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }

  Widget _processCard() {
    final steps = <_ProcessStep>[
      const _ProcessStep(
        title: 'Explorar catalogo',
        subtitle: 'Navega por las fichas y revisa compatibilidad.',
        icon: Icons.search_rounded,
        color: AppColors.brand,
      ),
      const _ProcessStep(
        title: 'Solicitar interes',
        subtitle: 'Envias una solicitud para continuar el proceso.',
        icon: Icons.favorite_border_rounded,
        color: AppColors.warning,
      ),
      const _ProcessStep(
        title: 'Revision y contacto',
        subtitle: 'El equipo revisa tu perfil y coordina el siguiente paso.',
        icon: Icons.phone_in_talk_rounded,
        color: AppColors.success,
      ),
      const _ProcessStep(
        title: 'Entrega responsable',
        subtitle: 'Se finaliza la adopcion con el seguimiento correspondiente.',
        icon: Icons.handshake_rounded,
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
                child: _processStepCard(step),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _processStepCard(_ProcessStep step) {
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

  void _showDetails(_AdoptionPet pet) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Cerrar',
                    ),
                  ),
                  const SizedBox(height: 18),
                  NetworkImageCard(
                    imageUrl: AppMedia.adoptionImageFor(pet.name),
                    height: 180,
                    borderRadius: 24,
                    showBorder: false,
                    overlayGradient: const LinearGradient(
                      colors: [Color(0x99000000), Color(0x22000000)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    foreground: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          pet.name,
                          style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Ficha de adopcion', style: Theme.of(sheetContext).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(Icons.pets_rounded, pet.species),
                      _chip(Icons.place_rounded, pet.location),
                      _chip(Icons.favorite_rounded, pet.filter),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow('Raza', pet.breed),
                        _detailRow('Edad', pet.age),
                        _detailRow('Sexo', pet.sex),
                        _detailRow('Tamano', pet.size),
                        _detailRow('Disponibilidad', 'Lista para conocer a su futura familia'),
                        const SizedBox(height: 10),
                        Text(
                          pet.story,
                          style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pet.traits
                              .map((trait) => _traitChip(trait))
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Compatibilidad',
                          style: Theme.of(sheetContext).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pet.compatibility,
                          style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showPendingAction,
                          icon: const Icon(Icons.message_rounded),
                          label: const Text('Contactar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showPendingAction,
                          icon: const Icon(Icons.favorite_rounded),
                          label: const Text('Me interesa'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

  void _showPendingAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catalogo modelado. Luego conectaremos el flujo real de adopcion.'),
      ),
    );
  }
}

class _AdoptionPet {
  const _AdoptionPet({
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.sex,
    required this.size,
    required this.location,
    required this.story,
    required this.traits,
    required this.compatibility,
    required this.filter,
    required this.color,
  });

  final String name;
  final String species;
  final String breed;
  final String age;
  final String sex;
  final String size;
  final String location;
  final String story;
  final List<String> traits;
  final String compatibility;
  final String filter;
  final Color color;
}

class _ProcessStep {
  const _ProcessStep({
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
