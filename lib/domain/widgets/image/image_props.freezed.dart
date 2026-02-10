// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageProps {

 String get fileId; String get align; String get fit; double? get width; double? get height;
/// Create a copy of ImageProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImagePropsCopyWith<ImageProps> get copyWith => _$ImagePropsCopyWithImpl<ImageProps>(this as ImageProps, _$identity);

  /// Serializes this ImageProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageProps&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.align, align) || other.align == align)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileId,align,fit,width,height);

@override
String toString() {
  return 'ImageProps(fileId: $fileId, align: $align, fit: $fit, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $ImagePropsCopyWith<$Res>  {
  factory $ImagePropsCopyWith(ImageProps value, $Res Function(ImageProps) _then) = _$ImagePropsCopyWithImpl;
@useResult
$Res call({
 String fileId, String align, String fit, double? width, double? height
});




}
/// @nodoc
class _$ImagePropsCopyWithImpl<$Res>
    implements $ImagePropsCopyWith<$Res> {
  _$ImagePropsCopyWithImpl(this._self, this._then);

  final ImageProps _self;
  final $Res Function(ImageProps) _then;

/// Create a copy of ImageProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileId = null,Object? align = null,Object? fit = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(_self.copyWith(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,align: null == align ? _self.align : align // ignore: cast_nullable_to_non_nullable
as String,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageProps].
extension ImagePropsPatterns on ImageProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageProps value)  $default,){
final _that = this;
switch (_that) {
case _ImageProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageProps value)?  $default,){
final _that = this;
switch (_that) {
case _ImageProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileId,  String align,  String fit,  double? width,  double? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageProps() when $default != null:
return $default(_that.fileId,_that.align,_that.fit,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileId,  String align,  String fit,  double? width,  double? height)  $default,) {final _that = this;
switch (_that) {
case _ImageProps():
return $default(_that.fileId,_that.align,_that.fit,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileId,  String align,  String fit,  double? width,  double? height)?  $default,) {final _that = this;
switch (_that) {
case _ImageProps() when $default != null:
return $default(_that.fileId,_that.align,_that.fit,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageProps extends ImageProps {
  const _ImageProps({required this.fileId, this.align = 'center', this.fit = 'contain', this.width, this.height}): super._();
  factory _ImageProps.fromJson(Map<String, dynamic> json) => _$ImagePropsFromJson(json);

@override final  String fileId;
@override@JsonKey() final  String align;
@override@JsonKey() final  String fit;
@override final  double? width;
@override final  double? height;

/// Create a copy of ImageProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImagePropsCopyWith<_ImageProps> get copyWith => __$ImagePropsCopyWithImpl<_ImageProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImagePropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageProps&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.align, align) || other.align == align)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileId,align,fit,width,height);

@override
String toString() {
  return 'ImageProps(fileId: $fileId, align: $align, fit: $fit, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$ImagePropsCopyWith<$Res> implements $ImagePropsCopyWith<$Res> {
  factory _$ImagePropsCopyWith(_ImageProps value, $Res Function(_ImageProps) _then) = __$ImagePropsCopyWithImpl;
@override @useResult
$Res call({
 String fileId, String align, String fit, double? width, double? height
});




}
/// @nodoc
class __$ImagePropsCopyWithImpl<$Res>
    implements _$ImagePropsCopyWith<$Res> {
  __$ImagePropsCopyWithImpl(this._self, this._then);

  final _ImageProps _self;
  final $Res Function(_ImageProps) _then;

/// Create a copy of ImageProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileId = null,Object? align = null,Object? fit = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(_ImageProps(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,align: null == align ? _self.align : align // ignore: cast_nullable_to_non_nullable
as String,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
