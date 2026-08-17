// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usuario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Usuario {

 int get id; String get name;// Null mientras la cuenta sea temporal (identidad anonima): Auth0 aporta
// el correo al reclamarla.
 String? get email; Rol get rol;// Identidad creada por POST /auth/anonimo, todavia sin reclamar. Los
// JSON anteriores al contrato no lo traen: se asume cuenta real.
@JsonKey(defaultValue: false) bool get esTemporal; String? get apellidoPaterno; String? get apellidoMaterno; String? get telefono;@JsonKey(name: 'email_verified_at') DateTime? get emailVerificadoEn;
/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsuarioCopyWith<Usuario> get copyWith => _$UsuarioCopyWithImpl<Usuario>(this as Usuario, _$identity);

  /// Serializes this Usuario to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Usuario&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.esTemporal, esTemporal) || other.esTemporal == esTemporal)&&(identical(other.apellidoPaterno, apellidoPaterno) || other.apellidoPaterno == apellidoPaterno)&&(identical(other.apellidoMaterno, apellidoMaterno) || other.apellidoMaterno == apellidoMaterno)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.emailVerificadoEn, emailVerificadoEn) || other.emailVerificadoEn == emailVerificadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,rol,esTemporal,apellidoPaterno,apellidoMaterno,telefono,emailVerificadoEn);

@override
String toString() {
  return 'Usuario(id: $id, name: $name, email: $email, rol: $rol, esTemporal: $esTemporal, apellidoPaterno: $apellidoPaterno, apellidoMaterno: $apellidoMaterno, telefono: $telefono, emailVerificadoEn: $emailVerificadoEn)';
}


}

/// @nodoc
abstract mixin class $UsuarioCopyWith<$Res>  {
  factory $UsuarioCopyWith(Usuario value, $Res Function(Usuario) _then) = _$UsuarioCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? email, Rol rol,@JsonKey(defaultValue: false) bool esTemporal, String? apellidoPaterno, String? apellidoMaterno, String? telefono,@JsonKey(name: 'email_verified_at') DateTime? emailVerificadoEn
});




}
/// @nodoc
class _$UsuarioCopyWithImpl<$Res>
    implements $UsuarioCopyWith<$Res> {
  _$UsuarioCopyWithImpl(this._self, this._then);

  final Usuario _self;
  final $Res Function(Usuario) _then;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? rol = null,Object? esTemporal = null,Object? apellidoPaterno = freezed,Object? apellidoMaterno = freezed,Object? telefono = freezed,Object? emailVerificadoEn = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as Rol,esTemporal: null == esTemporal ? _self.esTemporal : esTemporal // ignore: cast_nullable_to_non_nullable
as bool,apellidoPaterno: freezed == apellidoPaterno ? _self.apellidoPaterno : apellidoPaterno // ignore: cast_nullable_to_non_nullable
as String?,apellidoMaterno: freezed == apellidoMaterno ? _self.apellidoMaterno : apellidoMaterno // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,emailVerificadoEn: freezed == emailVerificadoEn ? _self.emailVerificadoEn : emailVerificadoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Usuario].
extension UsuarioPatterns on Usuario {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Usuario value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Usuario() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Usuario value)  $default,){
final _that = this;
switch (_that) {
case _Usuario():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Usuario value)?  $default,){
final _that = this;
switch (_that) {
case _Usuario() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? email,  Rol rol, @JsonKey(defaultValue: false)  bool esTemporal,  String? apellidoPaterno,  String? apellidoMaterno,  String? telefono, @JsonKey(name: 'email_verified_at')  DateTime? emailVerificadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Usuario() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.rol,_that.esTemporal,_that.apellidoPaterno,_that.apellidoMaterno,_that.telefono,_that.emailVerificadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? email,  Rol rol, @JsonKey(defaultValue: false)  bool esTemporal,  String? apellidoPaterno,  String? apellidoMaterno,  String? telefono, @JsonKey(name: 'email_verified_at')  DateTime? emailVerificadoEn)  $default,) {final _that = this;
switch (_that) {
case _Usuario():
return $default(_that.id,_that.name,_that.email,_that.rol,_that.esTemporal,_that.apellidoPaterno,_that.apellidoMaterno,_that.telefono,_that.emailVerificadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? email,  Rol rol, @JsonKey(defaultValue: false)  bool esTemporal,  String? apellidoPaterno,  String? apellidoMaterno,  String? telefono, @JsonKey(name: 'email_verified_at')  DateTime? emailVerificadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Usuario() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.rol,_that.esTemporal,_that.apellidoPaterno,_that.apellidoMaterno,_that.telefono,_that.emailVerificadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Usuario implements Usuario {
  const _Usuario({required this.id, required this.name, this.email, required this.rol, @JsonKey(defaultValue: false) this.esTemporal = false, this.apellidoPaterno, this.apellidoMaterno, this.telefono, @JsonKey(name: 'email_verified_at') this.emailVerificadoEn});
  factory _Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);

@override final  int id;
@override final  String name;
// Null mientras la cuenta sea temporal (identidad anonima): Auth0 aporta
// el correo al reclamarla.
@override final  String? email;
@override final  Rol rol;
// Identidad creada por POST /auth/anonimo, todavia sin reclamar. Los
// JSON anteriores al contrato no lo traen: se asume cuenta real.
@override@JsonKey(defaultValue: false) final  bool esTemporal;
@override final  String? apellidoPaterno;
@override final  String? apellidoMaterno;
@override final  String? telefono;
@override@JsonKey(name: 'email_verified_at') final  DateTime? emailVerificadoEn;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsuarioCopyWith<_Usuario> get copyWith => __$UsuarioCopyWithImpl<_Usuario>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsuarioToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Usuario&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.esTemporal, esTemporal) || other.esTemporal == esTemporal)&&(identical(other.apellidoPaterno, apellidoPaterno) || other.apellidoPaterno == apellidoPaterno)&&(identical(other.apellidoMaterno, apellidoMaterno) || other.apellidoMaterno == apellidoMaterno)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.emailVerificadoEn, emailVerificadoEn) || other.emailVerificadoEn == emailVerificadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,rol,esTemporal,apellidoPaterno,apellidoMaterno,telefono,emailVerificadoEn);

