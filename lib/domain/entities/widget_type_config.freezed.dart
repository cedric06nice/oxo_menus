// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'widget_type_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WidgetTypeConfig {

 String get type; WidgetAlignment get alignment;/// Whether this widget type is currently available to regular users.
/// Admins can configure [alignment] without enabling the type.
 bool get enabled;
/// Create a copy of WidgetTypeConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetTypeConfigCopyWith<WidgetTypeConfig> get copyWith => _$WidgetTypeConfigCopyWithImpl<WidgetTypeConfig>(this as WidgetTypeConfig, _$identity);

  /// Serializes this WidgetTypeConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetTypeConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,alignment,enabled);

@override
String toString() {
  return 'WidgetTypeConfig(type: $type, alignment: $alignment, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $WidgetTypeConfigCopyWith<$Res>  {
  factory $WidgetTypeConfigCopyWith(WidgetTypeConfig value, $Res Function(WidgetTypeConfig) _then) = _$WidgetTypeConfigCopyWithImpl;
@useResult
$Res call({
 String type, WidgetAlignment alignment, bool enabled
});




}
/// @nodoc
class _$WidgetTypeConfigCopyWithImpl<$Res>
    implements $WidgetTypeConfigCopyWith<$Res> {
  _$WidgetTypeConfigCopyWithImpl(this._self, this._then);

  final WidgetTypeConfig _self;
  final $Res Function(WidgetTypeConfig) _then;

/// Create a copy of WidgetTypeConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? alignment = null,Object? enabled = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as WidgetAlignment,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WidgetTypeConfig].
extension WidgetTypeConfigPatterns on WidgetTypeConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetTypeConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetTypeConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetTypeConfig value)  $default,){
final _that = this;
switch (_that) {
case _WidgetTypeConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetTypeConfig value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetTypeConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  WidgetAlignment alignment,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetTypeConfig() when $default != null:
return $default(_that.type,_that.alignment,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  WidgetAlignment alignment,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _WidgetTypeConfig():
return $default(_that.type,_that.alignment,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  WidgetAlignment alignment,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _WidgetTypeConfig() when $default != null:
return $default(_that.type,_that.alignment,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WidgetTypeConfig extends WidgetTypeConfig {
  const _WidgetTypeConfig({required this.type, this.alignment = WidgetAlignment.start, this.enabled = true}): super._();
  factory _WidgetTypeConfig.fromJson(Map<String, dynamic> json) => _$WidgetTypeConfigFromJson(json);

@override final  String type;
@override@JsonKey() final  WidgetAlignment alignment;
/// Whether this widget type is currently available to regular users.
/// Admins can configure [alignment] without enabling the type.
@override@JsonKey() final  bool enabled;

/// Create a copy of WidgetTypeConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetTypeConfigCopyWith<_WidgetTypeConfig> get copyWith => __$WidgetTypeConfigCopyWithImpl<_WidgetTypeConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WidgetTypeConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetTypeConfig&&(identical(other.type, type) || other.type == type)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,alignment,enabled);

@override
String toString() {
  return 'WidgetTypeConfig(type: $type, alignment: $alignment, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$WidgetTypeConfigCopyWith<$Res> implements $WidgetTypeConfigCopyWith<$Res> {
  factory _$WidgetTypeConfigCopyWith(_WidgetTypeConfig value, $Res Function(_WidgetTypeConfig) _then) = __$WidgetTypeConfigCopyWithImpl;
@override @useResult
$Res call({
 String type, WidgetAlignment alignment, bool enabled
});




}
/// @nodoc
class __$WidgetTypeConfigCopyWithImpl<$Res>
    implements _$WidgetTypeConfigCopyWith<$Res> {
  __$WidgetTypeConfigCopyWithImpl(this._self, this._then);

  final _WidgetTypeConfig _self;
  final $Res Function(_WidgetTypeConfig) _then;

/// Create a copy of WidgetTypeConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? alignment = null,Object? enabled = null,}) {
  return _then(_WidgetTypeConfig(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as WidgetAlignment,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
