import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/router/app_routes.dart';
import 'package:petsafe_movil_app/features/adoption/presentation/adoption_page.dart';
import 'package:petsafe_movil_app/features/appointments/presentation/appointments_page.dart';
import 'package:petsafe_movil_app/features/auth/presentation/login_page.dart';
import 'package:petsafe_movil_app/features/dashboard/presentation/dashboard_page.dart';
import 'package:petsafe_movil_app/features/history/presentation/history_page.dart';
import 'package:petsafe_movil_app/features/pets/presentation/pets_page.dart';
import 'package:petsafe_movil_app/features/profile/presentation/profile_page.dart';
import 'package:petsafe_movil_app/features/reminders/presentation/reminders_page.dart';
import 'package:petsafe_movil_app/features/shell/presentation/home_shell.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.login => const LoginPage(),
      AppRoutes.shell => const HomeShell(),
      AppRoutes.dashboard => const DashboardPage(),
      AppRoutes.pets => const PetsPage(),
      AppRoutes.appointments => const AppointmentsPage(),
      AppRoutes.history => const HistoryPage(),
      AppRoutes.reminders => const RemindersPage(),
      AppRoutes.adoption => const AdoptionPage(),
      AppRoutes.profile => const ProfilePage(),
      _ => const LoginPage(),
    };

    return MaterialPageRoute<void>(
      builder: (_) => page,
      settings: settings,
    );
  }
}

