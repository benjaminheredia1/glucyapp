import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/data/auth0_gateway.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/sesion.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/auth/presentation/sesion_controller.dart';
import 'package:glucy_app/features/precalificacion/data/embudo_store.dart';
import 'package:glucy_app/features/precalificacion/data/precalificacion_repository.dart';
import 'package:glucy_app/features/precalificacion/data/vinculador_precalificacion.dart';
import 'package:glucy_app/features/precalificacion/domain/pregunta_filtro.dart';
import 'package:glucy_app/features/precalificacion/domain/veredicto.dart';

const _maria = Usuario(id: 7, name: 'Maria', email: 'maria@ejemplo.com', rol: Rol.paciente);

class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso({this.almacenada, this.alIniciar});

  Usuario? almacenada;
  Usuario? alIniciar;
  Object? errorAlRestaurar;
  Object? errorAlIniciar;
  int cierres = 0;

  @override
  Future<Usuario> iniciarSesion() async {
    if (errorAlIniciar != null) throw errorAlIniciar!;

    return alIniciar ?? _maria;
  }

  @override
  Future<Usuario?> restaurarSesion() async {
    if (errorAlRestaurar != null) throw errorAlRestaurar!;

    return almacenada;
  }

  @override
  Future<void> cerrarSesion() async {
    cierres++;
    almacenada = null;
  }
}

/// Repo/store minimos, solo para satisfacer los tipos que pide el
/// constructor de `VinculadorPrecalificacion`: esta suite es de
/// `SesionController`, no de vinculacion, asi que a estos dobles no se les
/// pide que hagan nada util.
class _RepoInerte implements PrecalificacionRepository {
  @override
  Future<List<PreguntaFiltro>> preguntas() async => const [];

  @override
  Future<Veredicto> evaluar(Map<int, bool> respuestas, {String? leadEmail}) async =>
      throw UnimplementedError();

  @override
  Future<void> vincular(int precalificacionId) async {}
}

class _StoreInerte implements EmbudoStore {
  @override
  Future<void> guardarProgreso(Map<int, bool> respuestas) async {}

  @override
  Future<Map<int, bool>> leerProgreso() async => {};

  @override
  Future<void> guardarPrecalificacion(int id) async {}

  @override
  Future<int?> leerPrecalificacion() async => null;

  @override
  Future<void> limpiar() async {}
}

/// Doble por defecto: sin id pendiente, `vincularPendiente()` no hace nada.
/// Sin esto, `contenedor()` deja el `vinculadorPrecalificacionProvider` real
/// sin sobrescribir, y su cadena de dependencias (`precalificacionRepositoryProvider`
/// -> ... -> `appConfigProvider`) revienta con `UnimplementedError` al no
/// estar sobrescrita en esta suite -- Task 17 solo sobrevivia a esto porque
/// `VinculadorPrecalificacion.vincularPendiente()` atrapa cualquier fallo, no
/// porque el entorno de prueba estuviera realmente configurado.
VinculadorPrecalificacion _vinculadorInerte() =>
    VinculadorPrecalificacion(repo: _RepoInerte(), store: _StoreInerte());

/// Para probar que `SesionController.iniciarSesion()` se blinda por su
/// cuenta (Fix 3 del review): ni siquiera un fallo que escape por completo
/// del propio `VinculadorPrecalificacion` (aqui, sobreescribiendo
/// `vincularPendiente()` para que lance algo que no sea `FalloApi`) puede
/// pisar el estado de sesion ya autenticada.
class VinculadorPrecalificacionQueFalla extends VinculadorPrecalificacion {
  VinculadorPrecalificacionQueFalla() : super(repo: _RepoInerte(), store: _StoreInerte());

  @override
  Future<void> vincularPendiente() async => throw StateError('fallo inesperado, no FalloApi');
}

ProviderContainer contenedor(AuthRepositoryFalso repo, {VinculadorPrecalificacion? vinculador}) {
  final c = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      vinculadorPrecalificacionProvider.overrideWithValue(vinculador ?? _vinculadorInerte()),
    ],
  );
  addTearDown(c.dispose);

  return c;
}

void main() {
  test('sin sesion guardada arranca en noAutenticado', () async {
    final c = contenedor(AuthRepositoryFalso());

    final sesion = await c.read(sesionControllerProvider.future);

    expect(sesion, isA<SesionNoAutenticado>());
  });

  test('con sesion guardada arranca autenticado', () async {
    final c = contenedor(AuthRepositoryFalso(almacenada: _maria));

    final sesion = await c.read(sesionControllerProvider.future);

    expect(sesion, isA<SesionAutenticado>());
    expect((sesion as SesionAutenticado).usuario, _maria);
  });

  test('un fallo de red al restaurar deja el estado en error', () async {
    final repo = AuthRepositoryFalso()..errorAlRestaurar = const FalloRed();
    final c = contenedor(repo);

    await expectLater(c.read(sesionControllerProvider.future), throwsA(isA<FalloRed>()));
    expect(c.read(sesionControllerProvider).hasError, isTrue);
  });

  test('iniciarSesion pasa a autenticado', () async {
    final c = contenedor(AuthRepositoryFalso());
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).iniciarSesion();

    expect(c.read(sesionControllerProvider).value, isA<SesionAutenticado>());
  });

  test('un fallo inesperado al vincular la precalificacion no tumba la sesion', () async {
    final c = contenedor(AuthRepositoryFalso(), vinculador: VinculadorPrecalificacionQueFalla());
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).iniciarSesion();

    final sesion = c.read(sesionControllerProvider);
    expect(sesion.value, isA<SesionAutenticado>());
    expect(sesion.hasError, isFalse);
  });

  test('una cancelacion de Auth0 vuelve a noAutenticado sin error', () async {
    final repo = AuthRepositoryFalso()..errorAlIniciar = const Auth0Cancelado();
    final c = contenedor(repo);
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).iniciarSesion();

    final estado = c.read(sesionControllerProvider);
    expect(estado.hasError, isFalse);
    expect(estado.value, isA<SesionNoAutenticado>());
  });

  test('un fallo del servidor al iniciar deja el estado en error', () async {
    final repo = AuthRepositoryFalso()..errorAlIniciar = const FalloServidor();
    final c = contenedor(repo);
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).iniciarSesion();

    expect(c.read(sesionControllerProvider).hasError, isTrue);
  });

  test('cerrarSesion vuelve a noAutenticado', () async {
    final repo = AuthRepositoryFalso(almacenada: _maria);
    final c = contenedor(repo);
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).cerrarSesion();

    expect(c.read(sesionControllerProvider).value, isA<SesionNoAutenticado>());
    expect(repo.cierres, 1);
  });
}
