import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/core/widgets/feature_placeholder_page.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Citas',
      subtitle:
          'Permite solicitar citas medicas y revisar si el veterinario las confirma o rechaza.',
      icon: Icons.calendar_month_rounded,
      highlights: <String>[
        'Solicitud de cita desde la app',
        'Seguimiento del estado de la cita',
        'Horarios, motivos y notas de la atencion',
      ],
    );
  }
}
