import 'package:freezed_annotation/freezed_annotation.dart';

import 'rol.dart';

part 'usuario.freezed.dart';
part 'usuario.g.dart';

/// El backend mezcla dos convenciones: sus columnas propias van en camelCase y
/// las de Laravel en snake_case. Se respeta cada una con `@JsonKey`.
@freezed
abstract class Usuario with _$Usuario {
  const factory Usuario({
    required int id,
    required String name,
    required String email,
    required Rol rol,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? telefono,
    @JsonKey(name: 'email_verified_at') DateTime? emailVerificadoEn,
  }) = _Usuario;

  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);
}
