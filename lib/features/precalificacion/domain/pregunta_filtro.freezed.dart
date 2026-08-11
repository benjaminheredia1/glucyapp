// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pregunta_filtro.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PreguntaFiltro {

 int get id; String get codigo; String get texto; int get orden; int get version;
/// Create a copy of PreguntaFiltro
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreguntaFiltroCopyWith<PreguntaFiltro> get copyWith => _$PreguntaFiltroCopyWithImpl<PreguntaFiltro>(this as PreguntaFiltro, _$identity);

  /// Serializes this PreguntaFiltro to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreguntaFiltro&&(identical(other.id, id) || other.id == id)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.texto, texto) || other.texto == texto)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codigo,texto,orden,version);

@override
String toString() {
  return 'PreguntaFiltro(id: $id, codigo: $codigo, texto: $texto, orden: $orden, version: $version)';
}


}

/// @nodoc
abstract mixin class $PreguntaFiltroCopyWith<$Res>  {
  factory $PreguntaFiltroCopyWith(PreguntaFiltro value, $Res Function(PreguntaFiltro) _then) = _$PreguntaFiltroCopyWithImpl;
@useResult
$Res call({
 int id, String codigo, String texto, int orden, int version
});




}
/// @nodoc
class _$PreguntaFiltroCopyWithImpl<$Res>
    implements $PreguntaFiltroCopyWith<$Res> {
  _$PreguntaFiltroCopyWithImpl(this._self, this._then);

  final PreguntaFiltro _self;
  final $Res Function(PreguntaFiltro) _then;

/// Create a copy of PreguntaFiltro
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codigo = null,Object? texto = null,Object? orden = null,Object? version = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,texto: null == texto ? _self.texto : texto // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PreguntaFiltro].
extension PreguntaFiltroPatterns on PreguntaFiltro {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreguntaFiltro value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreguntaFiltro() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreguntaFiltro value)  $default,){
final _that = this;
switch (_that) {
case _PreguntaFiltro():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreguntaFiltro value)?  $default,){
final _that = this;
switch (_that) {
case _PreguntaFiltro() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String codigo,  String texto,  int orden,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreguntaFiltro() when $default != null:
return $default(_that.id,_that.codigo,_that.texto,_that.orden,_that.version);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String codigo,  String texto,  int orden,  int version)  $default,) {final _that = this;
switch (_that) {
case _PreguntaFiltro():
return $default(_that.id,_that.codigo,_that.texto,_that.orden,_that.version);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String codigo,  String texto,  int orden,  int version)?  $default,) {final _that = this;
switch (_that) {
case _PreguntaFiltro() when $default != null:
return $default(_that.id,_that.codigo,_that.texto,_that.orden,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PreguntaFiltro implements PreguntaFiltro {
  const _PreguntaFiltro({required this.id, required this.codigo, required this.texto, required this.orden, required this.version});
  factory _PreguntaFiltro.fromJson(Map<String, dynamic> json) => _$PreguntaFiltroFromJson(json);

@override final  int id;
@override final  String codigo;
@override final  String texto;
@override final  int orden;
@override final  int version;

/// Create a copy of PreguntaFiltro
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreguntaFiltroCopyWith<_PreguntaFiltro> get copyWith => __$PreguntaFiltroCopyWithImpl<_PreguntaFiltro>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PreguntaFiltroToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreguntaFiltro&&(identical(other.id, id) || other.id == id)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.texto, texto) || other.texto == texto)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codigo,texto,orden,version);

@override
String toString() {
  return 'PreguntaFiltro(id: $id, codigo: $codigo, texto: $texto, orden: $orden, version: $version)';
}


}

/// @nodoc
abstract mixin class _$PreguntaFiltroCopyWith<$Res> implements $PreguntaFiltroCopyWith<$Res> {
  factory _$PreguntaFiltroCopyWith(_PreguntaFiltro value, $Res Function(_PreguntaFiltro) _then) = __$PreguntaFiltroCopyWithImpl;
@override @useResult
$Res call({
 int id, String codigo, String texto, int orden, int version
});




}
/// @nodoc
class __$PreguntaFiltroCopyWithImpl<$Res>
    implements _$PreguntaFiltroCopyWith<$Res> {
  __$PreguntaFiltroCopyWithImpl(this._self, this._then);

  final _PreguntaFiltro _self;
  final $Res Function(_PreguntaFiltro) _then;

/// Create a copy of PreguntaFiltro
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codigo = null,Object? texto = null,Object? orden = null,Object? version = null,}) {
  return _then(_PreguntaFiltro(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,texto: null == texto ? _self.texto : texto // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
