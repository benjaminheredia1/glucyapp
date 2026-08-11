import 'package:dio/dio.dart';

import '../storage/token_store.dart';

/// Devuelve un token de Sanctum fresco, o `null` si ya no hay forma de
/// renovar la sesion.
typedef Renovador = Future<String?> Function();

/// Adjunta el Bearer y, ante un 401, renueva **una sola vez** y reintenta.
///
/// Es un `QueuedInterceptor` a proposito: con varias peticiones en vuelo, un
/// `Interceptor` normal dispararia una renovacion por cada 401.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStore store,
    required Renovador renovar,
    HttpClientAdapter? transporte,
  })  : _store = store,
        _renovar = renovar,
        _transporte = transporte;

  static const _marcaReintento = 'glucy.reintentado';

  final TokenStore _store;
  final Renovador _renovar;

  /// El adaptador HTTP del cliente que nos instala (no sus interceptors).
  /// Sin esto, el `Dio` desnudo del reintento abre su propia conexion real:
  /// en produccion da igual, pero en los tests el adaptador simulado solo
  /// esta enchufado al `Dio` original, y el reintento acaba en "conexion
  /// rechazada" en vez de llegar a la respuesta simulada.
  final HttpClientAdapter? _transporte;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _store.leer();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final esSesionCaducada = err.response?.statusCode == 401;
    final yaReintentado = err.requestOptions.extra[_marcaReintento] == true;

    // Un 403 no se renueva: el token vale, lo que falta es alcance.
    if (!esSesionCaducada || yaReintentado) {
      handler.next(err);

      return;
    }

    final token = await _renovar();

    if (token == null) {
      await _store.borrar();
      handler.next(err);

      return;
    }

    final peticion = err.requestOptions
      ..extra[_marcaReintento] = true
      ..headers['Authorization'] = 'Bearer $token';

    try {
      // Dio desnudo a proposito: reenviar por `dio` volveria a entrar en
      // esta misma cola de interceptores. Si ese segundo intento tambien
      // fallara, quedaria encolado detras de este mismo `onError` (que
      // todavia no ha terminado) dentro de la `_errorQueue` de dio: un
      // interbloqueo, no solo un reintento de mas.
      final clienteReintento = Dio(
        BaseOptions(
          baseUrl: peticion.baseUrl,
          connectTimeout: peticion.connectTimeout,
          receiveTimeout: peticion.receiveTimeout,
        ),
      );

      if (_transporte != null) {
        clienteReintento.httpClientAdapter = _transporte;
      }

      final respuesta = await clienteReintento.fetch<dynamic>(peticion);

      handler.resolve(respuesta);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
