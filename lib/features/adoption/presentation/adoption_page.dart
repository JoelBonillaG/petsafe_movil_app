import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/config/app_config.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';
import 'package:petsafe_movil_app/features/adoption/data/adoption_models.dart';
import 'package:petsafe_movil_app/features/adoption/data/adoption_repository.dart';
import 'package:petsafe_movil_app/features/adoption/data/adoption_repository_factory.dart';

class AdoptionPage extends StatefulWidget {
  const AdoptionPage({super.key});

  @override
  State<AdoptionPage> createState() => _AdoptionPageState();
}

class _AdoptionPageState extends State<AdoptionPage> {
  late final AdoptionRepository _repository;

  List<AdoptionItem> _items = <AdoptionItem>[];
  bool _isLoading = false;
  String? _errorMessage;

  bool _wasTickerActive = false;

  List<AdoptionItem> get _visibleItems => _items;

  @override
  void initState() {
    super.initState();
    _repository = AdoptionRepositoryFactory.create();
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
      _errorMessage = null;
    });
    try {
      final result = await _repository.loadCatalog();
      if (mounted) {
        setState(() {
          _items = result.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('ApiFailure: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: 'Adopcion',
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
              onPressed: _showAdoptionFlowInfo,
              tooltip: 'Ver proceso de adopcion',
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
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _errorState();
    }

    final visible = _visibleItems;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        _heroCard(visible.length),
        const SizedBox(height: 16),
        Text(
          'Catalogo disponible',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        if (visible.isEmpty)
          _emptyState()
        else
          ...visible
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _petCard(item),
                ),
              )
              .toList(growable: false),
      ],
    );
  }

  Widget _errorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 60),
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
        Center(
          child: OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
      ],
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
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  'Adopta y ayuda a una mascota revisando su perfil y dando el primer paso.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.93),
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

  Widget _petCard(AdoptionItem item) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showDetails(item),
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
                  imageUrl: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? AppConfig.normalizeImageUrl(item.imageUrl!)
                      : AppMedia.adoptionImageFor(item.petName),
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
                          Expanded(
                            child: Text(
                              item.petName,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          _statusPill(item.speciesLabel),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Raza: ${item.breedLabel}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (item.contactName != null || item.contactPhone != null)
                        Text(
                          [
                            if (item.contactName != null) item.contactName!,
                            if (item.contactPhone != null) item.contactPhone!,
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.story != null) ...[
              const SizedBox(height: 12),
              Text(
                item.story!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
            if (item.tagNames.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.tagNames
                    .map((tag) => _traitChip(tag))
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDetails(item),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Ver mas'),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  void _showAdoptionFlowInfo() {
    final steps = <_ProcessStep>[
      const _ProcessStep(
        title: 'Revisa mascotas en adopcion',
        subtitle: 'Explora los animales disponibles de la clinica y abre su ficha.',
        icon: Icons.search_rounded,
        color: AppColors.brand,
      ),
      const _ProcessStep(
        title: 'Si te interesa, llama',
        subtitle: 'Usa el boton de llamada para contactar al dueno o responsable.',
        icon: Icons.phone_rounded,
        color: AppColors.warning,
      ),
      const _ProcessStep(
        title: 'Coordinan la adopcion',
        subtitle: 'Acorden visita y entrega responsable segun disponibilidad.',
        icon: Icons.handshake_rounded,
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
                'Como funciona la adopcion',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Sigue estos pasos para hacer el proceso claro y rapido.',
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
                          child: _processStepCard(step),
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

  void _showDetails(AdoptionItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 +
                MediaQuery.of(sheetContext).viewInsets.bottom +
                MediaQuery.of(sheetContext).padding.bottom,
          ),
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
                  imageUrl: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? AppConfig.normalizeImageUrl(item.imageUrl!)
                      : AppMedia.adoptionImageFor(item.petName),
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
                        item.petName,
                        style: Theme.of(sheetContext).textTheme.titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Ficha de adopcion',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
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
                      _detailRow('Especie', item.speciesLabel),
                      _detailRow('Raza', item.breedLabel),
                      if (item.contactName != null)
                        _detailRow('Contacto', item.contactName!),
                      if (item.contactPhone != null)
                        _detailRow('Telefono', item.contactPhone!),
                      if (item.contactEmail != null)
                        _detailRow('Correo', item.contactEmail!),
                      if (item.story != null) ...[
                        const SizedBox(height: 10),
                        Text('Historia',
                            style: Theme.of(sheetContext).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          item.story!,
                          style: Theme.of(sheetContext).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary, height: 1.45),
                        ),
                      ],
                      if (item.requirements != null) ...[
                        const SizedBox(height: 10),
                        Text('Requisitos',
                            style: Theme.of(sheetContext).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          item.requirements!,
                          style: Theme.of(sheetContext).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary, height: 1.45),
                        ),
                      ],
                      if (item.tagNames.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.tagNames
                              .map((tag) => _traitChip(tag))
                              .toList(growable: false),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (item.contactPhone != null)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _onCallTap(item.contactPhone!),
                          icon: const Icon(Icons.phone_rounded),
                          label: Text('Llamar: ${item.contactPhone}'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCallTap(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacto: $phone')),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
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
