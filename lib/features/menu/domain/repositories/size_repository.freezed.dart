// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'size_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateSizeInput {

 String get name; double get width; double get height; Status get status; String get direction;
/// Create a copy of CreateSizeInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateSizeInputCopyWith<CreateSizeInput> get copyWith => _$CreateSizeInputCopyWithImpl<CreateSizeInput>(this as CreateSizeInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateSizeInput&&(identical(other.name, name) || other.name == name)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,name,width,height,status,direction);

@override
String toString() {
  return 'CreateSizeInput(name: $name, width: $width, height: $height, status: $status, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $CreateSizeInputCopyWith<$Res>  {
  factory $CreateSizeInputCopyWith(CreateSizeInput value, $Res Function(CreateSizeInput) _then) = _$CreateSizeInputCopyWithImpl;
@useResult
$Res call({
 String name, double width, double height, Status status, String direction
});




}
/// @nodoc
class _$CreateSizeInputCopyWithImpl<$Res>
    implements $CreateSizeInputCopyWith<$Res> {
  _$CreateSizeInputCopyWithImpl(this._self, this._then);

  final CreateSizeInput _self;
  final $Res Function(CreateSizeInput) _then;

/// Create a copy of CreateSizeInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? width = null,Object? height = null,Object? status = null,Object? direction = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateSizeInput].
extension CreateSizeInputPatterns on CreateSizeInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateSizeInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateSizeInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateSizeInput value)  $default,){
final _that = this;
switch (_that) {
case _CreateSizeInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateSizeInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreateSizeInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double width,  double height,  Status status,  String direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateSizeInput() when $default != null:
return $default(_that.name,_that.width,_that.height,_that.status,_that.direction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double width,  double height,  Status status,  String direction)  $default,) {final _that = this;
switch (_that) {
case _CreateSizeInput():
return $default(_that.name,_that.width,_that.height,_that.status,_that.direction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double width,  double height,  Status status,  String direction)?  $default,) {final _that = this;
switch (_that) {
case _CreateSizeInput() when $default != null:
return $default(_that.name,_that.width,_that.height,_that.status,_that.direction);case _:
  return null;

}
}

}

/// @nodoc


class _CreateSizeInput extends CreateSizeInput {
  const _CreateSizeInput({required this.name, required this.width, required this.height, required this.status, required this.direction}): super._();
  

@override final  String name;
@override final  double width;
@override final  double height;
@override final  Status status;
@override final  String direction;

/// Create a copy of CreateSizeInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateSizeInputCopyWith<_CreateSizeInput> get copyWith => __$CreateSizeInputCopyWithImpl<_CreateSizeInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateSizeInput&&(identical(other.name, name) || other.name == name)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,name,width,height,status,direction);

@override
String toString() {
  return 'CreateSizeInput(name: $name, width: $width, height: $height, status: $status, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$CreateSizeInputCopyWith<$Res> implements $CreateSizeInputCopyWith<$Res> {
  factory _$CreateSizeInputCopyWith(_CreateSizeInput value, $Res Function(_CreateSizeInput) _then) = __$CreateSizeInputCopyWithImpl;
@override @useResult
$Res call({
 String name, double width, double height, Status status, String direction
});




}
/// @nodoc
class __$CreateSizeInputCopyWithImpl<$Res>
    implements _$CreateSizeInputCopyWith<$Res> {
  __$CreateSizeInputCopyWithImpl(this._self, this._then);

  final _CreateSizeInput _self;
  final $Res Function(_CreateSizeInput) _then;

/// Create a copy of CreateSizeInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? width = null,Object? height = null,Object? status = null,Object? direction = null,}) {
  return _then(_CreateSizeInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$UpdateSizeInput {

 int get id; String? get name; double? get width; double? get height; Status? get status; String? get direction;
/// Create a copy of UpdateSizeInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateSizeInputCopyWith<UpdateSizeInput> get copyWith => _$UpdateSizeInputCopyWithImpl<UpdateSizeInput>(this as UpdateSizeInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateSizeInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,width,height,status,direction);

@override
String toString() {
  return 'UpdateSizeInput(id: $id, name: $name, width: $width, height: $height, status: $status, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $UpdateSizeInputCopyWith<$Res>  {
  factory $UpdateSizeInputCopyWith(UpdateSizeInput value, $Res Function(UpdateSizeInput) _then) = _$UpdateSizeInputCopyWithImpl;
@useResult
$Res call({
 int id, String? name, double? width, double? height, Status? status, String? direction
});




}
/// @nodoc
class _$UpdateSizeInputCopyWithImpl<$Res>
    implements $UpdateSizeInputCopyWith<$Res> {
  _$UpdateSizeInputCopyWithImpl(this._self, this._then);

  final UpdateSizeInput _self;
  final $Res Function(UpdateSizeInput) _then;

/// Create a copy of UpdateSizeInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? width = freezed,Object? height = freezed,Object? status = freezed,Object? direction = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateSizeInput].
extension UpdateSizeInputPatterns on UpdateSizeInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateSizeInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateSizeInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateSizeInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateSizeInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateSizeInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateSizeInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  double? width,  double? height,  Status? status,  String? direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateSizeInput() when $default != null:
return $default(_that.id,_that.name,_that.width,_that.height,_that.status,_that.direction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  double? width,  double? height,  Status? status,  String? direction)  $default,) {final _that = this;
switch (_that) {
case _UpdateSizeInput():
return $default(_that.id,_that.name,_that.width,_that.height,_that.status,_that.direction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  double? width,  double? height,  Status? status,  String? direction)?  $default,) {final _that = this;
switch (_that) {
case _UpdateSizeInput() when $default != null:
return $default(_that.id,_that.name,_that.width,_that.height,_that.status,_that.direction);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateSizeInput extends UpdateSizeInput {
  const _UpdateSizeInput({required this.id, this.name, this.width, this.height, this.status, this.direction}): super._();
  

@override final  int id;
@override final  String? name;
@override final  double? width;
@override final  double? height;
@override final  Status? status;
@override final  String? direction;

/// Create a copy of UpdateSizeInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateSizeInputCopyWith<_UpdateSizeInput> get copyWith => __$UpdateSizeInputCopyWithImpl<_UpdateSizeInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateSizeInput&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,width,height,status,direction);

@override
String toString() {
  return 'UpdateSizeInput(id: $id, name: $name, width: $width, height: $height, status: $status, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$UpdateSizeInputCopyWith<$Res> implements $UpdateSizeInputCopyWith<$Res> {
  factory _$UpdateSizeInputCopyWith(_UpdateSizeInput value, $Res Function(_UpdateSizeInput) _then) = __$UpdateSizeInputCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, double? width, double? height, Status? status, String? direction
});




}
/// @nodoc
class __$UpdateSizeInputCopyWithImpl<$Res>
    implements _$UpdateSizeInputCopyWith<$Res> {
  __$UpdateSizeInputCopyWithImpl(this._self, this._then);

  final _UpdateSizeInput _self;
  final $Res Function(_UpdateSizeInput) _then;

/// Create a copy of UpdateSizeInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? width = freezed,Object? height = freezed,Object? status = freezed,Object? direction = freezed,}) {
  return _then(_UpdateSizeInput(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
