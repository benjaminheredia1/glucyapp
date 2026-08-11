// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'respuesta_sesion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RespuestaSesion _$RespuestaSesionFromJson(Map<String, dynamic> json) =>
    _RespuestaSesion(
      token: json['token'] as String,
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RespuestaSesionToJson(_RespuestaSesion instance) =>
    <String, dynamic>{'token': instance.token, 'usuario': instance.usuario};
