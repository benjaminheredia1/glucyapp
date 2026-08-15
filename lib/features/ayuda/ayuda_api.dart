import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/fallo_api.dart';
import '../../core/network/dio_client.dart';

class ArticuloAyuda {
  const ArticuloAyuda({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.cuerpo,
  });

  factory ArticuloAyuda.fromJson(Map<String, dynamic> json) => ArticuloAyuda(
        id: json['id'] as int,
        categoria: json['categoria'] as String,
        titulo: json['titulo'] as String,
        cuerpo: json['cuerpo'] as String,
      );

  final int id;
  final String categoria;
  final String titulo;
  final String cuerpo;
}

class AyudaApi {
  const AyudaApi(this._dio);

  final Dio _dio;

  /// Articulos publicados, en el orden editorial del backend. El alcance ya
  /// oculta borradores a quien no es admin.
  Future<List<ArticuloAyuda>> articulos() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/articulos-ayuda',
        queryParameters: {'porPagina': 100},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          ArticuloAyuda.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}

final ayudaApiProvider = Provider<AyudaApi>((ref) => AyudaApi(ref.watch(dioProvider)));
