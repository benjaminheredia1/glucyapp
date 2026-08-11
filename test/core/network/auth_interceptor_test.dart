import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/core/network/auth_interceptor.dart';
import 'package:glucy_app/core/network/error_interceptor.dart';
import 'package:glucy_app/core/storage/token_store.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Almacen en memoria: los tests no tocan el Keychain.
class TokenStoreFalso implements TokenStore {
  TokenStoreFalso([this._token]);

  String? _token;
  int borrados = 0;

  @override
  Future<String?> leer() async => _token;

  @override
  Future<void> guardar(String token) async => _token = token;

  @override
  Future<void> borrar() async {
    borrados++;
    _token = null;
  }
}

void main() {
  late Dio dio;
  late DioAdapter adaptador;
  late TokenStoreFalso store;
  late int renovaciones;
  late String? tokenRenovado;

  void montar({String? tokenInicial}) {
    renovaciones = 0;
    tokenRenovado = 'token-nuevo';
    store = TokenStoreFalso(tokenInicial);
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
    adaptador = DioAdapter(dio: dio);
    dio.interceptors.addAll([
      AuthInterceptor(
        store: store,
        renovar: () async {
          renovaciones++;
          if (tokenRenovado != null) await store.guardar(tokenRenovado!);
          return tokenRenovado;
        },
        // El reintento usa un Dio desnudo (ver auth_interceptor.dart); sin
        // compartir aqui el adaptador simulado, ese segundo intento saldria
        // a la red de verdad y fallaria con "conexion rechazada".
        transporte: dio.httpClientAdapter,
      ),
      ErrorInterceptor(),
    ]);
  }

  test('adjunta el Bearer cuando hay token guardado', () async {
    montar(tokenInicial: 'token-viejo');
    adaptador.onGet('/user', (servidor) => servidor.reply(200, {'id': 1}));

    final respuesta = await dio.get<dynamic>('/user');

    expect(respuesta.requestOptions.headers['Authorization'], 'Bearer token-viejo');
  });

  test('no adjunta cabecera si no hay token', () async {
    montar();
    adaptador.onGet('/user', (servidor) => servidor.reply(200, {'id': 1}));

    final respuesta = await dio.get<dynamic>('/user');

    expect(respuesta.requestOptions.headers.containsKey('Authorization'), isFalse);
  });

  test('un 401 renueva una vez y reintenta con el token nuevo', () async {
    montar(tokenInicial: 'token-viejo');
    adaptador
      ..onGet('/user', (servidor) => servidor.reply(401, {'message': 'Unauthenticated.'}),
          headers: {'Authorization': 'Bearer token-viejo'})
      ..onGet('/user', (servidor) => servidor.reply(200, {'id': 7}),
          headers: {'Authorization': 'Bearer token-nuevo'});

    final respuesta = await dio.get<dynamic>('/user');

    expect(respuesta.statusCode, 200);
    expect(renovaciones, 1);
    expect(await store.leer(), 'token-nuevo');
  });

  test('si la renovacion falla, borra el token y propaga FalloAuth', () async {
    montar(tokenInicial: 'token-viejo');
    tokenRenovado = null;
    adaptador.onGet('/user', (servidor) => servidor.reply(401, {'message': 'Unauthenticated.'}));

    await expectLater(
      dio.get<dynamic>('/user'),
      throwsA(isA<DioException>().having((e) => e.error, 'error', isA<FalloAuth>())),
    );

    expect(renovaciones, 1);
    expect(store.borrados, 1);
    expect(await store.leer(), isNull);
  });

  test('no reintenta dos veces: un 401 tras renovar se propaga', () async {
    montar(tokenInicial: 'token-viejo');
    adaptador.onGet('/user', (servidor) => servidor.reply(401, {'message': 'Unauthenticated.'}));

    await expectLater(
      dio.get<dynamic>('/user'),
      throwsA(isA<DioException>().having((e) => e.error, 'error', isA<FalloAuth>())),
    );

    expect(renovaciones, 1, reason: 'la segunda respuesta 401 no debe disparar otra renovacion');
  });

  test('un 500 no dispara renovacion', () async {
    montar(tokenInicial: 'token-viejo');
    adaptador.onGet('/user', (servidor) => servidor.reply(500, {'message': 'Boom'}));

    await expectLater(
      dio.get<dynamic>('/user'),
      throwsA(isA<DioException>().having((e) => e.error, 'error', isA<FalloServidor>())),
    );

    expect(renovaciones, 0);
  });

  test('un 403 no dispara renovacion: el token vale, falta alcance', () async {
    montar(tokenInicial: 'token-viejo');
    adaptador.onGet('/user', (servidor) => servidor.reply(403, {'message': 'No autorizado.'}));

    await expectLater(
      dio.get<dynamic>('/user'),
      throwsA(isA<DioException>().having((e) => e.error, 'error', isA<FalloAuth>())),
    );

    expect(renovaciones, 0);
  });
}
