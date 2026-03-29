import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/core/widgets/feature_placeholder_page.dart';

class AdoptionPage extends StatelessWidget {
  const AdoptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Adopcion',
      subtitle:
          'Catalogo de mascotas disponibles para adopcion con su informacion principal.',
      icon: Icons.favorite_rounded,
      highlights: <String>[
        'Listado de mascotas en adopcion',
        'Ficha visual y filtros basicos',
        'Solicitud o contacto para adopcion',
      ],
    );
  }
}
