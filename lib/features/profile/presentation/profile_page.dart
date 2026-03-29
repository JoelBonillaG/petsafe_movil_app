import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/router/app_routes.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/constants/app_media.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_repository_factory.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            onPressed: () => _showProfileActions(context),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _heroCard(context),
          const SizedBox(height: 16),
          _accountCard(context),
          const SizedBox(height: 16),
          Text('Mascotas vinculadas', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: const [
                SizedBox(width: 4),
                _PetMiniCard(
                  name: 'Luna',
                  subtitle: 'Tu companera principal',
                  imageUrl: AppMedia.dogHeroOne,
                  accent: AppColors.brand,
                ),
                SizedBox(width: 12),
                _PetMiniCard(
                  name: 'Mia',
                  subtitle: 'Control y vacunas al dia',
                  imageUrl: AppMedia.catHeroOne,
                  accent: AppColors.accent,
                ),
                SizedBox(width: 12),
                _PetMiniCard(
                  name: 'Rocky',
                  subtitle: 'Historial y seguimiento',
                  imageUrl: AppMedia.dogHeroTwo,
                  accent: AppColors.success,
                ),
                SizedBox(width: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Accesos rapidos', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          _QuickActionTile(
            icon: Icons.person_rounded,
            title: 'Datos del usuario',
            subtitle: 'Nombre, correo, telefono y documento de identidad.',
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            icon: Icons.lock_rounded,
            title: 'Seguridad',
            subtitle: 'Cambiar contrasena, cerrar sesiones y reactivar acceso.',
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            icon: Icons.notifications_active_rounded,
            title: 'Preferencias',
            subtitle: 'Alertas, idioma, notificaciones y recordatorios.',
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            icon: Icons.support_agent_rounded,
            title: 'Ayuda y soporte',
            subtitle: 'Canales de soporte, preguntas frecuentes y contacto.',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesion'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showProfileActions(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editar perfil'),
                ),
              ),
            ],
          ),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          NetworkImageCard(
            imageUrl: AppMedia.ownerHero,
            height: 220,
            borderRadius: 28,
            showShadow: false,
            showBorder: false,
            overlayGradient: const LinearGradient(
              colors: [
                Color(0xCC2F605E),
                Color(0x881E3A8A),
                Color(0x112F605E),
              ],
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Text(
                          'Tu cuenta',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _showProfileActions(context),
                        child: const NetworkAvatar(
                          imageUrl: AppMedia.profileHero,
                          size: 74,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Joel',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Propietario principal y tutor registrado',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: _pill(
              icon: Icons.verified_rounded,
              label: 'Perfil activo',
              background: Colors.white.withOpacity(0.18),
              foreground: Colors.white,
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Row(
              children: [
                _glassStat('3', 'Mascotas'),
                const SizedBox(width: 10),
                _glassStat('1', 'Cita'),
                const SizedBox(width: 10),
                _glassStat('12', 'Eventos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.activeSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.badge_rounded, color: AppColors.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mi cuenta', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Acceso rapido a los datos personales, seguridad y soporte.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
            children: const [
              _InfoChip(icon: Icons.email_rounded, label: 'joel@petsafe.com'),
              _InfoChip(icon: Icons.phone_rounded, label: '+593 9XX XXX XXX'),
              _InfoChip(icon: Icons.location_on_rounded, label: 'Guayaquil, EC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showProfileActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.activeSoft,
                    child: Icon(Icons.settings_rounded, color: AppColors.brand),
                  ),
                  title: const Text('Configurar perfil'),
                  subtitle: const Text('Ajusta tus datos, foto y preferencias'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Luego abriremos la pantalla de configuracion.')),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.warningBg,
                    child: Icon(Icons.logout_rounded, color: AppColors.warning),
                  ),
                  title: const Text('Cerrar sesion'),
                  subtitle: const Text('Salir de la cuenta actual'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _signOut(context);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.infoBg,
                    child: Icon(Icons.support_agent_rounded, color: AppColors.info),
                  ),
                  title: const Text('Ayuda y soporte'),
                  subtitle: const Text('Preguntas frecuentes y contacto'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aun no conectamos el centro de ayuda.')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final repository = await AuthRepositoryFactory.create();
    await repository.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.brand),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.activeSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _PetMiniCard extends StatelessWidget {
  const _PetMiniCard({
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.accent,
  });

  final String name;
  final String subtitle;
  final String imageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkImageCard(
            imageUrl: imageUrl,
            height: 78,
            borderRadius: 18,
            showShadow: false,
            showBorder: false,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
