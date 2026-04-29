import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/core/widgets/feature_placeholder_page.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Recordatorios',
      subtitle:
          'Centraliza los avisos automaticos de citas, vacunas y controles futuros.',
      icon: Icons.notifications_active_rounded,
      highlights: <String>[
        'Proximas citas y seguimientos',
        'Vacunas y desparasitaciones pendientes',
        'Notificaciones push y alertas in-app',
      ],
    );
  }
}
