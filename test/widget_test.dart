import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_app/main.dart';
import 'package:math_app/state/app_state.dart';

void main() {
  testWidgets('Login page is shown when no usuario ha iniciado sesión', (
    tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.initialize();

    await tester.pumpWidget(MathApp(appState: appState));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });
}
