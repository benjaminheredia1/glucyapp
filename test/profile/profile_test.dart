import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/app/router/rutas.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/perfil/perfil_api.dart';
import 'package:glucy_app/profile/profile.dart';
import 'package:go_router/go_router.dart';

const _anonima = Usuario(id: 1, name: 'Paciente', rol: Rol.paciente, esTemporal: true);

class PerfilApiFalsa implements PerfilApi {
  Object? error;
  Map<String, Object?>? ultimoPatch;

  @override
  Future<Perfil> obtener() async => const Perfil(usuario: _anonima);

  @override
  Future<Perfil> actualizar({
    String? name,
    String? apellidoPaterno,
    String? telefono,
    DateTime? fechaNacimiento,
    String? sexo,
    double? pesoKg,
    int? tallaCm,
  }) async {
    ultimoPatch = {
      'name': name,
      'apellidoPaterno': apellidoPaterno,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento,
      'sexo': sexo,
      'pesoKg': pesoKg,
      'tallaCm': tallaCm,
    };
    if (error != null) throw error!;

    return const Perfil(usuario: _anonima);
  }
}

Future<GoRouter> montar(WidgetTester tester, PerfilApiFalsa api) async {
  // La pantalla es alta: que quepa el boton inferior sin desbordar.
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: Rutas.perfil,
    routes: [
      GoRoute(path: Rutas.perfil, builder: (_, __) => const Profile()),
      GoRoute(path: Rutas.filtroClinico, builder: (_, __) => const Scaffold(body: Text('FILTRO'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [perfilApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  return router;
}

String rutaActual(GoRouter router) => router.routerDelegate.currentConfiguration.uri.path;

void main() {
  testWidgets('Continuar manda el PATCH con nombre, telefono, sexo, peso y talla y va al filtro', (tester) async {
    final api = PerfilApiFalsa();
    final router = await montar(tester, api);

    await tester.enterText(find.byKey(const Key('campo-nombre')), 'María Torres');
    await tester.enterText(find.byKey(const Key('campo-telefono')), '987654321');
    await tester.enterText(find.byKey(const Key('campo-peso')), '74');
    await tester.enterText(find.byKey(const Key('campo-talla')), '162');
    await tester.tap(find.byKey(const Key('campo-sexo')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Femenino').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar al filtro clínico'));
    await tester.pumpAndSettle();

    expect(api.ultimoPatch?['name'], 'María Torres');
    expect(api.ultimoPatch?['telefono'], '987654321');
    expect(api.ultimoPatch?['sexo'], 'femenino');
    expect(api.ultimoPatch?['pesoKg'], 74.0);
    expect(api.ultimoPatch?['tallaCm'], 162);
    expect(rutaActual(router), Rutas.filtroClinico);
  });

  testWidgets('los campos vacios no viajan en el PATCH', (tester) async {
    final api = PerfilApiFalsa();
    await montar(tester, api);

    await tester.tap(find.text('Continuar al filtro clínico'));
    await tester.pumpAndSettle();

    expect(api.ultimoPatch, isNotNull);
    expect(api.ultimoPatch!.values.every((v) => v == null), isTrue);
  });

  testWidgets('si el PATCH falla se queda en la pantalla y muestra el error', (tester) async {
    final api = PerfilApiFalsa()..error = const FalloServidor();
    final router = await montar(tester, api);

    await tester.tap(find.text('Continuar al filtro clínico'));
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.perfil);
    expect(find.textContaining('El servidor tuvo un problema.'), findsOneWidget);
  });
}
