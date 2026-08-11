import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/usuario.dart';

part 'respuesta_sesion.freezed.dart';
part 'respuesta_sesion.g.dart';

/// Cuerpo de `POST /api/auth/auth0`.
@freezed
abstract class RespuestaSesion with _$RespuestaSesion {
  const factory RespuestaSesion({
    required String token,
    required Usuario usuario,
  }) = _RespuestaSesion;

  factory RespuestaSesion.fromJson(Map<String, dynamic> json) =>
      _$RespuestaSesionFromJson(json);
}
