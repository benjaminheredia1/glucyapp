// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagina_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginaApi<T> _$PaginaApiFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _PaginaApi<T>(
  data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
  paginaActual: (json['current_page'] as num).toInt(),
  ultimaPagina: (json['last_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$PaginaApiToJson<T>(
  _PaginaApi<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': instance.data.map(toJsonT).toList(),
  'current_page': instance.paginaActual,
  'last_page': instance.ultimaPagina,
  'total': instance.total,
};
