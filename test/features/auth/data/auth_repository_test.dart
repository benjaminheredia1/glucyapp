import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/data/auth0_gateway.dart';
import 'package:glucy_app/features/auth/data/auth_api.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/data/dto/respuesta_sesion.dart';
import 'package:glucy_app/features/auth/data/renovador_sesion.dart';
import 'package:glucy_app/features/auth/data/usuario_api.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';

import '../../../core/network/auth_interceptor_test.dart' show TokenStoreFalso;

const _maria = Usuario(id: 7, name: 'Maria', email: 'maria@ejemplo.com', rol: Rol.paciente);

class Auth0GatewayFalso implements Auth0Gateway {
  Auth0GatewayFalso({this.tokenLogin = 'auth0-nuevo', this.tokenVigente = 'auth0-vigente'});

  String? tokenLogin;
  String? tokenVigente;
  int cierres = 0;
  Object? errorAlIniciar;

  @override
  Future<String> iniciarSesion() async {
    if (errorAlIniciar != null) throw errorAlIniciar!;

    return tokenLogin!;
  }

  @override
  Future<String?> accessTokenVigente() async => tokenVigente;

  @override
  Future<void> cerrarSesion() async => cierres++;
}

class AuthApiFalsa implements AuthApi {
  AuthApiFalsa({this.token = 'sanctum-nuevo'});

  String token;
  Object? error;
  int llamadas = 0;
  String? ultimoAccessToken;

  @override
  Future<RespuestaSesion> intercambiar(String accessToken, {String dispositivo = 'api'}) async {
    llamadas++;
    ultimoAccessToken = accessToken;
    if (error != null) throw error!;

    return RespuestaSesion(token: token, usuario: _maria);
  }
}

class UsuarioApiFalsa implements UsuarioApi {
  Object? error;
  int cierres = 0;

  @override
  Future<Usuario> actual() async {
    if (error != null) throw error!;

    return _maria;
  }

  @override
  Future<void> cerrarSesion() async => cierres++;
}

void main() {
  late Auth0GatewayFalso gateway;
  late AuthApiFalsa authApi;
  late UsuarioApiFalsa usuarioApi;
  late TokenStoreFalso store;
  late AuthRepository repo;

  setUp(() {
    gateway = Auth0GatewayFalso();
    authApi = AuthApiFalsa();
    usuarioApi = UsuarioApiFalsa();
    store = TokenStoreFalso();
    repo = AuthRepository(
      gateway: gateway,
      authApi: authApi,
      usuarioApi: usuarioApi,
      store: store,
    );
  });

  group('iniciarSesion', () {
    test('canjea el token de Auth0 y guarda el de Sanctum', () async {
      final usuario = await repo.iniciarSesion();

      expect(usuario, _maria);
      expect(authApi.ultimoAccessToken, 'auth0-nuevo');
      expect(await store.leer(), 'sanctum-nuevo');
    });

    test('si el intercambio falla, no deja token guardado', () async {
      authApi.error = const FalloServidor();

      await expectLater(repo.iniciarSesion(), throwsA(isA<FalloServidor>()));

      expect(await store.leer(), isNull);
    });

    test('propaga la cancelacion del usuario', () async {
      gateway.errorAlIniciar = const Auth0Cancelado();

      await expectLater(repo.iniciarSesion(), throwsA(isA<Auth0Cancelado>()));
    });
  });

  group('restaurarSesion', () {
    test('sin token guardado devuelve null y no llama a la API', () async {
      expect(await repo.restaurarSesion(), isNull);
    });

    test('con token guardado devuelve el usuario', () async {
      await store.guardar('sanctum-viejo');

      expect(await repo.restaurarSesion(), _maria);
    });

    test('si la API responde 401, borra el token y devuelve null', () async {
      await store.guardar('sanctum-muerto');
      usuarioApi.error = const FalloAuth();

      expect(await repo.restaurarSesion(), isNull);
      expect(await store.leer(), isNull);
    });

    test('un fallo de red no borra el token: la sesion puede seguir viva', () async {
      await store.guardar('sanctum-vivo');
      usuarioApi.error = const FalloRed();

      await expectLater(repo.restaurarSesion(), throwsA(isA<FalloRed>()));

      expect(await store.leer(), 'sanctum-vivo');
    });
  });

  group('cerrarSesion', () {
    test('revoca en el servidor, borra el token y cierra en Auth0', () async {
      await store.guardar('sanctum-vivo');

      await repo.cerrarSesion();

      expect(usuarioApi.cierres, 1);
      expect(gateway.cierres, 1);
      expect(await store.leer(), isNull);
    });

    test('borra el token local aunque el servidor falle', () async {
      await store.guardar('sanctum-vivo');
      usuarioApi.error = const FalloServidor();

      await repo.cerrarSesion();

      expect(await store.leer(), isNull);
      expect(gateway.cierres, 1);
    });
  });

  group('RenovadorSesion', () {
    test('devuelve el token nuevo y lo guarda', () async {
      final renovador = RenovadorSesion(gateway: gateway, authApi: authApi, store: store);

      expect(await renovador.renovar(), 'sanctum-nuevo');
      expect(await store.leer(), 'sanctum-nuevo');
    });

    test('devuelve null si Auth0 ya no tiene credenciales', () async {
      gateway.tokenVigente = null;
      final renovador = RenovadorSesion(gateway: gateway, authApi: authApi, store: store);

      expect(await renovador.renovar(), isNull);
      expect(authApi.llamadas, 0);
    });

    test('devuelve null si el intercambio falla, en vez de propagar', () async {
      authApi.error = const FalloAuth();
      final renovador = RenovadorSesion(gateway: gateway, authApi: authApi, store: store);

      expect(await renovador.renovar(), isNull);
    });
  });
}
