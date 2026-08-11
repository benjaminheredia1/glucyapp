import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/app/router/glucy_router.dart';
import 'package:glucy_app/app/router/rutas.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:go_router/go_router.dart';

class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso(this.almacenada);

  final Usuario? almacenada;

  @override
  Future<Usuario> iniciarSesion() async => almacenada!;

  @override
  Future<Usuario?> restaurarSesion() async => almacenada;

  @override
  Future<void> cerrarSesion() async {}
}

Usuario usuarioCon(Rol rol) => Usuario(id: 1, name: 'X', email: 'x@ejemplo.com', rol: rol);

Future<GoRouter> montar(WidgetTester tester, Usuario? almacenada) async {
  final contenedor = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(AuthRepositoryFalso(almacenada))],
  );
  addTearDown(contenedor.dispose);

  final router = contenedor.read(glucyRouterProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: contenedor,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  return router;
}

String rutaActual(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

void main() {
  testWidgets('sin sesion aterriza en el embudo publico', (tester) async {
    final router = await montar(tester, null);

    expect(rutaActual(router), Rutas.onboarding);
  });

  testWidgets('un paciente autenticado aterriza en su inicio', (tester) async {
    final router = await montar(tester, usuarioCon(Rol.paciente));

    expect(rutaActual(router), Rutas.inicioPaciente);
  });

  testWidgets('un doctor autenticado aterriza en el portal medico', (tester) async {
    final router = await montar(tester, usuarioCon(Rol.doctor));

    expect(rutaActual(router), Rutas.inicioMedico);
  });

  testWidgets('un admin aterriza en el portal medico', (tester) async {
    final router = await montar(tester, usuarioCon(Rol.admin));

    expect(rutaActual(router), Rutas.inicioMedico);
  });

  testWidgets('un paciente no puede entrar al portal medico', (tester) async {
    final router = await montar(tester, usuarioCon(Rol.paciente));

    router.go(Rutas.inicioMedico);
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.inicioPaciente);
  });

  testWidgets('un autenticado que va al login vuelve a su inicio', (tester) async {
    final router = await montar(tester, usuarioCon(Rol.paciente));

    router.go(Rutas.login);
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.inicioPaciente);
  });

  testWidgets('sin sesion, el inicio de paciente redirige al login', (tester) async {
    final router = await montar(tester, null);

    router.go(Rutas.inicioPaciente);
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.login);
  });

  testWidgets('sin sesion, el filtro clinico si es alcanzable', (tester) async {
    final router = await montar(tester, null);

    router.go(Rutas.filtroClinico);
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.filtroClinico);
  });
}
