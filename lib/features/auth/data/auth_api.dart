import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/fallo_api.dart';
import '../../../core/network/dio_client.dart';
import 'dto/respuesta_sesion.dart';

/// Solo el intercambio. Va sobre `dioPublico` porque la ruta es publica y
/// porque `AuthInterceptor` depende de esta clase para renovar.
class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Future<RespuestaSesion> intercambiar(String accessToken, {String dispositivo = 'api'}) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/auth/auth0',
        data: {'accessToken': accessToken, 'dispositivo': dispositivo},
      );

      return RespuestaSesion.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioPublicoProvider)));
