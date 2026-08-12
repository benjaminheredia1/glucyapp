import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/onboarding/questions_components/analisis_screen.dart';

void main() {
  testWidgets('renderiza sin overflow en el lienzo de 390x844 del diseno', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AnalisisScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra los 5 sistemas, el valor por valor y la confianza del analisis', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AnalisisScreen()));

    expect(find.text('Detalle del análisis'), findsOneWidget);
    expect(find.text('Glucémico'), findsOneWidget);
    expect(find.text('Sobre meta'), findsOneWidget);
    expect(find.text('Confirmado'), findsOneWidget);
    expect(find.text('158 mg/dL'), findsOneWidget);
    expect(find.text('7.4 %'), findsOneWidget);
    expect(find.text('142 mg/dL'), findsOneWidget);
    expect(find.text('92 %'), findsOneWidget);
  });

  testWidgets('el boton "Volver a mi pre-diagnostico" cierra la pantalla', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalisisScreen())),
          child: const Text('abrir'),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle del análisis'), findsOneWidget);

    await tester.tap(find.text('Volver a mi pre-diagnóstico'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle del análisis'), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
  });
}
