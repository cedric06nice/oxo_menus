// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'widget_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WidgetInstance {

 String get id; String get columnId; String get type; String get version; int get index; Map<String, dynamic> get props; WidgetStyle? get style; DateTime? get dateCreated; DateTime? get dateUpdated;
/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetInstanceCopyWith<WidgetInstance> get copyWith => _$WidgetInstanceCopyWithImpl<WidgetInstance>(this as WidgetInstance, _$identity);

  /// Serializes this WidgetInstance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other.props, props)&&(identical(other.style, style) || other.style == style)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,columnId,type,version,index,const DeepCollectionEquality().hash(props),style,dateCreated,dateUpdated);

@override
String toString() {
  return 'WidgetInstance(id: $id, columnId: $columnId, type: $type, version: $version, index: $index, props: $props, style: $style, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
}


}

/// @nodoc
abstract mixin class $WidgetInstanceCopyWith<$Res>  {
  factory $WidgetInstanceCopyWith(WidgetInstance value, $Res Function(WidgetInstance) _then) = _$WidgetInstanceCopyWithImpl;
@useResult
$Res call({
 String id, String columnId, String type, String version, int index, Map<String, dynamic> props, WidgetStyle? style, DateTime? dateCreated, DateTime? dateUpdated
});


$WidgetStyleCopyWith<$Res>? get style;

}
/// @nodoc
class _$WidgetInstanceCopyWithImpl<$Res>
    implements $WidgetInstanceCopyWith<$Res> {
  _$WidgetInstanceCopyWithImpl(this._self, this._then);

  final WidgetInstance _self;
  final $Res Function(WidgetInstance) _then;

/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? columnId = null,Object? type = null,Object? version = null,Object? index = null,Object? props = null,Object? style = freezed,Object? dateCreated = freezed,Object? dateUpdated = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,props: null == props ? _self.props : props // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as WidgetStyle?,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WidgetStyleCopyWith<$Res>? get style {
    if (_self.style == null) {
    return null;
  }

  return $WidgetStyleCopyWith<$Res>(_self.style!, (value) {
    return _then(_self.copyWith(style: value));
  });
}
}


/// Adds pattern-matching-related methods to [WidgetInstance].
extension WidgetInstancePatterns on WidgetInstance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetInstance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetInstance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetInstance value)  $default,){
final _that = this;
switch (_that) {
case _WidgetInstance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetInstance value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetInstance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String columnId,  String type,  String version,  int index,  Map<String, dynamic> props,  WidgetStyle? style,  DateTime? dateCreated,  DateTime? dateUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetInstance() when $default != null:
return $default(_that.id,_that.columnId,_that.type,_that.version,_that.index,_that.props,_that.style,_that.dateCreated,_that.dateUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String columnId,  String type,  String version,  int index,  Map<String, dynamic> props,  WidgetStyle? style,  DateTime? dateCreated,  DateTime? dateUpdated)  $default,) {final _that = this;
switch (_that) {
case _WidgetInstance():
return $default(_that.id,_that.columnId,_that.type,_that.version,_that.index,_that.props,_that.style,_that.dateCreated,_that.dateUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String columnId,  String type,  String version,  int index,  Map<String, dynamic> props,  WidgetStyle? style,  DateTime? dateCreated,  DateTime? dateUpdated)?  $default,) {final _that = this;
switch (_that) {
case _WidgetInstance() when $default != null:
return $default(_that.id,_that.columnId,_that.type,_that.version,_that.index,_that.props,_that.style,_that.dateCreated,_that.dateUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WidgetInstance extends WidgetInstance {
  const _WidgetInstance({required this.id, required this.columnId, required this.type, required this.version, required this.index, required final  Map<String, dynamic> props, this.style, this.dateCreated, this.dateUpdated}): _props = props,super._();
  factory _WidgetInstance.fromJson(Map<String, dynamic> json) => _$WidgetInstanceFromJson(json);

@override final  String id;
@override final  String columnId;
@override final  String type;
@override final  String version;
@override final  int index;
 final  Map<String, dynamic> _props;
@override Map<String, dynamic> get props {
  if (_props is EqualUnmodifiableMapView) return _props;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_props);
}

@override final  WidgetStyle? style;
@override final  DateTime? dateCreated;
@override final  DateTime? dateUpdated;

/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetInstanceCopyWith<_WidgetInstance> get copyWith => __$WidgetInstanceCopyWithImpl<_WidgetInstance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WidgetInstanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other._props, _props)&&(identical(other.style, style) || other.style == style)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,columnId,type,version,index,const DeepCollectionEquality().hash(_props),style,dateCreated,dateUpdated);

@override
String toString() {
  return 'WidgetInstance(id: $id, columnId: $columnId, type: $type, version: $version, index: $index, props: $props, style: $style, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
}


}

/// @nodoc
abstract mixin class _$WidgetInstanceCopyWith<$Res> implements $WidgetInstanceCopyWith<$Res> {
  factory _$WidgetInstanceCopyWith(_WidgetInstance value, $Res Function(_WidgetInstance) _then) = __$WidgetInstanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String columnId, String type, String version, int index, Map<String, dynamic> props, WidgetStyle? style, DateTime? dateCreated, DateTime? dateUpdated
});


@override $WidgetStyleCopyWith<$Res>? get style;

}
/// @nodoc
class __$WidgetInstanceCopyWithImpl<$Res>
    implements _$WidgetInstanceCopyWith<$Res> {
  __$WidgetInstanceCopyWithImpl(this._self, this._then);

  final _WidgetInstance _self;
  final $Res Function(_WidgetInstance) _then;

/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? columnId = null,Object? type = null,Object? version = null,Object? index = null,Object? props = null,Object? style = freezed,Object? dateCreated = freezed,Object? dateUpdated = freezed,}) {
  return _then(_WidgetInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,props: null == props ? _self._props : props // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as WidgetStyle?,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of WidgetInstance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WidgetStyleCopyWith<$Res>? get style {
    if (_self.style == null) {
    return null;
  }

  return $WidgetStyleCopyWith<$Res>(_self.style!, (value) {
    return _then(_self.copyWith(style: value));
  });
}
}


