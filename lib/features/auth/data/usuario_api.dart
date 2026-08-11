import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/fallo_api.dart';
import '../../../core/network/dio_client.dart';
import '../domain/usuario.dart';

/// Rutas que exigen sesion. Van sobre el `dio` con `AuthInterceptor`.
class UsuarioApi {
  const UsuarioApi(this._dio);

  final Dio _dio;

  Future<Usuario> actual() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>('/user');

      return Usuario.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _dio.post<void>('/auth/logout');
    } on DioException catch (e) {
      // Que el servidor no confirme la revocacion no puede impedir salir: el
      // token local se borra igualmente en AuthRepository.
      if (e.error is FalloRed) return;

      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}

final usuarioApiProvider = Provider<UsuarioApi>((ref) => UsuarioApi(ref.watch(dioProvider)));
