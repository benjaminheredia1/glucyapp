import 'package:json_annotation/json_annotation.dart';

/// Los tres roles de `users.rol`. La autorizacion real la hace el backend; esto
/// solo decide a que parte de la app aterriza cada quien.
enum Rol {
  @JsonValue('admin')
  admin,
  @JsonValue('doctor')
  doctor,
  @JsonValue('paciente')
  paciente,
}