/// @nodoc
mixin _$WidgetStyle {

 String? get fontFamily; double? get fontSize; String? get color; String? get backgroundColor; String? get border; double? get padding;
/// Create a copy of WidgetStyle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetStyleCopyWith<WidgetStyle> get copyWith => _$WidgetStyleCopyWithImpl<WidgetStyle>(this as WidgetStyle, _$identity);

  /// Serializes this WidgetStyle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetStyle&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.color, color) || other.color == color)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.border, border) || other.border == border)&&(identical(other.padding, padding) || other.padding == padding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fontFamily,fontSize,color,backgroundColor,border,padding);

@override
String toString() {
  return 'WidgetStyle(fontFamily: $fontFamily, fontSize: $fontSize, color: $color, backgroundColor: $backgroundColor, border: $border, padding: $padding)';
}


}

/// @nodoc
abstract mixin class $WidgetStyleCopyWith<$Res>  {
  factory $WidgetStyleCopyWith(WidgetStyle value, $Res Function(WidgetStyle) _then) = _$WidgetStyleCopyWithImpl;
@useResult
$Res call({
 String? fontFamily, double? fontSize, String? color, String? backgroundColor, String? border, double? padding
});




}
/// @nodoc
class _$WidgetStyleCopyWithImpl<$Res>
    implements $WidgetStyleCopyWith<$Res> {
  _$WidgetStyleCopyWithImpl(this._self, this._then);

  final WidgetStyle _self;
  final $Res Function(WidgetStyle) _then;

/// Create a copy of WidgetStyle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fontFamily = freezed,Object? fontSize = freezed,Object? color = freezed,Object? backgroundColor = freezed,Object? border = freezed,Object? padding = freezed,}) {
  return _then(_self.copyWith(
fontFamily: freezed == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String?,fontSize: freezed == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,border: freezed == border ? _self.border : border // ignore: cast_nullable_to_non_nullable
as String?,padding: freezed == padding ? _self.padding : padding // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WidgetStyle].
extension WidgetStylePatterns on WidgetStyle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetStyle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetStyle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetStyle value)  $default,){
final _that = this;
switch (_that) {
case _WidgetStyle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetStyle value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetStyle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? fontFamily,  double? fontSize,  String? color,  String? backgroundColor,  String? border,  double? padding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetStyle() when $default != null:
return $default(_that.fontFamily,_that.fontSize,_that.color,_that.backgroundColor,_that.border,_that.padding);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? fontFamily,  double? fontSize,  String? color,  String? backgroundColor,  String? border,  double? padding)  $default,) {final _that = this;
switch (_that) {
case _WidgetStyle():
return $default(_that.fontFamily,_that.fontSize,_that.color,_that.backgroundColor,_that.border,_that.padding);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? fontFamily,  double? fontSize,  String? color,  String? backgroundColor,  String? border,  double? padding)?  $default,) {final _that = this;
switch (_that) {
case _WidgetStyle() when $default != null:
return $default(_that.fontFamily,_that.fontSize,_that.color,_that.backgroundColor,_that.border,_that.padding);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WidgetStyle extends WidgetStyle {
  const _WidgetStyle({this.fontFamily, this.fontSize, this.color, this.backgroundColor, this.border, this.padding}): super._();
  factory _WidgetStyle.fromJson(Map<String, dynamic> json) => _$WidgetStyleFromJson(json);

@override final  String? fontFamily;
@override final  double? fontSize;
@override final  String? color;
@override final  String? backgroundColor;
@override final  String? border;
@override final  double? padding;

/// Create a copy of WidgetStyle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetStyleCopyWith<_WidgetStyle> get copyWith => __$WidgetStyleCopyWithImpl<_WidgetStyle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WidgetStyleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetStyle&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.color, color) || other.color == color)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.border, border) || other.border == border)&&(identical(other.padding, padding) || other.padding == padding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fontFamily,fontSize,color,backgroundColor,border,padding);

@override
String toString() {
  return 'WidgetStyle(fontFamily: $fontFamily, fontSize: $fontSize, color: $color, backgroundColor: $backgroundColor, border: $border, padding: $padding)';
}


}

/// @nodoc
abstract mixin class _$WidgetStyleCopyWith<$Res> implements $WidgetStyleCopyWith<$Res> {
  factory _$WidgetStyleCopyWith(_WidgetStyle value, $Res Function(_WidgetStyle) _then) = __$WidgetStyleCopyWithImpl;
@override @useResult
$Res call({
 String? fontFamily, double? fontSize, String? color, String? backgroundColor, String? border, double? padding
});




}
/// @nodoc
class __$WidgetStyleCopyWithImpl<$Res>
    implements _$WidgetStyleCopyWith<$Res> {
  __$WidgetStyleCopyWithImpl(this._self, this._then);

  final _WidgetStyle _self;
  final $Res Function(_WidgetStyle) _then;

/// Create a copy of WidgetStyle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fontFamily = freezed,Object? fontSize = freezed,Object? color = freezed,Object? backgroundColor = freezed,Object? border = freezed,Object? padding = freezed,}) {
  return _then(_WidgetStyle(
fontFamily: freezed == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String?,fontSize: freezed == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,border: freezed == border ? _self.border : border // ignore: cast_nullable_to_non_nullable
as String?,padding: freezed == padding ? _self.padding : padding // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
