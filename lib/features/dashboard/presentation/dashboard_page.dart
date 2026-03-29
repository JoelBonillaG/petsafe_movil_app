import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/core/widgets/feature_placeholder_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Inicio',
      subtitle:
          'Resumen rapido de mascotas, citas, historial y recordatorios futuros.',
      icon: Icons.dashboard_rounded,
      highlights: <String>[
        'Accesos rapidos a las funciones principales',
        'Estados resumidos de citas y recordatorios',
        'Entrada visual para adopcion y novedades',
      ],
    );
  }
}
