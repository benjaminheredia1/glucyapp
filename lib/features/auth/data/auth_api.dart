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

  /// Identidad temporal sin datos (`POST /auth/anonimo`). Con su token el
  /// paciente hace todo el embudo; en "Crear cuenta" se reclama con
  /// [intercambiar] pasando `tokenAnonimo`.
  Future<RespuestaSesion> anonimo({String dispositivo = 'api'}) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/auth/anonimo',
        data: {'dispositivo': dispositivo},
      );

      return RespuestaSesion.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  /// Canjea el access token de Auth0 por un token de Sanctum. Si llega
  /// `tokenAnonimo`, va como Bearer y el backend convierte esa identidad en la
  /// cuenta real (mismo `usuario.id`). Se pone a mano y no por el
  /// `AuthInterceptor` porque este cliente es el publico: meterlo en la cola
  /// de renovacion crearia un ciclo (renovar llama a intercambiar).
  Future<RespuestaSesion> intercambiar(
    String accessToken, {
    String dispositivo = 'api',
    String? tokenAnonimo,
  }) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/auth/auth0',
        data: {'accessToken': accessToken, 'dispositivo': dispositivo},
        options: tokenAnonimo == null
            ? null
            : Options(headers: {'Authorization': 'Bearer $tokenAnonimo'}),
      );

      return RespuestaSesion.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioPublicoProvider)));
