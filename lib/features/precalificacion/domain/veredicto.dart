import 'package:freezed_annotation/freezed_annotation.dart';

part 'veredicto.freezed.dart';
part 'veredicto.g.dart';

enum Resultado {
  @JsonValue('apto')
  apto,
  @JsonValue('no_apto')
  noApto,
  @JsonValue('urgente')
  urgente,
}

/// Lo decide `PrecalificacionController::evaluar` en el servidor. El cliente
/// solo lo obedece.
@freezed
abstract class Veredicto with _$Veredicto {
  const factory Veredicto({
    required int id,
    required Resultado resultado,
    String? motivo,
  }) = _Veredicto;

  factory Veredicto.fromJson(Map<String, dynamic> json) => _$VeredictoFromJson(json);
}
