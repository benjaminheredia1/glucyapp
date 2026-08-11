// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'respuesta_sesion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RespuestaSesion {

 String get token; Usuario get usuario;
/// Create a copy of RespuestaSesion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RespuestaSesionCopyWith<RespuestaSesion> get copyWith => _$RespuestaSesionCopyWithImpl<RespuestaSesion>(this as RespuestaSesion, _$identity);

  /// Serializes this RespuestaSesion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RespuestaSesion&&(identical(other.token, token) || other.token == token)&&(identical(other.usuario, usuario) || other.usuario == usuario));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,usuario);

@override
String toString() {
  return 'RespuestaSesion(token: $token, usuario: $usuario)';
}


}

/// @nodoc
abstract mixin class $RespuestaSesionCopyWith<$Res>  {
  factory $RespuestaSesionCopyWith(RespuestaSesion value, $Res Function(RespuestaSesion) _then) = _$RespuestaSesionCopyWithImpl;
@useResult
$Res call({
 String token, Usuario usuario
});


$UsuarioCopyWith<$Res> get usuario;

}
/// @nodoc
class _$RespuestaSesionCopyWithImpl<$Res>
    implements $RespuestaSesionCopyWith<$Res> {
  _$RespuestaSesionCopyWithImpl(this._self, this._then);

  final RespuestaSesion _self;
  final $Res Function(RespuestaSesion) _then;

/// Create a copy of RespuestaSesion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? usuario = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,usuario: null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as Usuario,
  ));
}
/// Create a copy of RespuestaSesion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsuarioCopyWith<$Res> get usuario {
  
  return $UsuarioCopyWith<$Res>(_self.usuario, (value) {
    return _then(_self.copyWith(usuario: value));
  });
}
}


/// Adds pattern-matching-related methods to [RespuestaSesion].
extension RespuestaSesionPatterns on RespuestaSesion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RespuestaSesion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RespuestaSesion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RespuestaSesion value)  $default,){
final _that = this;
switch (_that) {
case _RespuestaSesion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RespuestaSesion value)?  $default,){
final _that = this;
switch (_that) {
case _RespuestaSesion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  Usuario usuario)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RespuestaSesion() when $default != null:
return $default(_that.token,_that.usuario);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  Usuario usuario)  $default,) {final _that = this;
switch (_that) {
case _RespuestaSesion():
return $default(_that.token,_that.usuario);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  Usuario usuario)?  $default,) {final _that = this;
switch (_that) {
case _RespuestaSesion() when $default != null:
return $default(_that.token,_that.usuario);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RespuestaSesion implements RespuestaSesion {
  const _RespuestaSesion({required this.token, required this.usuario});
  factory _RespuestaSesion.fromJson(Map<String, dynamic> json) => _$RespuestaSesionFromJson(json);

@override final  String token;
@override final  Usuario usuario;

/// Create a copy of RespuestaSesion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RespuestaSesionCopyWith<_RespuestaSesion> get copyWith => __$RespuestaSesionCopyWithImpl<_RespuestaSesion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RespuestaSesionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RespuestaSesion&&(identical(other.token, token) || other.token == token)&&(identical(other.usuario, usuario) || other.usuario == usuario));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,usuario);

@override
String toString() {
  return 'RespuestaSesion(token: $token, usuario: $usuario)';
}


}

/// @nodoc
abstract mixin class _$RespuestaSesionCopyWith<$Res> implements $RespuestaSesionCopyWith<$Res> {
  factory _$RespuestaSesionCopyWith(_RespuestaSesion value, $Res Function(_RespuestaSesion) _then) = __$RespuestaSesionCopyWithImpl;
@override @useResult
$Res call({
 String token, Usuario usuario
});


@override $UsuarioCopyWith<$Res> get usuario;

}
/// @nodoc
class __$RespuestaSesionCopyWithImpl<$Res>
    implements _$RespuestaSesionCopyWith<$Res> {
  __$RespuestaSesionCopyWithImpl(this._self, this._then);

  final _RespuestaSesion _self;
  final $Res Function(_RespuestaSesion) _then;

/// Create a copy of RespuestaSesion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? usuario = null,}) {
  return _then(_RespuestaSesion(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,usuario: null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as Usuario,
  ));
}

/// Create a copy of RespuestaSesion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsuarioCopyWith<$Res> get usuario {
  
  return $UsuarioCopyWith<$Res>(_self.usuario, (value) {
    return _then(_self.copyWith(usuario: value));
  });
}
}

// dart format on
