import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/fallo_api.dart';
import '../../core/network/dio_client.dart';
import '../auth/domain/usuario.dart';

/// Datos clinicos propios que viajan anidados en `/user` y `/perfil` bajo la
/// clave `paciente`. Solo los campos que edita la pantalla de perfil.
class PerfilPaciente {
  const PerfilPaciente({
    required this.id,
    this.fechaNacimiento,
    this.sexo,
    this.pesoKg,
    this.tallaCm,
  });

  factory PerfilPaciente.fromJson(Map<String, dynamic> json) => PerfilPaciente(
        id: json['id'] as int,
        fechaNacimiento: json['fechaNacimiento'] == null
            ? null
            : DateTime.tryParse(json['fechaNacimiento'] as String),
        sexo: json['sexo'] as String?,
        pesoKg: (json['pesoKg'] as num?)?.toDouble(),
        tallaCm: switch (json['tallaCm']) {
          final int talla => talla,
          final String talla => int.tryParse(talla),
          _ => null,
        },
      );

  final int id;
  final DateTime? fechaNacimiento;
  final String? sexo;
  final double? pesoKg;
  final int? tallaCm;
}

class Perfil {
  const Perfil({required this.usuario, this.paciente});

  factory Perfil.fromJson(Map<String, dynamic> json) => Perfil(
        usuario: Usuario.fromJson(json),
        paciente: json['paciente'] == null
            ? null
            : PerfilPaciente.fromJson(json['paciente'] as Map<String, dynamic>),
      );

  final Usuario usuario;
  final PerfilPaciente? paciente;
}

/// Autoedicion del perfil contra `PATCH /perfil` de glucyai.
class PerfilApi {
  const PerfilApi(this._dio);

  final Dio _dio;

  Future<Perfil> obtener() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>('/user');

      return Perfil.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  Future<Perfil> actualizar({
    String? name,
    String? apellidoPaterno,
    String? telefono,
    DateTime? fechaNacimiento,
    String? sexo,
    double? pesoKg,
    int? tallaCm,
  }) async {
    // Solo viajan los campos con valor: PATCH parcial, igual que el backend.
    final cuerpo = <String, dynamic>{
      'name': ?name,
      'apellidoPaterno': ?apellidoPaterno,
      'telefono': ?telefono,
      'fechaNacimiento': ?fechaNacimiento?.toIso8601String().substring(0, 10),
      'sexo': ?sexo,
      'pesoKg': ?pesoKg,
      'tallaCm': ?tallaCm,
    };

    try {
      final respuesta = await _dio.patch<Map<String, dynamic>>('/perfil', data: cuerpo);

      return Perfil.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}

final perfilApiProvider = Provider<PerfilApi>((ref) => PerfilApi(ref.watch(dioProvider)));
