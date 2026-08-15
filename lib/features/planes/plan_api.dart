import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/fallo_api.dart';
import '../../core/network/dio_client.dart';

class Plan {
  const Plan({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.moneda,
    required this.periodicidad,
    this.descripcion,
    this.diasPrueba,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        precio: (json['precio'] as num?)?.toDouble() ?? 0,
        moneda: json['moneda'] as String? ?? 'BOB',
        periodicidad: json['periodicidad'] as String? ?? 'mensual',
        descripcion: json['descripcion'] as String?,
        diasPrueba: json['diasPrueba'] as int?,
      );

  final int id;
  final String nombre;
  final double precio;
  final String moneda;
  final String periodicidad;
  final String? descripcion;
  final int? diasPrueba;
}

class PlanApi {
  const PlanApi(this._dio);

  final Dio _dio;

  Future<List<Plan>> disponibles() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/planes',
        queryParameters: {'porPagina': 50},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          Plan.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}

final planApiProvider = Provider<PlanApi>((ref) => PlanApi(ref.watch(dioProvider)));
