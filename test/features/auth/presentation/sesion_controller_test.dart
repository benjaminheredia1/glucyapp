import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/data/auth0_gateway.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/sesion.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/auth/presentation/sesion_controller.dart';

const _maria = Usuario(id: 7, name: 'Maria', email: 'maria@ejemplo.com', rol: Rol.paciente);

class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso({this.almacenada, this.alIniciar});

  Usuario? almacenada;
  Usuario? alIniciar;
  Object? errorAlRestaurar;
  Object? errorAlIniciar;
  int cierres = 0;

  @override
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async {
    if (errorAlIniciar != null) throw errorAlIniciar!;

    return alIniciar ?? _maria;
  }

  @override
  Future<Usuario> entrarComoAnonimo() async => throw UnimplementedError();

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

ProviderContainer contenedor(AuthRepositoryFalso repo) {
  final c = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
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
