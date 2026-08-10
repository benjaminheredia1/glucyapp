import 'package:dio/dio.dart';

import 'traducir_fallo.dart';

/// Deja el `FalloApi` en `DioException.error`, para que los repositorios hagan
/// `on DioException catch (e) { throw e.error as FalloApi; }` sin repetir la
/// traduccion en cada uno.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(err.copyWith(error: traducirFallo(err)));
  }
}
