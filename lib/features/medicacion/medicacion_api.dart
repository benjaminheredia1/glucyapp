import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/fallo_api.dart';
import '../../core/network/dio_client.dart';

/// Toma de medicacion de un dia. `programadaEn`/`tomadaEn` en hora local.
class TomaDelDia {
  const TomaDelDia({
    required this.id,
    required this.programadaEn,
    required this.estado,
    required this.medicamento,
    required this.dosis,
    this.tomadaEn,
  });

  factory TomaDelDia.fromJson(Map<String, dynamic> json) {
    // Laravel serializa la relacion en snake_case (`paciente_medicamento`).
    final pm = (json['pacienteMedicamento'] ?? json['paciente_medicamento']) as Map<String, dynamic>?;
    final medicamento = pm?['medicamento'] as Map<String, dynamic>?;

    return TomaDelDia(
      id: json['id'] as int,
      programadaEn: DateTime.parse(json['programadaEn'] as String).toLocal(),
      tomadaEn: json['tomadaEn'] == null ? null : DateTime.parse(json['tomadaEn'] as String).toLocal(),
      estado: json['estado'] as String,
      medicamento: medicamento?['nombre'] as String? ?? 'Medicamento',
      dosis: pm?['dosis'] as String? ?? '',
    );
  }

  final int id;
  final DateTime programadaEn;
  final DateTime? tomadaEn;

  /// pendiente | tomada | omitida
  final String estado;
  final String medicamento;
  final String dosis;

  bool get tomada => estado == 'tomada';
  bool get pendiente => estado == 'pendiente';
}

/// Entrada del historial (`GET /actividad`), en hora local.
sealed class EntradaActividad {
  const EntradaActividad(this.en);

  final DateTime en;

  static EntradaActividad fromJson(Map<String, dynamic> json) {
    final en = DateTime.parse(json['en'] as String).toLocal();

    return switch (json['tipo']) {
      'toma' => ActividadToma(
          en,
          medicamento: json['medicamento'] as String? ?? 'Medicamento',
          dosis: json['dosis'] as String? ?? '',
          estado: json['estado'] as String,
        ),
      _ => ActividadMedicion(
          en,
          valor: switch (json['valor']) {
            final num v => v.toDouble(),
            final String v => double.tryParse(v) ?? 0,
            _ => 0,
          },
          unidad: json['unidad'] as String? ?? 'mg/dL',
          momento: json['momento'] as String? ?? '',
        ),
    };
  }
}

class ActividadToma extends EntradaActividad {
  const ActividadToma(super.en, {required this.medicamento, required this.dosis, required this.estado});

  final String medicamento;
  final String dosis;
  final String estado;

  bool get tomada => estado == 'tomada';
}

class ActividadMedicion extends EntradaActividad {
  const ActividadMedicion(super.en, {required this.valor, required this.unidad, required this.momento});

  final double valor;
  final String unidad;
  final String momento;
}

class MedicamentoCatalogo {
  const MedicamentoCatalogo({required this.id, required this.nombre, this.concentracion});

  factory MedicamentoCatalogo.fromJson(Map<String, dynamic> json) => MedicamentoCatalogo(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        concentracion: json['concentracion'] as String?,
      );

  final int id;
  final String nombre;
  final String? concentracion;

  String get etiqueta => (concentracion == null || concentracion!.isEmpty) ? nombre : '$nombre $concentracion';
}

class PacienteResumen {
  const PacienteResumen({required this.id, required this.nombre});

  factory PacienteResumen.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] as Map<String, dynamic>?;
    final nombre = [usuario?['name'], usuario?['apellidoPaterno']].whereType<String>().join(' ').trim();

    return PacienteResumen(id: json['id'] as int, nombre: nombre.isEmpty ? 'Paciente ${json['id']}' : nombre);
  }

  final int id;
  final String nombre;
}

/// Tomas del dia, historial y (para el doctor) alta de medicacion. Todo con
/// Bearer; vale tambien el de la identidad anonima.
class MedicacionApi {
  const MedicacionApi(this._dio);

  final Dio _dio;

  /// `GET /tomas?dia&zona`: el backend materializa las tomas que falten y las
  /// devuelve ordenadas por hora.
  Future<List<TomaDelDia>> tomasDeHoy({required String dia, required String zona}) async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>('/tomas', queryParameters: {
        'dia': dia,
        'zona': zona,
        'orden': 'programadaEn',
        'direccion': 'asc',
        'porPagina': 50,
      });

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          TomaDelDia.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  Future<TomaDelDia> marcar(int tomaId, {required bool tomada}) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/tomas/$tomaId/marcar',
        data: {'estado': tomada ? 'tomada' : 'omitida'},
      );

      return TomaDelDia.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  Future<List<EntradaActividad>> actividad({int porPagina = 50}) async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/actividad',
        queryParameters: {'porPagina': porPagina},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          EntradaActividad.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  // ------------------------------------------------- doctor

  Future<List<MedicamentoCatalogo>> medicamentos() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/medicamentos',
        queryParameters: {'porPagina': 100, 'activo': 1},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          MedicamentoCatalogo.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  /// Pacientes visibles para el doctor (su clinica + asignados).
  Future<List<PacienteResumen>> pacientes() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/pacientes',
        queryParameters: {'porPagina': 100},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          PacienteResumen.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  Future<void> asignar({
    required int pacienteId,
    required int medicamentoId,
    required String dosis,
    required String frecuencia,
    required List<String> horarios,
    required DateTime fechaInicio,
    String? indicaciones,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>('/paciente-medicamentos', data: {
        'pacienteId': pacienteId,
        'medicamentoId': medicamentoId,
        'dosis': dosis,
        'frecuencia': frecuencia,
        'horarios': horarios,
        'fechaInicio': fechaInicio.toIso8601String().substring(0, 10),
        'indicaciones': ?indicaciones,
      });
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  FalloApi _fallo(DioException e) => e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
}

final medicacionApiProvider = Provider<MedicacionApi>((ref) => MedicacionApi(ref.watch(dioProvider)));
