// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_file_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageFileInfo {

 String get id; String? get title; String? get type;
/// Create a copy of ImageFileInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageFileInfoCopyWith<ImageFileInfo> get copyWith => _$ImageFileInfoCopyWithImpl<ImageFileInfo>(this as ImageFileInfo, _$identity);

  /// Serializes this ImageFileInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageFileInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type);

@override
String toString() {
  return 'ImageFileInfo(id: $id, title: $title, type: $type)';
}


}

/// @nodoc
abstract mixin class $ImageFileInfoCopyWith<$Res>  {
  factory $ImageFileInfoCopyWith(ImageFileInfo value, $Res Function(ImageFileInfo) _then) = _$ImageFileInfoCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? type
});




}
/// @nodoc
class _$ImageFileInfoCopyWithImpl<$Res>
    implements $ImageFileInfoCopyWith<$Res> {
  _$ImageFileInfoCopyWithImpl(this._self, this._then);

  final ImageFileInfo _self;
  final $Res Function(ImageFileInfo) _then;

/// Create a copy of ImageFileInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageFileInfo].
extension ImageFileInfoPatterns on ImageFileInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageFileInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageFileInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageFileInfo value)  $default,){
final _that = this;
switch (_that) {
case _ImageFileInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageFileInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ImageFileInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageFileInfo() when $default != null:
return $default(_that.id,_that.title,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? type)  $default,) {final _that = this;
switch (_that) {
case _ImageFileInfo():
return $default(_that.id,_that.title,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _ImageFileInfo() when $default != null:
return $default(_that.id,_that.title,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageFileInfo extends ImageFileInfo {
  const _ImageFileInfo({required this.id, this.title, this.type}): super._();
  factory _ImageFileInfo.fromJson(Map<String, dynamic> json) => _$ImageFileInfoFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? type;

/// Create a copy of ImageFileInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageFileInfoCopyWith<_ImageFileInfo> get copyWith => __$ImageFileInfoCopyWithImpl<_ImageFileInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageFileInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageFileInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type);

@override
String toString() {
  return 'ImageFileInfo(id: $id, title: $title, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ImageFileInfoCopyWith<$Res> implements $ImageFileInfoCopyWith<$Res> {
  factory _$ImageFileInfoCopyWith(_ImageFileInfo value, $Res Function(_ImageFileInfo) _then) = __$ImageFileInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? type
});




}
/// @nodoc
class __$ImageFileInfoCopyWithImpl<$Res>
    implements _$ImageFileInfoCopyWith<$Res> {
  __$ImageFileInfoCopyWithImpl(this._self, this._then);

  final _ImageFileInfo _self;
  final $Res Function(_ImageFileInfo) _then;

/// Create a copy of ImageFileInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? type = freezed,}) {
  return _then(_ImageFileInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
