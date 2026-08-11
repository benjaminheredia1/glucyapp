import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/fallo_api.dart';
import '../../../core/network/dio_client.dart';
import '../domain/pregunta_filtro.dart';
import '../domain/veredicto.dart';

/// Dos clientes: el filtro corre antes de que exista la cuenta, asi que sus dos
/// rutas son publicas; `vincular` en cambio exige sesion.
class PrecalificacionApi {
  const PrecalificacionApi(this._publico, this._autenticado);

  final Dio _publico;
  final Dio _autenticado;

  Future<List<PreguntaFiltro>> preguntas() async {
    try {
      final respuesta = await _publico.get<List<dynamic>>('/precalificacion/preguntas');

      return respuesta.data!
          .map((fila) => PreguntaFiltro.fromJson(fila as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  Future<Veredicto> evaluar(Map<String, dynamic> cuerpo) async {
    try {
      final respuesta = await _publico.post<Map<String, dynamic>>(
        '/precalificacion/evaluar',
        data: cuerpo,
      );

      return Veredicto.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  Future<void> vincular(int precalificacionId) async {
    try {
      await _autenticado.post<void>('/precalificaciones/$precalificacionId/vincular');
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  FalloApi _fallo(DioException e) =>
      e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
}

final precalificacionApiProvider = Provider<PrecalificacionApi>(
  (ref) => PrecalificacionApi(ref.watch(dioPublicoProvider), ref.watch(dioProvider)),
);
