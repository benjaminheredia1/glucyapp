import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_store.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Lo sobrescribe la Task 12 con la renovacion real. Por defecto, no hay forma
/// de renovar: un 401 cierra la sesion.
final renovadorProvider = Provider<Renovador>((ref) => () async => null);

BaseOptions _opciones(AppConfig config) => BaseOptions(
      baseUrl: config.apiBaseUrl.toString(),
      connectTimeout: config.timeout,
      receiveTimeout: config.timeout,
      sendTimeout: config.timeout,
      headers: const {'Accept': 'application/json'},
    );

// El cuerpo de la peticion nunca se loguea, ni redactado: `redactarParaLog`
// solo reconoce el JSON citado ("clave":"valor") que imprime el cuerpo de
// una RESPUESTA. `AuthApi.intercambiar` manda un `Map` de Dart como cuerpo de
// la peticion, y el logger de dio imprime un Map con su `.toString()`
// (`{accessToken: eyJ..., dispositivo: api}`, sin comillas), una forma que el
// regex no cubre: el access token de Auth0 se imprimiria en claro. Apagar
// `requestBody` cierra toda esa clase de fuga en vez de perseguir cada forma
// sin comillas que pueda producir un Map.
@visibleForTesting
LogInterceptor crearInterceptorLog() => LogInterceptor(
      request: false,
      requestHeader: false,
      requestBody: false,
      responseBody: true,
      logPrint: (linea) => debugPrint(redactarParaLog(linea.toString())),
    );

/// El log no puede filtrar credenciales ni en desarrollo.
///
/// `dioPublicoProvider` es quien hace el intercambio con Auth0, y esa
/// respuesta llega en snake_case (`access_token`, `refresh_token`,
/// `id_token`), no en el camelCase de esta app: si solo cubrieramos
/// `accessToken` el token de Auth0 se imprimiria en claro.
// `replaceAll(Pattern, String)` no expande `$1`: a diferencia de JS, Dart
// trata el reemplazo como texto literal. Hace falta `replaceAllMapped` para
// conservar el grupo capturado (el "Bearer " o el "clave":") y solo tapar
// el valor.
String _tapar(String linea, RegExp patron) =>
    linea.replaceAllMapped(patron, (m) => '${m[1]}<redactado>');

@visibleForTesting
String redactarParaLog(String linea) => _tapar(
      _tapar(linea, RegExp(r'(Bearer\s+)[\w\-\.|]+')),
      RegExp(
        r'("(?:password|token|accessToken|access_token|refresh_token|id_token)"\s*:\s*")[^"]*',
      ),
    );

/// Cliente sin sesion. Lo usa `AuthApi` para el intercambio, que es publico y
/// que no puede depender del interceptor que a su vez depende de el.
final dioPublicoProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(_opciones(config));
  dio.interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
  ));

  dio.interceptors.add(ErrorInterceptor());

  // Chucker NO se instala aqui a proposito: este cliente hace el intercambio
  // con Auth0 y el inspector guardaria el access token en claro en el
  // dispositivo, la misma fuga que `crearInterceptorLog` cierra apagando
  // `requestBody`.
  if (config.logHttp && kDebugMode) {
    dio.interceptors.add(crearInterceptorLog());
  }

  return dio;
});

/// Cliente con sesion. Lo usa todo lo demas.
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(_opciones(config));

  dio.interceptors.add(
    AuthInterceptor(
      store: ref.watch(tokenStoreProvider),
      renovar: ref.watch(renovadorProvider),
      // `http_mock_adapter` no puede simular un Dio() completamente
      // desnudo (solo se engancha a la instancia que le pasan), asi que
      // AuthInterceptor acepta compartir el HttpClientAdapter del cliente
      // que lo instala. Aqui, en produccion, eso significa que el
      // reintento usa la misma pila de red real que ya usa el resto de la
      // app -- no un stub de pruebas -- mientras que AuthInterceptor y
      // ErrorInterceptor (los interceptors, no el adaptador) se quedan
      // fuera: eso es lo que de verdad evita que el reintento vuelva a
      // entrar en esta misma cadena.
      transporte: dio.httpClientAdapter,
    ),
  );
  dio.interceptors.add(ErrorInterceptor());

  if (config.logHttp && kDebugMode) {
    dio.interceptors.add(crearInterceptorLog());
    // Inspector en el dispositivo: burbuja tras cada peticion, lista con
    // request/response completos. Solo en debug y bajo el mismo LOG_HTTP.
    // Muestra la cabecera Authorization (Bearer de Sanctum local): asumible
    // en desarrollo, y el intercambio de Auth0 queda fuera (ver arriba).
    dio.interceptors.add(ChuckerDioInterceptor());
  }

  return dio;
});
