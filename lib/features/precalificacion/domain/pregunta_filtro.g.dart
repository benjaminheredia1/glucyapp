// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregunta_filtro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PreguntaFiltro _$PreguntaFiltroFromJson(Map<String, dynamic> json) =>
    _PreguntaFiltro(
      id: (json['id'] as num).toInt(),
      codigo: json['codigo'] as String,
      texto: json['texto'] as String,
      orden: (json['orden'] as num).toInt(),
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$PreguntaFiltroToJson(_PreguntaFiltro instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codigo': instance.codigo,
      'texto': instance.texto,
      'orden': instance.orden,
      'version': instance.version,
    };
