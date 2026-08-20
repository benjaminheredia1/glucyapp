import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/fallo_api.dart';
import '../../core/network/dio_client.dart';

class TipoEstudio {
  const TipoEstudio({required this.id, required this.nombre});

  factory TipoEstudio.fromJson(Map<String, dynamic> json) =>
      TipoEstudio(id: json['id'] as int, nombre: json['nombre'] as String);

  final int id;
  final String nombre;
}

/// Estudio del paciente con su veredicto. `estado` refleja el flujo de
/// aprobacion del backend: pendiente → en_revision → aprobado | rechazado.
class EstudioMedico {
  const EstudioMedico({
    required this.id,
    required this.estado,
    required this.fecha,
    this.tipoEstudio,
    this.tipoEstudioId,
    this.motivoRechazo,
    this.descripcion,
    this.archivoId,
    this.pacienteNombre,
  });

  factory EstudioMedico.fromJson(Map<String, dynamic> json) {
    final usuario = (json['paciente'] as Map<String, dynamic>?)?['usuario'] as Map<String, dynamic>?;
    final nombre = usuario == null
        ? null
        : [usuario['name'], usuario['apellidoPaterno']].whereType<String>().join(' ').trim();

    // Laravel serializa la relacion eager-loaded en snake_case
    // (`tipo_estudio`) aunque las columnas propias vayan en camelCase.
    final tipo = (json['tipoEstudio'] ?? json['tipo_estudio']) as Map<String, dynamic>?;

    return EstudioMedico(
      id: json['id'] as int,
      estado: json['estado'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      tipoEstudio: tipo == null ? null : TipoEstudio.fromJson(tipo),
      tipoEstudioId: json['tipoEstudioId'] as int? ?? tipo?['id'] as int?,
      motivoRechazo: json['motivoRechazo'] as String?,
      descripcion: json['descripcion'] as String?,
      archivoId: json['archivoId'] as int? ?? (json['archivo'] as Map<String, dynamic>?)?['id'] as int?,
      pacienteNombre: nombre == null || nombre.isEmpty ? null : nombre,
    );
  }

  final int id;
  final String estado;
  final DateTime fecha;
  final TipoEstudio? tipoEstudio;
  /// Siempre presente en el JSON; `tipoEstudio` solo si el backend cargo la
  /// relacion. Cruzar por este id no depende de eso.
  final int? tipoEstudioId;
  final String? motivoRechazo;
  final String? descripcion;
  final int? archivoId;
  final String? pacienteNombre;
}

/// Resultado de subir un archivo: el id para registrar estudios que falten y
/// los estudios que la IA detecto y aprobo al momento en ese mismo archivo.
typedef ResultadoSubida = ({int archivoId, List<EstudioMedico> aprobados});

class EstudioApi {
  const EstudioApi(this._dio);

  final Dio _dio;

  /// Estudios propios (el alcance del backend filtra por la sesion).
  Future<List<EstudioMedico>> propios() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/estudios-medicos',
        queryParameters: {'porPagina': 50, 'orden': 'created_at', 'direccion': 'desc'},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          EstudioMedico.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  Future<List<TipoEstudio>> tipos() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/tipo-estudios',
        queryParameters: {'porPagina': 100},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          TipoEstudio.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  /// Sube el documento (`POST /archivos/subir`). La IA del backend lo analiza
  /// en esta misma peticion y el veredicto llega al momento:
  ///
  /// - 422 si no es un estudio medico legible: [FalloValidacion] con el
  ///   motivo de la IA.
  /// - 2xx si es valido: `aprobados` trae los estudios que la IA detecto y
  ///   dejo aprobados (vacio si la IA esta apagada o no detecto ninguno; en
  ///   ese caso el flujo manual de revision del doctor sigue vigente).
  Future<ResultadoSubida> subirArchivo({required String rutaArchivo, required String nombreArchivo}) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/archivos/subir',
        data: FormData.fromMap({
          'archivo': await MultipartFile.fromFile(rutaArchivo, filename: nombreArchivo),
          'nombre': nombreArchivo,
        }),
      );

      return (
        archivoId: respuesta.data!['id'] as int,
        aprobados: [
          for (final fila in respuesta.data!['estudiosAprobados'] as List<dynamic>? ?? const [])
            EstudioMedico.fromJson(fila as Map<String, dynamic>),
        ],
      );
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  /// Registra un estudio de `tipoEstudioId` apuntando a un archivo ya subido.
  /// Nace `pendiente`: la aprobacion la firma un doctor desde su portal.
  Future<EstudioMedico> registrar({
    required int tipoEstudioId,
    required int archivoId,
    String? descripcion,
  }) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>('/estudios-medicos', data: {
        'tipoEstudioId': tipoEstudioId,
        'archivoId': archivoId,
        'fecha': DateTime.now().toIso8601String().substring(0, 10),
        'origen': 'carga',
        'descripcion': ?descripcion,
      });

      return EstudioMedico.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  /// Sube el documento y registra el estudio en un solo paso. Un
  /// [FalloValidacion] aqui significa que la IA rechazo el archivo al
  /// momento: no se registra ningun estudio.
  ///
  /// Si la IA ya aprobo un estudio de este tipo en el archivo subido, ese es
  /// el resultado y no se registra un duplicado pendiente.
  Future<EstudioMedico> subir({
    required int tipoEstudioId,
    required String rutaArchivo,
    required String nombreArchivo,
    String? descripcion,
  }) async {
    final subida = await subirArchivo(rutaArchivo: rutaArchivo, nombreArchivo: nombreArchivo);

    for (final aprobado in subida.aprobados) {
      if (aprobado.tipoEstudioId == tipoEstudioId) return aprobado;
    }

    return registrar(tipoEstudioId: tipoEstudioId, archivoId: subida.archivoId, descripcion: descripcion);
  }

  // ------------------------------------------------- portal del doctor

  /// Cargas que esperan veredicto, para el portal del doctor. El alcance del
  /// backend ya limita a los pacientes de su clinica.
  Future<List<EstudioMedico>> porValidar() async {
    try {
      final respuesta = await _dio.get<Map<String, dynamic>>(
        '/estudios-medicos',
        queryParameters: {'porPagina': 100, 'orden': 'created_at', 'direccion': 'asc'},
      );

      return [
        for (final fila in respuesta.data!['data'] as List<dynamic>)
          if (fila['estado'] == 'pendiente' || fila['estado'] == 'en_revision')
            EstudioMedico.fromJson(fila as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  /// Firma el veredicto. Solo doctor o admin: el backend rechaza al resto.
  Future<void> validar({required int id, required bool aprobar, String? motivo}) async {
    try {
      await _dio.post<Map<String, dynamic>>('/estudios-medicos/$id/validar', data: {
        'estado': aprobar ? 'aprobado' : 'rechazado',
        if (!aprobar) 'motivoRechazo': motivo,
      });
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  /// Enlace firmado temporal (5 min) para abrir el documento en el navegador.
  Future<Uri> enlaceArchivo(int archivoId) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>('/archivos/$archivoId/enlace');

      return Uri.parse(respuesta.data!['url'] as String);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}

final estudioApiProvider = Provider<EstudioApi>((ref) => EstudioApi(ref.watch(dioProvider)));
