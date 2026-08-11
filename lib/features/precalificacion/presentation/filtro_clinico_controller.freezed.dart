// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filtro_clinico_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EstadoFiltro {

 List<PreguntaFiltro> get preguntas; Map<int, bool> get respuestas; String? get leadEmail;// Fallo de un `enviar()` anterior, para pintar un aviso sin tirar las
// respuestas ya dadas. Es de la pantalla, no de dominio: no viaja a la
// API ni se compara en tests salvo por su presencia.
 Object? get errorEnvio;
/// Create a copy of EstadoFiltro
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstadoFiltroCopyWith<EstadoFiltro> get copyWith => _$EstadoFiltroCopyWithImpl<EstadoFiltro>(this as EstadoFiltro, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstadoFiltro&&const DeepCollectionEquality().equals(other.preguntas, preguntas)&&const DeepCollectionEquality().equals(other.respuestas, respuestas)&&(identical(other.leadEmail, leadEmail) || other.leadEmail == leadEmail)&&const DeepCollectionEquality().equals(other.errorEnvio, errorEnvio));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(preguntas),const DeepCollectionEquality().hash(respuestas),leadEmail,const DeepCollectionEquality().hash(errorEnvio));

@override
String toString() {
  return 'EstadoFiltro(preguntas: $preguntas, respuestas: $respuestas, leadEmail: $leadEmail, errorEnvio: $errorEnvio)';
}


}

/// @nodoc
abstract mixin class $EstadoFiltroCopyWith<$Res>  {
  factory $EstadoFiltroCopyWith(EstadoFiltro value, $Res Function(EstadoFiltro) _then) = _$EstadoFiltroCopyWithImpl;
@useResult
$Res call({
 List<PreguntaFiltro> preguntas, Map<int, bool> respuestas, String? leadEmail, Object? errorEnvio
});




}
/// @nodoc
class _$EstadoFiltroCopyWithImpl<$Res>
    implements $EstadoFiltroCopyWith<$Res> {
  _$EstadoFiltroCopyWithImpl(this._self, this._then);

  final EstadoFiltro _self;
  final $Res Function(EstadoFiltro) _then;

/// Create a copy of EstadoFiltro
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preguntas = null,Object? respuestas = null,Object? leadEmail = freezed,Object? errorEnvio = freezed,}) {
  return _then(_self.copyWith(
preguntas: null == preguntas ? _self.preguntas : preguntas // ignore: cast_nullable_to_non_nullable
as List<PreguntaFiltro>,respuestas: null == respuestas ? _self.respuestas : respuestas // ignore: cast_nullable_to_non_nullable
as Map<int, bool>,leadEmail: freezed == leadEmail ? _self.leadEmail : leadEmail // ignore: cast_nullable_to_non_nullable
as String?,errorEnvio: freezed == errorEnvio ? _self.errorEnvio : errorEnvio ,
  ));
}

}


/// Adds pattern-matching-related methods to [EstadoFiltro].
extension EstadoFiltroPatterns on EstadoFiltro {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstadoFiltro value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstadoFiltro() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstadoFiltro value)  $default,){
final _that = this;
switch (_that) {
case _EstadoFiltro():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstadoFiltro value)?  $default,){
final _that = this;
switch (_that) {
case _EstadoFiltro() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PreguntaFiltro> preguntas,  Map<int, bool> respuestas,  String? leadEmail,  Object? errorEnvio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstadoFiltro() when $default != null:
return $default(_that.preguntas,_that.respuestas,_that.leadEmail,_that.errorEnvio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PreguntaFiltro> preguntas,  Map<int, bool> respuestas,  String? leadEmail,  Object? errorEnvio)  $default,) {final _that = this;
switch (_that) {
case _EstadoFiltro():
return $default(_that.preguntas,_that.respuestas,_that.leadEmail,_that.errorEnvio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PreguntaFiltro> preguntas,  Map<int, bool> respuestas,  String? leadEmail,  Object? errorEnvio)?  $default,) {final _that = this;
switch (_that) {
case _EstadoFiltro() when $default != null:
return $default(_that.preguntas,_that.respuestas,_that.leadEmail,_that.errorEnvio);case _:
  return null;

}
}

}

/// @nodoc


class _EstadoFiltro extends EstadoFiltro {
  const _EstadoFiltro({required final  List<PreguntaFiltro> preguntas, required final  Map<int, bool> respuestas, this.leadEmail, this.errorEnvio}): _preguntas = preguntas,_respuestas = respuestas,super._();
  

 final  List<PreguntaFiltro> _preguntas;
@override List<PreguntaFiltro> get preguntas {
  if (_preguntas is EqualUnmodifiableListView) return _preguntas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preguntas);
}

 final  Map<int, bool> _respuestas;
@override Map<int, bool> get respuestas {
  if (_respuestas is EqualUnmodifiableMapView) return _respuestas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_respuestas);
}

@override final  String? leadEmail;
// Fallo de un `enviar()` anterior, para pintar un aviso sin tirar las
// respuestas ya dadas. Es de la pantalla, no de dominio: no viaja a la
// API ni se compara en tests salvo por su presencia.
@override final  Object? errorEnvio;

/// Create a copy of EstadoFiltro
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstadoFiltroCopyWith<_EstadoFiltro> get copyWith => __$EstadoFiltroCopyWithImpl<_EstadoFiltro>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstadoFiltro&&const DeepCollectionEquality().equals(other._preguntas, _preguntas)&&const DeepCollectionEquality().equals(other._respuestas, _respuestas)&&(identical(other.leadEmail, leadEmail) || other.leadEmail == leadEmail)&&const DeepCollectionEquality().equals(other.errorEnvio, errorEnvio));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_preguntas),const DeepCollectionEquality().hash(_respuestas),leadEmail,const DeepCollectionEquality().hash(errorEnvio));

@override
String toString() {
  return 'EstadoFiltro(preguntas: $preguntas, respuestas: $respuestas, leadEmail: $leadEmail, errorEnvio: $errorEnvio)';
}


}

/// @nodoc
abstract mixin class _$EstadoFiltroCopyWith<$Res> implements $EstadoFiltroCopyWith<$Res> {
  factory _$EstadoFiltroCopyWith(_EstadoFiltro value, $Res Function(_EstadoFiltro) _then) = __$EstadoFiltroCopyWithImpl;
@override @useResult
$Res call({
 List<PreguntaFiltro> preguntas, Map<int, bool> respuestas, String? leadEmail, Object? errorEnvio
});




}
/// @nodoc
class __$EstadoFiltroCopyWithImpl<$Res>
    implements _$EstadoFiltroCopyWith<$Res> {
  __$EstadoFiltroCopyWithImpl(this._self, this._then);

  final _EstadoFiltro _self;
  final $Res Function(_EstadoFiltro) _then;

/// Create a copy of EstadoFiltro
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preguntas = null,Object? respuestas = null,Object? leadEmail = freezed,Object? errorEnvio = freezed,}) {
  return _then(_EstadoFiltro(
preguntas: null == preguntas ? _self._preguntas : preguntas // ignore: cast_nullable_to_non_nullable
as List<PreguntaFiltro>,respuestas: null == respuestas ? _self._respuestas : respuestas // ignore: cast_nullable_to_non_nullable
as Map<int, bool>,leadEmail: freezed == leadEmail ? _self.leadEmail : leadEmail // ignore: cast_nullable_to_non_nullable
as String?,errorEnvio: freezed == errorEnvio ? _self.errorEnvio : errorEnvio ,
  ));
}


}

// dart format on
