import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/core/widgets/feature_placeholder_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Historial',
      subtitle:
          'Muestra el historial clinico disponible y habilita la exportacion a PDF.',
      icon: Icons.description_rounded,
      highlights: <String>[
        'Consultas, tratamientos y procedimientos',
        'Vacunas, desparasitaciones y cirugias',
        'Exportacion y comparticion en PDF',
      ],
    );
  }
}
