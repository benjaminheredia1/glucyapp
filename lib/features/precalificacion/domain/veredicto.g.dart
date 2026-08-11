// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'veredicto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Veredicto _$VeredictoFromJson(Map<String, dynamic> json) => _Veredicto(
  id: (json['id'] as num).toInt(),
  resultado: $enumDecode(_$ResultadoEnumMap, json['resultado']),
  motivo: json['motivo'] as String?,
);

Map<String, dynamic> _$VeredictoToJson(_Veredicto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resultado': _$ResultadoEnumMap[instance.resultado]!,
      'motivo': instance.motivo,
    };

const _$ResultadoEnumMap = {
  Resultado.apto: 'apto',
  Resultado.noApto: 'no_apto',
  Resultado.urgente: 'urgente',
};
