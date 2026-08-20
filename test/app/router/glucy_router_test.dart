import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/app/router/glucy_router.dart';
import 'package:glucy_app/app/router/rutas.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/auth/presentation/sesion_controller.dart';
import 'package:glucy_app/features/precalificacion/data/embudo_store.dart';
import 'package:glucy_app/features/precalificacion/data/precalificacion_repository.dart';
import 'package:glucy_app/features/precalificacion/domain/pregunta_filtro.dart';
import 'package:glucy_app/features/precalificacion/domain/veredicto.dart';
import 'package:glucy_app/shared/widgets/mensaje_error.dart';
import 'package:glucy_app/onboarding/questions_components/crear_cuenta_screen.dart';
import 'package:glucy_app/onboarding/questions_components/filtro1_screen.dart';
import 'package:go_router/go_router.dart';

class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso(this.almacenada);

  final Usuario? almacenada;
  Object? errorAnonimo;
  int altasAnonimas = 0;

  @override
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async => almacenada!;

  @override
  Future<Usuario> entrarComoAnonimo() async {
    altasAnonimas++;
    if (errorAnonimo != null) throw errorAnonimo!;

    return _anonima;
  }

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
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async => alIniciar!;

  @override
  Future<Usuario> entrarComoAnonimo() async => throw UnimplementedError();

  @override
  Future<Usuario?> restaurarSesion() async => almacenada;

  @override
  Future<void> cerrarSesion() async {
    almacenada = null;
  }
}

/// Fix 1 del review final: `iniciarSesion()` pone `AsyncLoading` durante todo
/// el viaje a Universal Login, que en la app real dura segundos porque el
/// usuario esta en un navegador. Para atrapar al router en pleno vuelo (antes
/// de que Auth0 conteste) hace falta una promesa que de verdad no resuelva,
/// no un delay corto: un `Future.delayed` se resolveria solo con
/// `pumpAndSettle`, y este test necesita justo lo contrario, un solo frame.
class AuthRepositoryQueNuncaResuelveAlIniciar implements AuthRepository {
  final Completer<Usuario> _pendiente = Completer<Usuario>();

  @override
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) => _pendiente.future;

  @override
  Future<Usuario> entrarComoAnonimo() async => throw UnimplementedError();

  @override
  Future<Usuario?> restaurarSesion() async => null;

  @override
  Future<void> cerrarSesion() async {}
}

Usuario usuarioCon(Rol rol) => Usuario(id: 1, name: 'X', email: 'x@ejemplo.com', rol: rol);

const _anonima = Usuario(id: 1, name: 'Paciente', rol: Rol.paciente, esTemporal: true);

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
  Future<Veredicto> evaluar(Map<int, bool> respuestas) async =>
      Veredicto(id: 1, resultado: resultado, motivo: resultado == Resultado.apto ? null : 'motivo de prueba');
}

/// El controlador del filtro tambien lee `embudoStoreProvider` al montarse
/// (para borrar el cache legado): sin este doble, el real pega a
/// flutter_secure_storage y `pumpAndSettle` cuelga esperando una respuesta de
/// un canal de plataforma que no existe en el test.
class EmbudoStoreFalso implements EmbudoStore {
  @override
  Future<void> limpiar() async {}
}

