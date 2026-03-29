import 'package:petsafe_movil_app/app/app.dart';
import 'package:petsafe_movil_app/core/bootstrap/app_bootstrap.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await AppBootstrap.initialize();
  runApp(const PetSafeApp());
}
