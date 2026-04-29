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
        description: 'Accede al perfil completo de tus mascotas.',
        icon: Icons.pets_rounded,
        color: AppColors.brand,
        routeName: AppRoutes.pets,
        imageUrl: AppMedia.dogHeroOne,
      ),
      const _DashboardFeature(
        title: 'Citas',
        description: 'Organiza la atencion de tu mascota sin complicaciones.',
        icon: Icons.calendar_month_rounded,
        color: AppColors.warning,
        routeName: AppRoutes.appointments,
        imageUrl: AppMedia.clinicHero,
      ),
      const _DashboardFeature(
        title: 'Historial',
        description: 'Consulta y gestiona todos los registros clinicos desde un solo lugar.',
        icon: Icons.description_rounded,
        color: AppColors.accent,
        routeName: AppRoutes.history,
        imageUrl: AppMedia.historyHero,
      ),
      const _DashboardFeature(
        title: 'Adopcion',
        description: 'Descubre mascotas en busca de hogar y encuentra tu companero ideal.',
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
