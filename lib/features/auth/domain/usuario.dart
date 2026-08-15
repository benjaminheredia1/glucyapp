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

extension UsuarioNombre on Usuario {
  /// Nombre y primer apellido, si existe. Las cuentas creadas por Auth0 solo
  /// traen `name` (a veces el propio correo), asi que no se asume nada mas.
  String get nombreCompleto {
    final apellido = apellidoPaterno;

    return apellido == null || apellido.trim().isEmpty ? name : '$name ${apellido.trim()}';
  }

  /// Dos iniciales para el avatar. Con una sola palabra, la primera letra.
  String get iniciales {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();

    return (partes.first[0] + partes[1][0]).toUpperCase();
  }
}
