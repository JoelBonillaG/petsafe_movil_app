import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petsafe_movil_app/app/app.dart';

void main() {
  testWidgets('shows the login screen on start', (WidgetTester tester) async {
    await tester.pumpWidget(const PetSafeApp());
    await tester.pumpAndSettle();

    expect(find.text('PetSafe'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
