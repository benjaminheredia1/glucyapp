import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/fallo_api.dart';
import '../../core/network/dio_client.dart';

class Medicion {
  const Medicion({
    required this.id,
    required this.valor,
    required this.momento,
    required this.medidoEn,
  });

  factory Medicion.fromJson(Map<String, dynamic> json) => Medicion(
        id: json['id'] as int,
        valor: (json['valor'] as num).toDouble(),
        momento: json['momento'] as String,
        medidoEn: DateTime.parse(json['medidoEn'] as String),
      );

  final int id;
  final double valor;
  final String momento;
  final DateTime medidoEn;
}

/// Mediciones de glucosa. El backend inyecta el pacienteId de la sesion
/// (forzarPacientePropio) y asigna el ciclo activo: aqui no viaja ninguno.
class MedicionApi {
  const MedicionApi(this._dio);

  final Dio _dio;

  Future<Medicion> registrar({
    required double valor,
    required String momento,
    String? nota,
  }) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>('/mediciones', data: {
        'valor': valor,
        'momento': momento,
        'unidad': 'mg/dL',
        'fuente': 'manual',
        if (nota != null && nota.isNotEmpty) 'nota': nota,
      });

      return Medicion.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  /// Ultimas mediciones propias, mas reciente primero.
  Future<List<Medicion>> recientes({int cantidad = 7}) async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/mediciones',
        queryParameters: {'porPagina': cantidad, 'orden': 'medidoEn', 'direccion': 'desc'},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          Medicion.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}

final medicionApiProvider = Provider<MedicionApi>((ref) => MedicionApi(ref.watch(dioProvider)));
