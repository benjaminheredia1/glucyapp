import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/core/network/error_interceptor.dart';
import 'package:glucy_app/features/auth/data/auth_api.dart';
import 'package:glucy_app/features/auth/data/usuario_api.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adaptador;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
    adaptador = DioAdapter(dio: dio);
    dio.interceptors.add(ErrorInterceptor());
  });

  Map<String, dynamic> usuarioJson({String rol = 'paciente'}) => {
        'id': 7,
        'name': 'Maria',
        'apellidoPaterno': 'Torres',
        'email': 'maria@ejemplo.com',
        'rol': rol,
        'email_verified_at': '2026-08-09T10:00:00.000000Z',
      };

  group('AuthApi.intercambiar', () {
    test('devuelve el token y el usuario', () async {
      adaptador.onPost(
        '/auth/auth0',
        (servidor) => servidor.reply(200, {'token': 'sanctum-123', 'usuario': usuarioJson()}),
        data: {'accessToken': 'auth0-abc', 'dispositivo': 'android-1'},
      );

      final respuesta = await AuthApi(dio).intercambiar('auth0-abc', dispositivo: 'android-1');

      expect(respuesta.token, 'sanctum-123');
      expect(respuesta.usuario.id, 7);
      expect(respuesta.usuario.email, 'maria@ejemplo.com');
      expect(respuesta.usuario.rol, Rol.paciente);
      expect(respuesta.usuario.apellidoPaterno, 'Torres');
      expect(respuesta.usuario.emailVerificadoEn, isNotNull);
    });

    test('lee el rol de doctor', () async {
      adaptador.onPost(
        '/auth/auth0',
        (servidor) => servidor.reply(200, {
          'token': 'sanctum-123',
          'usuario': usuarioJson(rol: 'doctor'),
        }),
        data: {'accessToken': 'auth0-abc', 'dispositivo': 'api'},
      );

      final respuesta = await AuthApi(dio).intercambiar('auth0-abc');

      expect(respuesta.usuario.rol, Rol.doctor);
    });

    test('un 401 se propaga como FalloAuth', () async {
      adaptador.onPost(
        '/auth/auth0',
        (servidor) => servidor.reply(401, {'message': 'Access token de Auth0 invalido.'}),
        data: {'accessToken': 'basura', 'dispositivo': 'api'},
      );

      await expectLater(
        AuthApi(dio).intercambiar('basura'),
        throwsA(isA<FalloAuth>()),
      );
    });

    test('un 503 se propaga como FalloServidor', () async {
      adaptador.onPost(
        '/auth/auth0',
        (servidor) => servidor.reply(503, {'message': 'El proveedor de identidad no esta disponible.'}),
        data: {'accessToken': 'auth0-abc', 'dispositivo': 'api'},
      );

      await expectLater(
        AuthApi(dio).intercambiar('auth0-abc'),
        throwsA(isA<FalloServidor>()),
      );
    });
  });

  group('AuthApi.anonimo', () {
    test('crea la identidad temporal y devuelve token y usuario', () async {
      adaptador.onPost(
        '/auth/anonimo',
        (servidor) => servidor.reply(201, {
          'token': '1|anon-abc',
          'usuario': {'id': 1, 'name': 'Paciente', 'email': null, 'rol': 'paciente', 'esTemporal': true},
        }),
        data: {'dispositivo': 'android-1'},
      );

      final respuesta = await AuthApi(dio).anonimo(dispositivo: 'android-1');

      expect(respuesta.token, '1|anon-abc');
      expect(respuesta.usuario.esTemporal, isTrue);
      expect(respuesta.usuario.email, isNull);
    });

    test('un 429 se propaga como FalloLimite', () async {
      adaptador.onPost(
        '/auth/anonimo',
        (servidor) => servidor.reply(429, {'message': 'Too Many Attempts.'}),
        data: {'dispositivo': 'api'},
      );

      await expectLater(AuthApi(dio).anonimo(), throwsA(isA<FalloLimite>()));
    });
  });

  group('AuthApi.intercambiar con identidad anonima', () {
    test('manda el Bearer anonimo cuando se le pasa', () async {
      adaptador.onPost(
        '/auth/auth0',
        (servidor) => servidor.reply(200, {'token': 'sanctum-real', 'usuario': usuarioJson()}),
        data: {'accessToken': 'auth0-abc', 'dispositivo': 'api'},
        headers: {'Authorization': 'Bearer 1|anon-abc'},
      );

      final respuesta = await AuthApi(dio).intercambiar('auth0-abc', tokenAnonimo: '1|anon-abc');

      expect(respuesta.token, 'sanctum-real');
    });

    test('un 409 se propaga como FalloConflicto', () async {
      adaptador.onPost(
        '/auth/auth0',
        (servidor) => servidor.reply(409, {'message': 'Ya existe una cuenta con este correo. Inicia sesion con ella.'}),
        data: {'accessToken': 'auth0-abc', 'dispositivo': 'api'},
        headers: {'Authorization': 'Bearer 1|anon-abc'},
      );

      await expectLater(
        AuthApi(dio).intercambiar('auth0-abc', tokenAnonimo: '1|anon-abc'),
        throwsA(isA<FalloConflicto>()),
      );
    });
  });

  group('UsuarioApi', () {
    test('actual() devuelve el usuario de la sesion', () async {
      adaptador.onGet('/user', (servidor) => servidor.reply(200, usuarioJson()));

      final usuario = await UsuarioApi(dio).actual();

      expect(usuario.id, 7);
      expect(usuario.rol, Rol.paciente);
    });

    test('actual() lee esTemporal y tolera email null (identidad anonima)', () async {
      adaptador.onGet(
        '/user',
        (servidor) => servidor.reply(200, {
          'id': 1,
          'name': 'Paciente',
          'email': null,
          'auth0Sub': null,
          'rol': 'paciente',
          'esTemporal': true,
        }),
      );

      final usuario = await UsuarioApi(dio).actual();

      expect(usuario.esTemporal, isTrue);
      expect(usuario.email, isNull);
    });

    test('actual() sin esTemporal en el JSON asume cuenta real', () async {
      adaptador.onGet('/user', (servidor) => servidor.reply(200, usuarioJson()));

      expect((await UsuarioApi(dio).actual()).esTemporal, isFalse);
    });

    test('actual() propaga FalloAuth si la sesion murio', () async {
      adaptador.onGet('/user', (servidor) => servidor.reply(401, {'message': 'Unauthenticated.'}));

      await expectLater(UsuarioApi(dio).actual(), throwsA(isA<FalloAuth>()));
    });

    test('cerrarSesion() acepta el 204', () async {
      adaptador.onPost('/auth/logout', (servidor) => servidor.reply(204, null), data: null);

      await expectLater(UsuarioApi(dio).cerrarSesion(), completes);
    });
  });
}
