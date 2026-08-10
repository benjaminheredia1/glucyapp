import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagina_api.freezed.dart';
part 'pagina_api.g.dart';

/// Envoltorio del paginador de Laravel, que devuelve todo `listar()` de
/// `BaseCrudController`.
@Freezed(genericArgumentFactories: true)
abstract class PaginaApi<T> with _$PaginaApi<T> {
  const factory PaginaApi({
    required List<T> data,
    @JsonKey(name: 'current_page') required int paginaActual,
    @JsonKey(name: 'last_page') required int ultimaPagina,
    required int total,
  }) = _PaginaApi<T>;

  factory PaginaApi.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginaApiFromJson(json, fromJsonT);
}
