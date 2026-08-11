import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/app/router/glucy_router.dart';
import 'package:glucy_app/app/router/rutas.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/auth/presentation/sesion_controller.dart';
import 'package:glucy_app/features/precalificacion/data/precalificacion_repository.dart';
import 'package:glucy_app/features/precalificacion/domain/pregunta_filtro.dart';
import 'package:glucy_app/features/precalificacion/domain/veredicto.dart';
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

/// A diferencia de `AuthRepositoryFalso`, distingue lo que ya habia guardado
/// de lo que devuelve un `iniciarSesion()` posterior: hace falta para probar
/// que el router rerutea una app ya montada, no solo en el primer build.
class AuthRepositoryDinamica implements AuthRepository {
  AuthRepositoryDinamica({this.almacenada, this.alIniciar});

  Usuario? almacenada;
  Usuario? alIniciar;

  @override
  Future<Usuario> iniciarSesion() async => alIniciar!;

  @override
  Future<Usuario?> restaurarSesion() async => almacenada;

  @override
  Future<void> cerrarSesion() async {
    almacenada = null;
  }
}

Usuario usuarioCon(Rol rol) => Usuario(id: 1, name: 'X', email: 'x@ejemplo.com', rol: rol);

/// El filtro clinico (Task 15) pide sus preguntas al montarse. Sin este fake,
/// `router.go(Rutas.filtroClinico)` dispara una llamada real a traves de
/// `appConfigProvider`, que este archivo no sobrescribe: este test solo
/// verifica que la ruta es alcanzable, no el contenido de la pantalla.
///
/// `resultado` es configurable para las pruebas de "el veredicto rutea al
/// destino correcto": traen una sola pregunta (para poder responderla y
/// habilitar el envio) y `evaluar()` siempre devuelve ese `resultado`.
class PrecalificacionRepositoryFalso implements PrecalificacionRepository {
  PrecalificacionRepositoryFalso({this.resultado = Resultado.apto});

  final Resultado resultado;

  @override
  Future<List<PreguntaFiltro>> preguntas() async =>
      const [PreguntaFiltro(id: 1, codigo: 'q1', texto: 'Pregunta de prueba', orden: 1, version: 1)];

  @override
  Future<Veredicto> evaluar(Map<int, bool> respuestas, {String? leadEmail}) async =>
      Veredicto(id: 1, resultado: resultado, motivo: resultado == Resultado.apto ? null : 'motivo de prueba');

  @override
  Future<void> vincular(int precalificacionId) async {}
}

Future<GoRouter> montar(
  WidgetTester tester,
  Usuario? almacenada, {
  PrecalificacionRepository? precalificacion,
}) async {
  final contenedor = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(AuthRepositoryFalso(almacenada)),
      precalificacionRepositoryProvider.overrideWithValue(
        precalificacion ?? PrecalificacionRepositoryFalso(),
      ),
    ],
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

/// Abre el filtro clinico, responde la unica pregunta del fake y toca "Ver mi
/// resultado". Deja al router en el destino que le corresponda al
/// `Resultado` configurado en `PrecalificacionRepositoryFalso`.
Future<void> _completarFiltroClinico(WidgetTester tester, GoRouter router) async {
  router.go(Rutas.filtroClinico);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Sí'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Ver mi resultado'));
  await tester.pumpAndSettle();
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

  // El unico sitio donde vive el switch `Resultado -> ruta` (Task 15). Sin
  // estas pruebas, cambiar por ejemplo `Resultado.urgente` para que rutee a
  // `Rutas.noApto` compilaria igual y el resto de la suite seguiria en
  // verde: nada mas ejercita las tres ramas.
  testWidgets('el veredicto apto navega a crear cuenta', (tester) async {
    final router = await montar(
      tester,
      null,
      precalificacion: PrecalificacionRepositoryFalso(resultado: Resultado.apto),
    );

    await _completarFiltroClinico(tester, router);

    expect(rutaActual(router), Rutas.crearCuenta);
  });

  testWidgets('el veredicto urgente navega a la pantalla de urgencia', (tester) async {
    final router = await montar(
      tester,
      null,
      precalificacion: PrecalificacionRepositoryFalso(resultado: Resultado.urgente),
    );

    await _completarFiltroClinico(tester, router);

    expect(rutaActual(router), Rutas.urgencia);
  });

  testWidgets('el veredicto no_apto navega a la pantalla de no apto', (tester) async {
    final router = await montar(
      tester,
      null,
      precalificacion: PrecalificacionRepositoryFalso(resultado: Resultado.noApto),
    );

    await _completarFiltroClinico(tester, router);

    expect(rutaActual(router), Rutas.noApto);
  });

  // Las pruebas de arriba mueven el router con router.go(...) o dejan que el
  // timer del splash llame a context.go(...): ambas rutas re-ejecutan
  // redirect por la navegacion normal de go_router, no por el
  // refreshListenable. Estas dos prueban lo unico que de verdad ejercita
  // _NotificadorSesion: cambiar el estado del propio sesionControllerProvider
  // con la app ya montada, sin tocar el router para nada.
  testWidgets('iniciar sesion en una app ya montada rerutea sin remount', (tester) async {
    final repo = AuthRepositoryDinamica(alIniciar: usuarioCon(Rol.paciente));
    final contenedor = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
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

    expect(rutaActual(router), Rutas.onboarding);

    await contenedor.read(sesionControllerProvider.notifier).iniciarSesion();
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.inicioPaciente);
  });

  testWidgets('cerrar sesion en una app ya montada rerutea sin remount', (tester) async {
    final repo = AuthRepositoryDinamica(almacenada: usuarioCon(Rol.paciente));
    final contenedor = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
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

    expect(rutaActual(router), Rutas.inicioPaciente);

    await contenedor.read(sesionControllerProvider.notifier).cerrarSesion();
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.login);
  });
}
