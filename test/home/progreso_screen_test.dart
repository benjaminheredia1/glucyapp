import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/mediciones/medicion_api.dart';
import 'package:glucy_app/home/progreso_screen.dart';

class MedicionApiFalsa implements MedicionApi {
  MedicionApiFalsa({this.devueltas = const []});

  List<Medicion> devueltas;

  @override
  Future<List<Medicion>> recientes({int cantidad = 7}) async => devueltas;

  @override
  Future<Medicion> registrar({required double valor, required String momento, String? nota}) =>
      throw UnimplementedError();
}

Medicion _m(int id, double valor, DateTime cuando) =>
    Medicion(id: id, valor: valor, momento: 'ayunas', medidoEn: cuando);

Future<void> montar(WidgetTester tester, MedicionApiFalsa api) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [medicionApiProvider.overrideWithValue(api)],
      child: const MaterialApp(home: ProgresoScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('promedio, tiempo en rango y numero de mediciones salen de los datos', (tester) async {
    final ahora = DateTime.now();
    // 4 mediciones en 30 dias: 3 en rango (<= 130), 1 alta. Promedio 129.
    await montar(
      tester,
      MedicionApiFalsa(devueltas: [
        _m(4, 126, ahora),
        _m(3, 110, ahora.subtract(const Duration(days: 1))),
        _m(2, 130, ahora.subtract(const Duration(days: 2))),
        _m(1, 150, ahora.subtract(const Duration(days: 20))),
      ]),
    );

    expect(find.textContaining('129 ', findRichText: true), findsOneWidget);
    expect(find.textContaining('75 %', findRichText: true), findsOneWidget);
    expect(find.textContaining('4 mediciones'), findsOneWidget);
    // Los porcentajes fijos de la maqueta ya no aparecen.
    expect(find.textContaining('78%'), findsNothing);
    expect(find.textContaining('11%'), findsNothing);
  });

  testWidgets('el rango de 7 dias deja fuera las mediciones viejas', (tester) async {
    final ahora = DateTime.now();
    await montar(
      tester,
      MedicionApiFalsa(devueltas: [
        _m(2, 120, ahora),
        _m(1, 180, ahora.subtract(const Duration(days: 20))),
      ]),
    );

    await tester.tap(find.text('7 días'));
    await tester.pumpAndSettle();

    expect(find.textContaining('120 ', findRichText: true), findsOneWidget);
    expect(find.textContaining('1 medición'), findsOneWidget);
  });

  testWidgets('sin mediciones en el rango lo dice, sin reventar', (tester) async {
    await montar(tester, MedicionApiFalsa());

    expect(find.textContaining('Sin mediciones'), findsOneWidget);
  });
}
