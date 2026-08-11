import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_store.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Lo sobrescribe la Task 10 con la renovacion real. Por defecto, no hay forma
/// de renovar: un 401 cierra la sesion.
final renovadorProvider = Provider<Renovador>((ref) => () async => null);

BaseOptions _opciones(AppConfig config) => BaseOptions(
      baseUrl: config.apiBaseUrl.toString(),
      connectTimeout: config.timeout,
      receiveTimeout: config.timeout,
      sendTimeout: config.timeout,
      headers: const {'Accept': 'application/json'},
    );

Interceptor _log() => LogInterceptor(
      request: false,
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      logPrint: (linea) => debugPrint(_redactar(linea.toString())),
    );

/// El log no puede filtrar credenciales ni en desarrollo.
String _redactar(String linea) => linea
    .replaceAll(RegExp(r'(Bearer\s+)[\w\-\.|]+'), r'$1<redactado>')
    .replaceAll(RegExp(r'("(?:password|token|accessToken)"\s*:\s*")[^"]*'), r'$1<redactado>');

/// Cliente sin sesion. Lo usa `AuthApi` para el intercambio, que es publico y
/// que no puede depender del interceptor que a su vez depende de el.
final dioPublicoProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(_opciones(config));

  dio.interceptors.add(ErrorInterceptor());

  if (config.logHttp && kDebugMode) {
    dio.interceptors.add(_log());
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
      // El reintento comparte el transporte real de este cliente, no su
      // lista de interceptors: ver el comentario en AuthInterceptor.
      transporte: dio.httpClientAdapter,
    ),
  );
  dio.interceptors.add(ErrorInterceptor());

  if (config.logHttp && kDebugMode) {
    dio.interceptors.add(_log());
  }

  return dio;
});