Future<GoRouter> montar(
  WidgetTester tester,
  Usuario? almacenada, {
  PrecalificacionRepository? precalificacion,
  AuthRepositoryFalso? auth,
}) async {
  final contenedor = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth ?? AuthRepositoryFalso(almacenada)),
      precalificacionRepositoryProvider.overrideWithValue(
        precalificacion ?? PrecalificacionRepositoryFalso(),
      ),
      embudoStoreProvider.overrideWithValue(EmbudoStoreFalso()),
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

  testWidgets('Empezar sin sesion crea la identidad anonima y va a tu perfil', (tester) async {
    final repo = AuthRepositoryFalso(null);
    final router = await montar(tester, null, auth: repo);
    expect(rutaActual(router), Rutas.onboarding);

    await tester.ensureVisible(find.text('Empezar es gratis'));
    await tester.tap(find.text('Empezar es gratis'));
    await tester.pumpAndSettle();

    expect(repo.altasAnonimas, 1);
    expect(rutaActual(router), Rutas.perfil);
  });

  testWidgets('Empezar con sesion temporal ya creada va directo a tu perfil', (tester) async {
    final repo = AuthRepositoryFalso(_anonima);
    final router = await montar(tester, _anonima, auth: repo);

    await tester.ensureVisible(find.text('Empezar es gratis'));
    await tester.tap(find.text('Empezar es gratis'));
    await tester.pumpAndSettle();

    expect(repo.altasAnonimas, 0);
    expect(rutaActual(router), Rutas.perfil);
  });

  testWidgets('si crear la identidad falla, onboarding muestra el error y no navega', (tester) async {
    final repo = AuthRepositoryFalso(null)..errorAnonimo = const FalloLimite(Duration(seconds: 30));
    final router = await montar(tester, null, auth: repo);

    await tester.ensureVisible(find.text('Empezar es gratis'));
    await tester.tap(find.text('Empezar es gratis'));
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.onboarding);
    expect(find.byType(MensajeError), findsOneWidget);
  });

  testWidgets('una identidad temporal aterriza en onboarding, no en inicio', (tester) async {
    final router = await montar(tester, _anonima);

    expect(rutaActual(router), Rutas.onboarding);
  });

  testWidgets('una identidad temporal que va a inicio vuelve a onboarding', (tester) async {
    final router = await montar(tester, _anonima);

    router.go(Rutas.inicioPaciente);
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.onboarding);
  });

  testWidgets('una identidad temporal puede entrar a tu perfil, filtro clinico y crear cuenta', (tester) async {
    final router = await montar(tester, _anonima);

    for (final ruta in [Rutas.perfil, Rutas.filtroClinico, Rutas.crearCuenta]) {
      router.go(ruta);
      await tester.pumpAndSettle();
      expect(rutaActual(router), ruta, reason: ruta);
    }
  });

  testWidgets('sin sesion, tu perfil es alcanzable (ruta publica)', (tester) async {
    final router = await montar(tester, null);

    router.go(Rutas.perfil);
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.perfil);
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
  // Segun el prototipo (Glucy AI .html, `submitPrecal`), apto sigue a
  // "Filtro 1 OK" y de ahi a los estudios; la cuenta se crea recien despues
  // del pre-diagnostico (pantalla 14), no al salir del filtro clinico.
  testWidgets('el veredicto apto navega a filtro 1 OK, no a crear cuenta', (tester) async {
    final router = await montar(
      tester,
      null,
      precalificacion: PrecalificacionRepositoryFalso(resultado: Resultado.apto),
    );

    await _completarFiltroClinico(tester, router);

    expect(find.byType(Filtro1Screen), findsOneWidget);
    expect(find.byType(CrearCuentaScreen), findsNothing);
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

  // Fix 3 del review final: se llega a /no-apto por context.go(...) desde el
  // filtro clinico (unica entrada real), asi que esta pantalla queda sola en
  // el stack de go_router. Antes del fix, la flecha de volver llamaba a
  // Navigator.of(context).pop() a secas y GoRouter lanzaba
  // GoError('There is nothing to pop'), exactamente el mismo bug que
  // clinical_filter_widget.dart ya habia arreglado con context.canPop().
  testWidgets('la flecha de volver en no-apto no revienta un stack vacio', (tester) async {
    final router = await montar(
      tester,
      null,
      precalificacion: PrecalificacionRepositoryFalso(resultado: Resultado.noApto),
    );

    await _completarFiltroClinico(tester, router);
    expect(rutaActual(router), Rutas.noApto);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(rutaActual(router), Rutas.onboarding);
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

  // Fix 1 del review final: antes de este fix, el redirect mandaba al splash
  // en cuanto `sesionControllerProvider` entraba en `AsyncLoading`, sin
  // distinguir el arranque en frio de un `iniciarSesion()` en marcha. Con
  // sesion ya resuelta (aqui, `noAutenticado`), tocar "Entrar o crear cuenta"
  // pone el estado en loading otra vez, pero como ya hay un valor previo
  // (`hasValue` sigue en true) el usuario tiene que seguir viendo el login,
  // no el splash: solo asi el spinner y el `MensajeError` de la Task 13/14
  // llegan a pintarse alguna vez.
  testWidgets('iniciarSesion en marcha no saca de la pantalla de login', (tester) async {
    final repo = AuthRepositoryQueNuncaResuelveAlIniciar();
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

    router.go(Rutas.login);
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.login);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    // Un solo frame, no pumpAndSettle: `iniciarSesion()` nunca resuelve en
    // este doble, asi que pumpAndSettle se colgaria esperando algo que no
    // va a llegar. Esta es justo la ventana (un frame tras el tap, con Auth0
    // todavia sin abrirse) donde vivia el bug original.
    await tester.pump();

    expect(rutaActual(router), Rutas.login);
  });
}
