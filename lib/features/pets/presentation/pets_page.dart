import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_models.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_repository.dart';
import 'package:petsafe_movil_app/features/pets/data/pets_repository_factory.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  static const int _pageSize = 50;

  final TextEditingController _searchController = TextEditingController();
  PetsRepository? _repository;
  List<PetProfile> _pets = <PetProfile>[];
  PaginationMeta? _meta;
  String? _errorMessage;
  bool _isBootstrapping = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isFromCache = false;
  bool _isOffline = false;
  int _currentPage = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      _repository = await PetsRepositoryFactory.create();
      await _loadPage(page: 1, reset: true);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isBootstrapping = false);
    }
  }

  Future<PetsRepository> _getRepository() async {
    final repository = _repository;
    if (repository != null) return repository;
    final created = await PetsRepositoryFactory.create();
    _repository = created;
    return created;
  }

  Future<void> _refresh() => _loadPage(page: 1, reset: true);

  Future<void> _loadMore() async {
    if (_isLoadingMore || !(_meta?.hasNextPage ?? false)) return;
    await _loadPage(page: _currentPage + 1, reset: false, loadingMore: true);
  }

  Future<void> _loadPage({
    required int page,
    required bool reset,
    bool loadingMore = false,
  }) async {
    final repository = await _getRepository();
    if (!mounted) return;

    setState(() {
      _errorMessage = null;
      _isLoading = reset;
      _isLoadingMore = loadingMore;
    });

    try {
      final result = await repository.loadPets(page: page, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _meta = result.meta;
        _currentPage = result.meta.currentPage;
        _isFromCache = result.fromCache;
        _isOffline = result.isOffline;
        _pets = reset ? result.pets : _mergePets(_pets, result.pets);
      });
    } on ApiFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        if (reset) {
          _pets = <PetProfile>[];
          _meta = null;
          _currentPage = 0;
          _isFromCache = false;
          _isOffline = false;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyError(error);
        if (reset) {
          _pets = <PetProfile>[];
          _meta = null;
          _currentPage = 0;
          _isFromCache = false;
          _isOffline = false;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  List<PetProfile> get _visiblePets {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _pets;
    return _pets.where((pet) => _matchesQuery(pet, query)).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visiblePets = _visiblePets;
    final totalPets = _meta?.totalItems ?? _pets.length;
    final hasPets = _pets.isNotEmpty;
    final hasMore = _meta?.hasNextPage ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas'),
        actions: [
          if (hasPets || _errorMessage != null)
            IconButton(
              onPressed: (_isLoading || _isLoadingMore) ? null : _refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            _heroCard(totalPets, visiblePets.length),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              enabled: !_isLoading && !_isLoadingMore,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                labelText: 'Buscar mascota',
                hintText: 'Nombre, codigo, especie, raza o microchip',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isBootstrapping || (_isLoading && !hasPets)) _loadingPanel(),
            if (!_isBootstrapping && _errorMessage != null && !hasPets)
              _errorPanel(_errorMessage!),
            if (hasPets) ...[
              if (_errorMessage != null) ...[
                _banner(
                  icon: Icons.warning_amber_rounded,
                  title: 'La ultima consulta tuvo un problema',
                  message: _errorMessage!,
                  accentColor: AppColors.warning,
                  backgroundColor: AppColors.warningBg,
                  actionLabel: 'Reintentar',
                  onActionPressed: _refresh,
                ),
                const SizedBox(height: 12),
              ],
              if (_isFromCache || _isOffline) ...[
                _banner(
                  icon: Icons.cloud_off_rounded,
                  title: _isOffline ? 'Mostrando informacion guardada en el dispositivo' : 'Mostrando respuesta cacheada',
                  message: 'La app recupero la ultima informacion disponible para que no te quedes sin acceso.',
                  accentColor: AppColors.info,
                  backgroundColor: AppColors.infoBg,
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),
              _summaryCard(totalPets, _pets.length, visiblePets.length, hasMore, _isLoadingMore),
              const SizedBox(height: 16),
              if (visiblePets.isEmpty)
                _emptyFilterState()
              else
                ...visiblePets.map((pet) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _petCard(pet),
                    )),
              if (hasMore) ...[
                const SizedBox(height: 8),
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _loadMore,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Cargar mas mascotas'),
                  ),
              ],
            ],
            if (!hasPets && _errorMessage == null && !_isLoading && !_isBootstrapping)
              _emptyState(),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(int totalPets, int visiblePets) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF3F8F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.activeSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.pets_rounded, color: AppColors.brand, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tus mascotas', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Consulta la informacion principal de cada mascota, su codigo QR y sus datos clinicos clave.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.pets_rounded, '$totalPets mascotas'),
              _chip(Icons.filter_alt_rounded, '$visiblePets visibles'),
              if (_isFromCache) _chip(Icons.cloud_off_rounded, _isOffline ? 'Modo offline' : 'Cache local'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _summaryCard(int totalPets, int loadedPets, int visiblePets, bool hasMore, bool isLoadingMore) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metric('Totales', totalPets.toString(), Icons.pets_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _metric('Cargadas', loadedPets.toString(), Icons.storage_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _metric('Mostradas', visiblePets.toString(), Icons.visibility_rounded)),
            ],
          ),
          if (hasMore) ...[
            const SizedBox(height: 14),
            Text(
              'Hay mas mascotas disponibles en el servidor.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: isLoadingMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : OutlinedButton.icon(
                      onPressed: _loadMore,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Cargar mas mascotas'),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
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
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _petCard(PetProfile pet) {
    final activeConditions = pet.conditions.where((condition) => condition.active).toList(growable: false);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showPetDetails(pet),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.activeSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.pets_rounded, color: AppColors.brand),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          '${pet.speciesLabel} • ${pet.breedLabel}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _statusPill(pet.sexLabel),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _infoChip(Icons.badge_outlined, pet.codeLabel),
                  _infoChip(Icons.fitness_center_rounded, pet.weightLabel),
                  _infoChip(Icons.cake_outlined, pet.ageLabel),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Microchip: ${pet.microchipLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showPetDetails(pet),
                    icon: const Icon(Icons.qr_code_rounded),
                    color: AppColors.brand,
                  ),
                ],
              ),
              if (activeConditions.isNotEmpty)
                Text(
                  'Condiciones activas: ${activeConditions.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
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

  Widget _infoChip(IconData icon, String label) {
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
  Widget _banner({
    required IconData icon,
    required String title,
    required String message,
    required Color accentColor,
    required Color backgroundColor,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                if (actionLabel != null && onActionPressed != null) ...[
                  const SizedBox(height: 10),
                  TextButton(onPressed: onActionPressed, child: Text(actionLabel)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingPanel() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.brand),
          SizedBox(height: 16),
          Text('Cargando mascotas...'),
        ],
      ),
    );
  }

  Widget _errorPanel(String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.error.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text('No fue posible cargar tus mascotas', style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _emptyFilterState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.activeSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.search_off_rounded, color: AppColors.brand, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            'No encontramos mascotas con "${_searchQuery.trim()}".',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba con otro nombre, codigo o borra el filtro para ver toda la lista.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            icon: const Icon(Icons.clear_rounded),
            label: const Text('Limpiar busqueda'),
          ),
        ],
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.activeSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.pets_rounded, color: AppColors.brand, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            'Aun no tienes mascotas registradas.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando el backend tenga mascotas asociadas a tu cuenta, aqui veras su informacion principal y su QR de identificacion.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  void _showPetDetails(PetProfile pet) {
    final activeConditions = pet.conditions.where((condition) => condition.active).toList(growable: false);
    final qrPayload = _qrPayloadForPet(pet);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
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
                  const SizedBox(height: 18),
                  Text(pet.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _infoChip(Icons.badge_outlined, pet.codeLabel),
                      _infoChip(Icons.pets_rounded, pet.speciesLabel),
                      _infoChip(Icons.qr_code_rounded, 'QR'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.qr_code_rounded, color: AppColors.brand, size: 22),
                        const SizedBox(height: 10),
                        QrImageView(
                          data: qrPayload,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(pet.codeLabel, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: qrPayload));
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Codigo QR copiado al portapapeles')),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copiar codigo QR'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Informacion principal', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _detailCard([
                    _detailRow('Microchip', pet.microchipLabel),
                    _detailRow('Sexo', pet.sexLabel),
                    _detailRow('Edad', pet.ageLabel),
                    _detailRow('Peso actual', pet.weightLabel),
                    _detailRow('Fecha de nacimiento', _formatDate(pet.birthDate)),
                    _detailRow('Esterilizado', pet.sterilized ? 'Si' : 'No'),
                    _detailRow('Especie', pet.speciesLabel),
                    _detailRow('Raza', pet.breedLabel),
                    _detailRow('Color', pet.colorLabel),
                  ]),
                  const SizedBox(height: 16),
                  Text('Notas clinicas', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _detailCard([
                    _detailText('Marcas distintivas', pet.distinguishingMarks, 'No registra marcas distintivas.'),
                    const SizedBox(height: 12),
                    _detailText('Alergias generales', pet.generalAllergies, 'No registra alergias generales.'),
                    const SizedBox(height: 12),
                    _detailText('Historia general', pet.generalHistory, 'No registra historia general.'),
                  ]),
                  const SizedBox(height: 16),
                  Text('Condiciones clinicas', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _detailCard(
                    activeConditions.isEmpty
                        ? [
                            Text(
                              'No hay condiciones clinicas activas registradas.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                            ),
                          ]
                        : [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: activeConditions
                                  .map((condition) => _conditionChip(condition.type, condition.name))
                                  .toList(growable: false),
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

  Widget _detailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
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
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(value, textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _detailText(String label, String? value, String emptyLabel) {
    final text = value?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text(text.isEmpty ? emptyLabel : text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
      ],
    );
  }

  Widget _conditionChip(String type, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$type: $name',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  bool _matchesQuery(PetProfile pet, String query) {
    final terms = <String>[
      pet.name,
      pet.codeLabel,
      pet.speciesLabel,
      pet.breedLabel,
      pet.colorLabel,
      pet.sexLabel,
      pet.microchipLabel,
      pet.distinguishingMarks ?? '',
      pet.generalAllergies ?? '',
      pet.generalHistory ?? '',
      ...pet.conditions.map((condition) => [condition.type, condition.name, condition.description ?? ''].join(' ')),
    ].join(' ').toLowerCase();
    return terms.contains(query);
  }

  List<PetProfile> _mergePets(List<PetProfile> current, List<PetProfile> incoming) {
    final byId = <int, PetProfile>{for (final pet in current) pet.id: pet};
    for (final pet in incoming) {
      byId[pet.id] = pet;
    }
    return byId.values.toList(growable: false);
  }

  String _qrPayloadForPet(PetProfile pet) {
    final code = pet.code.trim().isNotEmpty ? pet.code.trim() : pet.id.toString();
    return 'PETSAFE|PATIENT|${pet.id}|$code';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No registrada';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _friendlyError(Object error) {
    if (error is ApiFailure) return error.message;
    return 'No se pudo cargar la informacion de las mascotas.';
  }
}
