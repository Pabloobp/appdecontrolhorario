// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:control_horario/main.dart';

void main() {
  testWidgets('Muestra pantalla base de control horario', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ControlHorarioApp());

    expect(find.text('Control Horario'), findsOneWidget);
    expect(find.text('Registro simple, claro y rápido'), findsOneWidget);
  });
}
