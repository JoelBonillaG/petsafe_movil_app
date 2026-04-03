import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/router/app_routes.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_repository_factory.dart';

enum _GlobalHeaderMenuAction {
  profile,
  signOut,
}

List<Widget> buildGlobalHeaderActions(BuildContext context) {
  return <Widget>[
    IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Luego abriremos tu centro de notificaciones.')),
        );
      },
      icon: const Icon(Icons.notifications_none_rounded),
      tooltip: 'Notificaciones',
    ),
    PopupMenuButton<_GlobalHeaderMenuAction>(
      tooltip: 'Opciones de perfil',
      onSelected: (action) => _handleGlobalHeaderAction(context, action),
      itemBuilder: (menuContext) => const [
        PopupMenuItem<_GlobalHeaderMenuAction>(
          value: _GlobalHeaderMenuAction.profile,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_rounded),
            title: Text('Configurar perfil'),
          ),
        ),
        PopupMenuItem<_GlobalHeaderMenuAction>(
          value: _GlobalHeaderMenuAction.signOut,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, color: AppColors.warning),
            title: Text('Cerrar sesion'),
          ),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: UserInitialsAvatar(
          fullName: 'Joel Bonilla',
          size: 36,
          showShadow: false,
        ),
      ),
    ),
    const SizedBox(width: 8),
  ];
}

Future<void> _handleGlobalHeaderAction(
  BuildContext context,
  _GlobalHeaderMenuAction action,
) async {
  switch (action) {
    case _GlobalHeaderMenuAction.profile:
      Navigator.of(context).pushNamed(AppRoutes.profile);
      return;
    case _GlobalHeaderMenuAction.signOut:
      final repository = await AuthRepositoryFactory.create();
      await repository.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
  }
}
