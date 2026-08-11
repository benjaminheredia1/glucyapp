// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sesion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Sesion {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sesion);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Sesion()';
}


}

/// @nodoc
class $SesionCopyWith<$Res>  {
$SesionCopyWith(Sesion _, $Res Function(Sesion) __);
}


/// Adds pattern-matching-related methods to [Sesion].
extension SesionPatterns on Sesion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SesionNoAutenticado value)?  noAutenticado,TResult Function( SesionAutenticado value)?  autenticado,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SesionNoAutenticado() when noAutenticado != null:
return noAutenticado(_that);case SesionAutenticado() when autenticado != null:
return autenticado(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SesionNoAutenticado value)  noAutenticado,required TResult Function( SesionAutenticado value)  autenticado,}){
final _that = this;
switch (_that) {
case SesionNoAutenticado():
return noAutenticado(_that);case SesionAutenticado():
return autenticado(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SesionNoAutenticado value)?  noAutenticado,TResult? Function( SesionAutenticado value)?  autenticado,}){
final _that = this;
switch (_that) {
case SesionNoAutenticado() when noAutenticado != null:
return noAutenticado(_that);case SesionAutenticado() when autenticado != null:
return autenticado(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  noAutenticado,TResult Function( Usuario usuario)?  autenticado,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SesionNoAutenticado() when noAutenticado != null:
return noAutenticado();case SesionAutenticado() when autenticado != null:
return autenticado(_that.usuario);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  noAutenticado,required TResult Function( Usuario usuario)  autenticado,}) {final _that = this;
switch (_that) {
case SesionNoAutenticado():
return noAutenticado();case SesionAutenticado():
return autenticado(_that.usuario);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  noAutenticado,TResult? Function( Usuario usuario)?  autenticado,}) {final _that = this;
switch (_that) {
case SesionNoAutenticado() when noAutenticado != null:
return noAutenticado();case SesionAutenticado() when autenticado != null:
return autenticado(_that.usuario);case _:
  return null;

}
}

}

/// @nodoc


class SesionNoAutenticado implements Sesion {
  const SesionNoAutenticado();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SesionNoAutenticado);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Sesion.noAutenticado()';
}


}




/// @nodoc


class SesionAutenticado implements Sesion {
  const SesionAutenticado(this.usuario);
  

 final  Usuario usuario;

/// Create a copy of Sesion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SesionAutenticadoCopyWith<SesionAutenticado> get copyWith => _$SesionAutenticadoCopyWithImpl<SesionAutenticado>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SesionAutenticado&&(identical(other.usuario, usuario) || other.usuario == usuario));
}


@override
int get hashCode => Object.hash(runtimeType,usuario);

@override
String toString() {
  return 'Sesion.autenticado(usuario: $usuario)';
}


}

/// @nodoc
abstract mixin class $SesionAutenticadoCopyWith<$Res> implements $SesionCopyWith<$Res> {
  factory $SesionAutenticadoCopyWith(SesionAutenticado value, $Res Function(SesionAutenticado) _then) = _$SesionAutenticadoCopyWithImpl;
@useResult
$Res call({
 Usuario usuario
});


$UsuarioCopyWith<$Res> get usuario;

}
/// @nodoc
class _$SesionAutenticadoCopyWithImpl<$Res>
    implements $SesionAutenticadoCopyWith<$Res> {
  _$SesionAutenticadoCopyWithImpl(this._self, this._then);

  final SesionAutenticado _self;
  final $Res Function(SesionAutenticado) _then;

/// Create a copy of Sesion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? usuario = null,}) {
  return _then(SesionAutenticado(
null == usuario ? _self.usuario : usuario // ignore: cast_nullable_to_non_nullable
as Usuario,
  ));
}

/// Create a copy of Sesion
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
