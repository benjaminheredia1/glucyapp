// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pagina_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginaApi<T> {

 List<T> get data;@JsonKey(name: 'current_page') int get paginaActual;@JsonKey(name: 'last_page') int get ultimaPagina; int get total;
/// Create a copy of PaginaApi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginaApiCopyWith<T, PaginaApi<T>> get copyWith => _$PaginaApiCopyWithImpl<T, PaginaApi<T>>(this as PaginaApi<T>, _$identity);

  /// Serializes this PaginaApi to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginaApi<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.paginaActual, paginaActual) || other.paginaActual == paginaActual)&&(identical(other.ultimaPagina, ultimaPagina) || other.ultimaPagina == ultimaPagina)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),paginaActual,ultimaPagina,total);

@override
String toString() {
  return 'PaginaApi<$T>(data: $data, paginaActual: $paginaActual, ultimaPagina: $ultimaPagina, total: $total)';
}


}

/// @nodoc
abstract mixin class $PaginaApiCopyWith<T,$Res>  {
  factory $PaginaApiCopyWith(PaginaApi<T> value, $Res Function(PaginaApi<T>) _then) = _$PaginaApiCopyWithImpl;
@useResult
$Res call({
 List<T> data,@JsonKey(name: 'current_page') int paginaActual,@JsonKey(name: 'last_page') int ultimaPagina, int total
});




}
/// @nodoc
class _$PaginaApiCopyWithImpl<T,$Res>
    implements $PaginaApiCopyWith<T, $Res> {
  _$PaginaApiCopyWithImpl(this._self, this._then);

  final PaginaApi<T> _self;
  final $Res Function(PaginaApi<T>) _then;

/// Create a copy of PaginaApi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? paginaActual = null,Object? ultimaPagina = null,Object? total = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<T>,paginaActual: null == paginaActual ? _self.paginaActual : paginaActual // ignore: cast_nullable_to_non_nullable
as int,ultimaPagina: null == ultimaPagina ? _self.ultimaPagina : ultimaPagina // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginaApi].
extension PaginaApiPatterns<T> on PaginaApi<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginaApi<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginaApi() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginaApi<T> value)  $default,){
final _that = this;
switch (_that) {
case _PaginaApi():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginaApi<T> value)?  $default,){
final _that = this;
switch (_that) {
case _PaginaApi() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> data, @JsonKey(name: 'current_page')  int paginaActual, @JsonKey(name: 'last_page')  int ultimaPagina,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginaApi() when $default != null:
return $default(_that.data,_that.paginaActual,_that.ultimaPagina,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> data, @JsonKey(name: 'current_page')  int paginaActual, @JsonKey(name: 'last_page')  int ultimaPagina,  int total)  $default,) {final _that = this;
switch (_that) {
case _PaginaApi():
return $default(_that.data,_that.paginaActual,_that.ultimaPagina,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> data, @JsonKey(name: 'current_page')  int paginaActual, @JsonKey(name: 'last_page')  int ultimaPagina,  int total)?  $default,) {final _that = this;
switch (_that) {
case _PaginaApi() when $default != null:
return $default(_that.data,_that.paginaActual,_that.ultimaPagina,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _PaginaApi<T> implements PaginaApi<T> {
  const _PaginaApi({required final  List<T> data, @JsonKey(name: 'current_page') required this.paginaActual, @JsonKey(name: 'last_page') required this.ultimaPagina, required this.total}): _data = data;
  factory _PaginaApi.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$PaginaApiFromJson(json,fromJsonT);

 final  List<T> _data;
@override List<T> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override@JsonKey(name: 'current_page') final  int paginaActual;
@override@JsonKey(name: 'last_page') final  int ultimaPagina;
@override final  int total;

/// Create a copy of PaginaApi
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginaApiCopyWith<T, _PaginaApi<T>> get copyWith => __$PaginaApiCopyWithImpl<T, _PaginaApi<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$PaginaApiToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginaApi<T>&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.paginaActual, paginaActual) || other.paginaActual == paginaActual)&&(identical(other.ultimaPagina, ultimaPagina) || other.ultimaPagina == ultimaPagina)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),paginaActual,ultimaPagina,total);

@override
String toString() {
  return 'PaginaApi<$T>(data: $data, paginaActual: $paginaActual, ultimaPagina: $ultimaPagina, total: $total)';
}


}

/// @nodoc
abstract mixin class _$PaginaApiCopyWith<T,$Res> implements $PaginaApiCopyWith<T, $Res> {
  factory _$PaginaApiCopyWith(_PaginaApi<T> value, $Res Function(_PaginaApi<T>) _then) = __$PaginaApiCopyWithImpl;
@override @useResult
$Res call({
 List<T> data,@JsonKey(name: 'current_page') int paginaActual,@JsonKey(name: 'last_page') int ultimaPagina, int total
});




}
/// @nodoc
class __$PaginaApiCopyWithImpl<T,$Res>
    implements _$PaginaApiCopyWith<T, $Res> {
  __$PaginaApiCopyWithImpl(this._self, this._then);

  final _PaginaApi<T> _self;
  final $Res Function(_PaginaApi<T>) _then;

/// Create a copy of PaginaApi
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? paginaActual = null,Object? ultimaPagina = null,Object? total = null,}) {
  return _then(_PaginaApi<T>(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<T>,paginaActual: null == paginaActual ? _self.paginaActual : paginaActual // ignore: cast_nullable_to_non_nullable
as int,ultimaPagina: null == ultimaPagina ? _self.ultimaPagina : ultimaPagina // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
