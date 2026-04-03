import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/router/app_routes.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_DashboardFeature>[
      const _DashboardFeature(
        title: 'Mascotas',
        description: 'Consulta ficha, QR y datos clinicos principales.',
        icon: Icons.pets_rounded,
        color: AppColors.brand,
        routeName: AppRoutes.pets,
        imageUrl: AppMedia.dogHeroOne,
      ),
      const _DashboardFeature(
        title: 'Citas',
        description: 'Solicita una cita y revisa su estado de aprobacion.',
        icon: Icons.calendar_month_rounded,
        color: AppColors.warning,
        routeName: AppRoutes.appointments,
        imageUrl: AppMedia.clinicHero,
      ),
      const _DashboardFeature(
        title: 'Historial',
        description: 'Vista previa del expediente y futura exportacion PDF.',
        icon: Icons.description_rounded,
        color: AppColors.accent,
        routeName: AppRoutes.history,
        imageUrl: AppMedia.vetHero,
      ),
      const _DashboardFeature(
        title: 'Adopcion',
        description: 'Catalogo visual de mascotas disponibles para adopcion.',
        icon: Icons.favorite_rounded,
        color: AppColors.success,
        routeName: AppRoutes.adoption,
        imageUrl: AppMedia.adoptionHero,
      ),
    ];

    return FeaturePageScaffold(
      title: 'Inicio',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _heroCard(context),
          const SizedBox(height: 16),
          _modeBanner(context),
          const SizedBox(height: 16),
          _statsRow(context),
          const SizedBox(height: 16),
          Text(
            'Modulos principales',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _featureCard(context, item),
                ),
              )
              .toList(growable: false),
          const SizedBox(height: 6),
          Text(
            'Destacado de hoy',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _featuredPetCard(context),
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: NetworkImageCard(
        imageUrl: AppMedia.dashboardHero,
        height: 250,
        borderRadius: 28,
        showBorder: false,
        showShadow: true,
        overlayGradient: const LinearGradient(
          colors: [
            Color(0xCC2F605E),
            Color(0x991E3A8A),
            Color(0x331F2937),
          ],
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
                  'Inicio',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Todo lo importante de tus mascotas, en un solo lugar.',
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

  Widget _modeBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.info.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este inicio mezcla banner, resumen y accesos directos para que la app se sienta mas viva y util desde el primer vistazo.',
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

  Widget _statsRow(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _metricCard(context, 'Mascotas', '3', Icons.pets_rounded, AppColors.brand)),
            const SizedBox(width: 12),
            Expanded(child: _metricCard(context, 'Citas', '1', Icons.calendar_month_rounded, AppColors.warning)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metricCard(context, 'Historial', '12', Icons.description_rounded, AppColors.accent)),
            const SizedBox(width: 12),
            Expanded(child: _metricCard(context, 'Adopcion', '4', Icons.favorite_rounded, AppColors.success)),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(height: 12),
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

  Widget _featureCard(BuildContext context, _DashboardFeature feature) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: feature.routeName == null ? null : () => Navigator.of(context).pushNamed(feature.routeName!),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceStrong,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(feature.icon, color: feature.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feature.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      feature.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              NetworkImageCard(
                imageUrl: feature.imageUrl,
                height: 56,
                width: 56,
                borderRadius: 16,
                showBorder: false,
                showShadow: false,
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredPetCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.adoption),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: NetworkImageCard(
            imageUrl: AppMedia.adoptionHero,
            height: 190,
            borderRadius: 24,
            showBorder: false,
            overlayGradient: const LinearGradient(
              colors: [
                Color(0xAA000000),
                Color(0x22000000),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            foreground: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Historias y adopciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Explora mascotas con una presentacion mas visual y emotiva.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardFeature {
  const _DashboardFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.routeName,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? routeName;
  final String imageUrl;
}
