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
const _anonimo = Usuario(id: 1, name: 'Paciente', rol: Rol.paciente, esTemporal: true);

class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso({this.almacenada, this.alIniciar});

  Usuario? almacenada;
  Usuario? alIniciar;
  Object? errorAlRestaurar;
  Object? errorAlIniciar;
  Object? errorAnonimo;
  bool? ultimoReclamar;
  int altasAnonimas = 0;
  int cierres = 0;

  @override
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async {
    ultimoReclamar = reclamar;
    if (errorAlIniciar != null) throw errorAlIniciar!;

    return alIniciar ?? _maria;
  }

  @override
  Future<Usuario> entrarComoAnonimo() async {
    altasAnonimas++;
    if (errorAnonimo != null) throw errorAnonimo!;

    return _anonimo;
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

  test('entrarComoAnonimo pasa a autenticado temporal', () async {
    final c = contenedor(AuthRepositoryFalso());
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).entrarComoAnonimo();

    final sesion = c.read(sesionControllerProvider).value;
    expect(sesion, isA<SesionAutenticado>());
    expect((sesion as SesionAutenticado).usuario.esTemporal, isTrue);
  });

  test('un fallo al entrar como anonimo deja el estado en error', () async {
    final c = contenedor(AuthRepositoryFalso()..errorAnonimo = const FalloLimite(Duration(seconds: 30)));
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).entrarComoAnonimo();

    expect(c.read(sesionControllerProvider).hasError, isTrue);
  });

  test('iniciarSesion reclama por defecto y respeta reclamar: false', () async {
    final repo = AuthRepositoryFalso();
    final c = contenedor(repo);
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).iniciarSesion();
    expect(repo.ultimoReclamar, isTrue);

    await c.read(sesionControllerProvider.notifier).iniciarSesion(reclamar: false);
    expect(repo.ultimoReclamar, isFalse);
  });

  test('cancelar Auth0 desde una sesion temporal la conserva, no vuelve a noAutenticado', () async {
    final repo = AuthRepositoryFalso(almacenada: _anonimo)..errorAlIniciar = const Auth0Cancelado();
    final c = contenedor(repo);
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).iniciarSesion();

    final sesion = c.read(sesionControllerProvider).value;
    expect(sesion, isA<SesionAutenticado>());
    expect((sesion as SesionAutenticado).usuario.esTemporal, isTrue);
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
