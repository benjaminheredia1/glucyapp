import 'package:freezed_annotation/freezed_annotation.dart';

part 'pregunta_filtro.freezed.dart';
part 'pregunta_filtro.g.dart';

/// Pregunta tal y como la sirve `GET /api/precalificacion/preguntas`.
///
/// No trae `respuestaAlarma` ni `motivo` a proposito: si el cliente supiera
/// cual es la respuesta de alarma, el veredicto seria manipulable.
@freezed
abstract class PreguntaFiltro with _$PreguntaFiltro {
  const factory PreguntaFiltro({
    required int id,
    required String codigo,
    required String texto,
    required int orden,
    required int version,
  }) = _PreguntaFiltro;

  factory PreguntaFiltro.fromJson(Map<String, dynamic> json) => _$PreguntaFiltroFromJson(json);
}
