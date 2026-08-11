import 'package:freezed_annotation/freezed_annotation.dart';

import 'usuario.dart';

part 'sesion.freezed.dart';

/// Estado de sesion. Sellada: el `switch` de la UI y del router no puede
/// olvidarse de un caso.
@freezed
sealed class Sesion with _$Sesion {
  const factory Sesion.noAutenticado() = SesionNoAutenticado;

  const factory Sesion.autenticado(Usuario usuario) = SesionAutenticado;
}