@override
String toString() {
  return 'Usuario(id: $id, name: $name, email: $email, rol: $rol, esTemporal: $esTemporal, apellidoPaterno: $apellidoPaterno, apellidoMaterno: $apellidoMaterno, telefono: $telefono, emailVerificadoEn: $emailVerificadoEn)';
}


}

/// @nodoc
abstract mixin class _$UsuarioCopyWith<$Res> implements $UsuarioCopyWith<$Res> {
  factory _$UsuarioCopyWith(_Usuario value, $Res Function(_Usuario) _then) = __$UsuarioCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? email, Rol rol,@JsonKey(defaultValue: false) bool esTemporal, String? apellidoPaterno, String? apellidoMaterno, String? telefono,@JsonKey(name: 'email_verified_at') DateTime? emailVerificadoEn
});




}
/// @nodoc
class __$UsuarioCopyWithImpl<$Res>
    implements _$UsuarioCopyWith<$Res> {
  __$UsuarioCopyWithImpl(this._self, this._then);

  final _Usuario _self;
  final $Res Function(_Usuario) _then;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? rol = null,Object? esTemporal = null,Object? apellidoPaterno = freezed,Object? apellidoMaterno = freezed,Object? telefono = freezed,Object? emailVerificadoEn = freezed,}) {
  return _then(_Usuario(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as Rol,esTemporal: null == esTemporal ? _self.esTemporal : esTemporal // ignore: cast_nullable_to_non_nullable
as bool,apellidoPaterno: freezed == apellidoPaterno ? _self.apellidoPaterno : apellidoPaterno // ignore: cast_nullable_to_non_nullable
as String?,apellidoMaterno: freezed == apellidoMaterno ? _self.apellidoMaterno : apellidoMaterno // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,emailVerificadoEn: freezed == emailVerificadoEn ? _self.emailVerificadoEn : emailVerificadoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
