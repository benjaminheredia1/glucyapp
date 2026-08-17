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
import 'package:glucy_app/features/precalificacion/data/embudo_store.dart';

import '../../../core/network/auth_interceptor_test.dart' show TokenStoreFalso;

const _maria = Usuario(id: 7, name: 'Maria', email: 'maria@ejemplo.com', rol: Rol.paciente);
const _anonimo = Usuario(id: 1, name: 'Paciente', rol: Rol.paciente, esTemporal: true);

class Auth0GatewayFalso implements Auth0Gateway {
  Auth0GatewayFalso({this.tokenLogin = 'auth0-nuevo', this.tokenVigente = 'auth0-vigente'});

  String? tokenLogin;
  String? tokenVigente;
  int cierres = 0;
  Object? errorAlIniciar;

  @override
  Future<String> iniciarSesion({String? conexion}) async {
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
  // Fallo solo en la primera llamada CON Bearer anonimo, para probar el
  // reintento sin Bearer.
  Object? errorConBearer;
  int llamadas = 0;
  int altasAnonimas = 0;
  String? ultimoAccessToken;
  String? ultimoTokenAnonimo;
  final List<String?> bearersEnviados = [];

  @override
  Future<RespuestaSesion> anonimo({String dispositivo = 'api'}) async {
    altasAnonimas++;
    if (error != null) throw error!;
    return RespuestaSesion(token: '1|anon', usuario: _anonimo);
  }

  @override
  Future<RespuestaSesion> intercambiar(
    String accessToken, {
    String dispositivo = 'api',
    String? tokenAnonimo,
  }) async {
    llamadas++;
    ultimoAccessToken = accessToken;
    ultimoTokenAnonimo = tokenAnonimo;
    bearersEnviados.add(tokenAnonimo);
    if (tokenAnonimo != null && errorConBearer != null) throw errorConBearer!;
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

class EmbudoStoreFalso implements EmbudoStore {
  int limpiezas = 0;

  @override
  Future<void> guardarProgreso(Map<int, bool> respuestas) async {}

  @override
  Future<Map<int, bool>> leerProgreso() async => {};

  @override
  Future<void> limpiar() async => limpiezas++;
}

void main() {
  late Auth0GatewayFalso gateway;
  late AuthApiFalsa authApi;
  late UsuarioApiFalsa usuarioApi;
  late TokenStoreFalso store;
  late EmbudoStoreFalso embudo;
  late AuthRepository repo;

  setUp(() {
    gateway = Auth0GatewayFalso();
    authApi = AuthApiFalsa();
    usuarioApi = UsuarioApiFalsa();
    store = TokenStoreFalso();
    embudo = EmbudoStoreFalso();
    repo = AuthRepository(
      gateway: gateway,
      authApi: authApi,
      usuarioApi: usuarioApi,
      store: store,
      embudo: embudo,
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

  group('entrarComoAnonimo', () {
    test('crea la identidad, guarda su token y devuelve el usuario temporal', () async {
      final usuario = await repo.entrarComoAnonimo();

      expect(usuario.esTemporal, isTrue);
      expect(authApi.altasAnonimas, 1);
      expect(await store.leer(), '1|anon');
    });

    test('si la API falla, no deja token guardado', () async {
      authApi.error = const FalloLimite(Duration(seconds: 30));

      await expectLater(repo.entrarComoAnonimo(), throwsA(isA<FalloLimite>()));
      expect(await store.leer(), isNull);
    });
  });

  group('iniciarSesion reclamando la identidad anonima', () {
    test('con token guardado lo manda como Bearer y lo sustituye por el real', () async {
      await store.guardar('1|anon');

      final usuario = await repo.iniciarSesion();

      expect(usuario, _maria);
      expect(authApi.ultimoTokenAnonimo, '1|anon');
      expect(await store.leer(), 'sanctum-nuevo');
    });

    test('sin token guardado no manda Bearer', () async {
      await repo.iniciarSesion();

      expect(authApi.ultimoTokenAnonimo, isNull);
    });

    test('reclamar: false nunca manda Bearer aunque haya token', () async {
      await store.guardar('1|anon');

      await repo.iniciarSesion(reclamar: false);

      expect(authApi.ultimoTokenAnonimo, isNull);
      expect(await store.leer(), 'sanctum-nuevo');
    });

    test('un 409 se propaga como FalloConflicto y conserva el token anonimo', () async {
      await store.guardar('1|anon');
      authApi.errorConBearer = const FalloConflicto('Ya existe una cuenta con este correo.');

      await expectLater(repo.iniciarSesion(), throwsA(isA<FalloConflicto>()));
      expect(await store.leer(), '1|anon');
      expect(authApi.llamadas, 1);
    });

    test('un 401 con Bearer anonimo borra el token y reintenta sin Bearer una vez', () async {
      await store.guardar('1|anon-muerto');
      authApi.errorConBearer = const FalloAuth('El token de la sesion no es valido.');

      final usuario = await repo.iniciarSesion();

      expect(usuario, _maria);
      expect(authApi.bearersEnviados, ['1|anon-muerto', null]);
      expect(await store.leer(), 'sanctum-nuevo');
    });

    test('un 401 sin Bearer anonimo (Auth0 invalido) se propaga sin reintentar', () async {
      authApi.error = const FalloAuth('Access token de Auth0 invalido.');

      await expectLater(repo.iniciarSesion(), throwsA(isA<FalloAuth>()));
      expect(authApi.llamadas, 1);
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

    // Fix 2 del review final: sin esto, las respuestas del filtro clinico
    // (guardadas en EmbudoStore, vease embudo_store.dart) sobrevivian a un
    // cierre de sesion explicito y se le mostrarian a la siguiente persona
    // que abriera el filtro en el mismo dispositivo.
    test('limpia el embudo local', () async {
      await repo.cerrarSesion();

      expect(embudo.limpiezas, 1);
    });

    test('limpia el embudo incluso si el servidor falla', () async {
      usuarioApi.error = const FalloServidor();

      await repo.cerrarSesion();

      expect(embudo.limpiezas, 1);
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

    test('devuelve null si escapa algo que no es FalloApi, en vez de colgar la peticion', () async {
      // Un `TypeError` al parsear una respuesta malformada, o un
      // `PlatformException` del keystore al guardar, no son `FalloApi`.
      // `AuthInterceptor` llama a `renovar()` sin su propio try/catch: si
      // esto escapara, la peticion original nunca se resolveria.
      authApi.error = StateError('respuesta malformada');
      final renovador = RenovadorSesion(gateway: gateway, authApi: authApi, store: store);

      expect(await renovador.renovar(), isNull);
    });
  });
}
