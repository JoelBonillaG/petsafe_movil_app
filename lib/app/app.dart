import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/router/app_router.dart';
import 'package:petsafe_movil_app/app/router/app_routes.dart';
import 'package:petsafe_movil_app/app/theme/app_theme.dart';

class PetSafeApp extends StatelessWidget {
  const PetSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetSafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
