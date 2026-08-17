import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/mediciones/medicion_api.dart';
import 'package:glucy_app/home/home_screen.dart';

const _maria = Usuario(id: 7, name: 'Maria', email: 'maria@ejemplo.com', rol: Rol.paciente);

class AuthRepositoryFalso implements AuthRepository {
  @override
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async => _maria;

  @override
  Future<Usuario> entrarComoAnonimo() async => throw UnimplementedError();

  @override
  Future<Usuario?> restaurarSesion() async => _maria;

  @override
  Future<void> cerrarSesion() async {}
}

class MedicionApiFalsa implements MedicionApi {
  MedicionApiFalsa({this.devueltas = const [], this.error});

  List<Medicion> devueltas;
  Object? error;

  @override
  Future<List<Medicion>> recientes({int cantidad = 7}) async {
    if (error != null) throw error!;
    return devueltas;
  }

  @override
  Future<Medicion> registrar({required double valor, required String momento, String? nota}) =>
      throw UnimplementedError();
}

Medicion _m(int id, double valor, DateTime cuando, {String momento = 'ayunas'}) =>
    Medicion(id: id, valor: valor, momento: momento, medidoEn: cuando);

Future<void> montar(WidgetTester tester, MedicionApiFalsa api) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(AuthRepositoryFalso()),
        medicionApiProvider.overrideWithValue(api),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pinta la ultima medicion real, su momento y "En rango"', (tester) async {
    final ahora = DateTime.now();
    final api = MedicionApiFalsa(devueltas: [
      // Como la API: descendente por medidoEn.
      _m(3, 124, ahora, momento: 'postprandial'),
      _m(2, 132, ahora.subtract(const Duration(days: 1))),
      _m(1, 166, ahora.subtract(const Duration(days: 2))),
    ]);

    await montar(tester, api);

    expect(find.textContaining('124 ', findRichText: true), findsOneWidget);
    expect(find.textContaining('2 h después'), findsOneWidget);
    expect(find.text('En rango'), findsOneWidget);
    // Los valores fijos de la maqueta ya no aparecen.
    expect(find.textContaining('08:10'), findsNothing);
  });

  testWidgets('una ultima medicion alta se marca como "Alto"', (tester) async {
    await montar(tester, MedicionApiFalsa(devueltas: [_m(1, 158, DateTime.now())]));

    expect(find.text('Alto'), findsOneWidget);
    expect(find.text('En rango'), findsNothing);
  });

  testWidgets('sin mediciones invita a registrar la primera', (tester) async {
    await montar(tester, MedicionApiFalsa());

    expect(find.textContaining('primera medición'), findsOneWidget);
    expect(find.text('En rango'), findsNothing);
  });

  testWidgets('un fallo de red se muestra y deja reintentar', (tester) async {
    final api = MedicionApiFalsa(error: const FalloRed());
    await montar(tester, api);

    expect(find.textContaining('No hay conexion con el servidor.'), findsOneWidget);

    api.error = null;
    api.devueltas = [_m(1, 120, DateTime.now())];
    await tester.tap(find.byKey(const Key('reintentar-mediciones')));
    await tester.pumpAndSettle();

    expect(find.textContaining('120 ', findRichText: true), findsOneWidget);
  });
}
