// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'veredicto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Veredicto {

 int get id; Resultado get resultado; String? get motivo;
/// Create a copy of Veredicto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VeredictoCopyWith<Veredicto> get copyWith => _$VeredictoCopyWithImpl<Veredicto>(this as Veredicto, _$identity);

  /// Serializes this Veredicto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Veredicto&&(identical(other.id, id) || other.id == id)&&(identical(other.resultado, resultado) || other.resultado == resultado)&&(identical(other.motivo, motivo) || other.motivo == motivo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resultado,motivo);

@override
String toString() {
  return 'Veredicto(id: $id, resultado: $resultado, motivo: $motivo)';
}


}

/// @nodoc
abstract mixin class $VeredictoCopyWith<$Res>  {
  factory $VeredictoCopyWith(Veredicto value, $Res Function(Veredicto) _then) = _$VeredictoCopyWithImpl;
@useResult
$Res call({
 int id, Resultado resultado, String? motivo
});




}
/// @nodoc
class _$VeredictoCopyWithImpl<$Res>
    implements $VeredictoCopyWith<$Res> {
  _$VeredictoCopyWithImpl(this._self, this._then);

  final Veredicto _self;
  final $Res Function(Veredicto) _then;

/// Create a copy of Veredicto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? resultado = null,Object? motivo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,resultado: null == resultado ? _self.resultado : resultado // ignore: cast_nullable_to_non_nullable
as Resultado,motivo: freezed == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Veredicto].
extension VeredictoPatterns on Veredicto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Veredicto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Veredicto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Veredicto value)  $default,){
final _that = this;
switch (_that) {
case _Veredicto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Veredicto value)?  $default,){
final _that = this;
switch (_that) {
case _Veredicto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  Resultado resultado,  String? motivo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Veredicto() when $default != null:
return $default(_that.id,_that.resultado,_that.motivo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  Resultado resultado,  String? motivo)  $default,) {final _that = this;
switch (_that) {
case _Veredicto():
return $default(_that.id,_that.resultado,_that.motivo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  Resultado resultado,  String? motivo)?  $default,) {final _that = this;
switch (_that) {
case _Veredicto() when $default != null:
return $default(_that.id,_that.resultado,_that.motivo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Veredicto implements Veredicto {
  const _Veredicto({required this.id, required this.resultado, this.motivo});
  factory _Veredicto.fromJson(Map<String, dynamic> json) => _$VeredictoFromJson(json);

@override final  int id;
@override final  Resultado resultado;
@override final  String? motivo;

/// Create a copy of Veredicto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VeredictoCopyWith<_Veredicto> get copyWith => __$VeredictoCopyWithImpl<_Veredicto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VeredictoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Veredicto&&(identical(other.id, id) || other.id == id)&&(identical(other.resultado, resultado) || other.resultado == resultado)&&(identical(other.motivo, motivo) || other.motivo == motivo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resultado,motivo);

@override
String toString() {
  return 'Veredicto(id: $id, resultado: $resultado, motivo: $motivo)';
}


}

/// @nodoc
abstract mixin class _$VeredictoCopyWith<$Res> implements $VeredictoCopyWith<$Res> {
  factory _$VeredictoCopyWith(_Veredicto value, $Res Function(_Veredicto) _then) = __$VeredictoCopyWithImpl;
@override @useResult
$Res call({
 int id, Resultado resultado, String? motivo
});




}
/// @nodoc
class __$VeredictoCopyWithImpl<$Res>
    implements _$VeredictoCopyWith<$Res> {
  __$VeredictoCopyWithImpl(this._self, this._then);

  final _Veredicto _self;
  final $Res Function(_Veredicto) _then;

/// Create a copy of Veredicto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? resultado = null,Object? motivo = freezed,}) {
  return _then(_Veredicto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,resultado: null == resultado ? _self.resultado : resultado // ignore: cast_nullable_to_non_nullable
as Resultado,motivo: freezed == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
