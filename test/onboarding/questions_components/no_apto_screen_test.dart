import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/onboarding/questions_components/no_apto_screen.dart';

void main() {
  Widget envolver(Widget child) => MaterialApp(home: child);

  testWidgets('sin recap, oculta la seccion "LO QUE YA REGISTRASTE" en vez de mostrarla vacia', (tester) async {
    await tester.pumpWidget(envolver(const NoAptoScreen(reason: 'embarazo', recap: [])));

    expect(find.text('LO QUE YA REGISTRASTE'), findsNothing);
  });

  testWidgets('con recap, muestra la seccion y cada item', (tester) async {
    await tester.pumpWidget(envolver(const NoAptoScreen(
      reason: 'embarazo',
      recap: [NoAptoRecapItem('Edad', '29 años'), NoAptoRecapItem('IMC', '31.2')],
    )));

    expect(find.text('LO QUE YA REGISTRASTE'), findsOneWidget);
    expect(find.text('Edad'), findsOneWidget);
    expect(find.text('29 años'), findsOneWidget);
    expect(find.text('IMC'), findsOneWidget);
    expect(find.text('31.2'), findsOneWidget);
  });
}
