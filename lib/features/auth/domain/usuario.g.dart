// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Usuario _$UsuarioFromJson(Map<String, dynamic> json) => _Usuario(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String?,
  rol: $enumDecode(_$RolEnumMap, json['rol']),
  esTemporal: json['esTemporal'] as bool? ?? false,
  apellidoPaterno: json['apellidoPaterno'] as String?,
  apellidoMaterno: json['apellidoMaterno'] as String?,
  telefono: json['telefono'] as String?,
  emailVerificadoEn: json['email_verified_at'] == null
      ? null
      : DateTime.parse(json['email_verified_at'] as String),
);

Map<String, dynamic> _$UsuarioToJson(_Usuario instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'rol': _$RolEnumMap[instance.rol]!,
  'esTemporal': instance.esTemporal,
  'apellidoPaterno': instance.apellidoPaterno,
  'apellidoMaterno': instance.apellidoMaterno,
  'telefono': instance.telefono,
  'email_verified_at': instance.emailVerificadoEn?.toIso8601String(),
};

const _$RolEnumMap = {
  Rol.admin: 'admin',
  Rol.doctor: 'doctor',
  Rol.paciente: 'paciente',
};
