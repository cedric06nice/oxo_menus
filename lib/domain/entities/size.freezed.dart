// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'size.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Size {

 int get id; String get name; double get width; double get height; Status get status; String get direction;
/// Create a copy of Size
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SizeCopyWith<Size> get copyWith => _$SizeCopyWithImpl<Size>(this as Size, _$identity);

  /// Serializes this Size to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Size&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,width,height,status,direction);

@override
String toString() {
  return 'Size(id: $id, name: $name, width: $width, height: $height, status: $status, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $SizeCopyWith<$Res>  {
  factory $SizeCopyWith(Size value, $Res Function(Size) _then) = _$SizeCopyWithImpl;
@useResult
$Res call({
 int id, String name, double width, double height, Status status, String direction
});




}
/// @nodoc
class _$SizeCopyWithImpl<$Res>
    implements $SizeCopyWith<$Res> {
  _$SizeCopyWithImpl(this._self, this._then);

  final Size _self;
  final $Res Function(Size) _then;

/// Create a copy of Size
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? width = null,Object? height = null,Object? status = null,Object? direction = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Size].
extension SizePatterns on Size {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Size value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Size() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Size value)  $default,){
final _that = this;
switch (_that) {
case _Size():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Size value)?  $default,){
final _that = this;
switch (_that) {
case _Size() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  double width,  double height,  Status status,  String direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Size() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  double width,  double height,  Status status,  String direction)  $default,) {final _that = this;
switch (_that) {
case _Size():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  double width,  double height,  Status status,  String direction)?  $default,) {final _that = this;
switch (_that) {
case _Size() when $default != null:
return $default(_that.id,_that.name,_that.width,_that.height,_that.status,_that.direction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Size extends Size {
  const _Size({required this.id, required this.name, required this.width, required this.height, required this.status, required this.direction}): super._();
  factory _Size.fromJson(Map<String, dynamic> json) => _$SizeFromJson(json);

@override final  int id;
@override final  String name;
@override final  double width;
@override final  double height;
@override final  Status status;
@override final  String direction;

/// Create a copy of Size
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SizeCopyWith<_Size> get copyWith => __$SizeCopyWithImpl<_Size>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SizeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Size&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,width,height,status,direction);

@override
String toString() {
  return 'Size(id: $id, name: $name, width: $width, height: $height, status: $status, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$SizeCopyWith<$Res> implements $SizeCopyWith<$Res> {
  factory _$SizeCopyWith(_Size value, $Res Function(_Size) _then) = __$SizeCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, double width, double height, Status status, String direction
});




}
/// @nodoc
class __$SizeCopyWithImpl<$Res>
    implements _$SizeCopyWith<$Res> {
  __$SizeCopyWithImpl(this._self, this._then);

  final _Size _self;
  final $Res Function(_Size) _then;

/// Create a copy of Size
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? width = null,Object? height = null,Object? status = null,Object? direction = null,}) {
  return _then(_Size(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
