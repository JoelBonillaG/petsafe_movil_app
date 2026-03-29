import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/core/widgets/feature_placeholder_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Perfil',
      subtitle:
          'Configura tu cuenta, preferencias y datos del propietario o tutor.',
      icon: Icons.person_rounded,
      highlights: <String>[
        'Datos del usuario y su perfil',
        'Cierre de sesion y preferencias',
        'Accesos a ayuda y soporte',
      ],
    );
  }
}
