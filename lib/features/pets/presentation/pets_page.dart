import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/core/widgets/feature_placeholder_page.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Mascotas',
      subtitle:
          'Aqui se mostrara la informacion principal de cada mascota y su QR de identificacion.',
      icon: Icons.pets_rounded,
      highlights: <String>[
        'Ficha general de la mascota',
        'Codigo QR de identificacion',
        'Datos clinicos basicos y relaciones con su tutor',
      ],
    );
  }
}
