import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/planes/plan_api.dart';
import 'package:glucy_app/onboarding/questions_components/checkout_screen.dart';
import 'package:glucy_app/onboarding/questions_components/diag_pend_screen.dart';

/// Sin planes publicados la pantalla usa sus textos por defecto, que es lo
/// que estas pruebas verifican.
class PlanApiVacio implements PlanApi {
  @override
  Future<List<Plan>> disponibles() async => [];
}

Widget _app() => ProviderScope(
      overrides: [planApiProvider.overrideWithValue(PlanApiVacio())],
      child: const MaterialApp(home: CheckoutScreen()),
    );

void main() {
  testWidgets('renderiza sin overflow en el lienzo de 390x844 del diseno', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra el precio, la linea de tiempo de 13 dias y el pago por QR', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('Iniciar mi tratamiento'), findsOneWidget);
    expect(find.text('12 días gratis'), findsOneWidget);
    expect(find.textContaining('USD 0'), findsOneWidget);
    expect(find.text('Tus próximos 13 días'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Día 13'), findsOneWidget);
    expect(find.text('Pago por QR'), findsOneWidget);
    expect(find.text('Bancos y billeteras'), findsOneWidget);
    expect(find.textContaining('no hay cobro nunca'), findsOneWidget);
  });

  testWidgets('empezar la prueba lleva a la pantalla de revision medica', (tester) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Empezar mis 12 días gratis'));
    await tester.pumpAndSettle();

    expect(find.byType(DiagPendScreen), findsOneWidget);
  });

  testWidgets('con plan publicado muestra su precio y dias de prueba', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [planApiProvider.overrideWithValue(_PlanApiConPlan())],
      child: const MaterialApp(home: CheckoutScreen()),
    ));
    await tester.pump();

    expect(find.text('30 días gratis'), findsOneWidget);
    expect(find.textContaining('BOB 199'), findsOneWidget);
    expect(find.text('Empezar mis 30 días gratis'), findsOneWidget);
  });
}

class _PlanApiConPlan implements PlanApi {
  @override
  Future<List<Plan>> disponibles() async => const [
        Plan(id: 1, nombre: 'Glucy Mensual', precio: 199, moneda: 'BOB', periodicidad: 'mensual', diasPrueba: 30),
      ];
}
