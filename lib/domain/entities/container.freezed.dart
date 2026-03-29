// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Container {

 int get id; int get pageId; int get index; String? get name; int? get parentContainerId; LayoutConfig? get layout; StyleConfig? get styleConfig; DateTime? get dateCreated; DateTime? get dateUpdated;
/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerCopyWith<Container> get copyWith => _$ContainerCopyWithImpl<Container>(this as Container, _$identity);

  /// Serializes this Container to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Container&&(identical(other.id, id) || other.id == id)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentContainerId, parentContainerId) || other.parentContainerId == parentContainerId)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pageId,index,name,parentContainerId,layout,styleConfig,dateCreated,dateUpdated);

@override
String toString() {
  return 'Container(id: $id, pageId: $pageId, index: $index, name: $name, parentContainerId: $parentContainerId, layout: $layout, styleConfig: $styleConfig, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
}


}

/// @nodoc
abstract mixin class $ContainerCopyWith<$Res>  {
  factory $ContainerCopyWith(Container value, $Res Function(Container) _then) = _$ContainerCopyWithImpl;
@useResult
$Res call({
 int id, int pageId, int index, String? name, int? parentContainerId, LayoutConfig? layout, StyleConfig? styleConfig, DateTime? dateCreated, DateTime? dateUpdated
});


$LayoutConfigCopyWith<$Res>? get layout;$StyleConfigCopyWith<$Res>? get styleConfig;

}
/// @nodoc
class _$ContainerCopyWithImpl<$Res>
    implements $ContainerCopyWith<$Res> {
  _$ContainerCopyWithImpl(this._self, this._then);

  final Container _self;
  final $Res Function(Container) _then;

/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pageId = null,Object? index = null,Object? name = freezed,Object? parentContainerId = freezed,Object? layout = freezed,Object? styleConfig = freezed,Object? dateCreated = freezed,Object? dateUpdated = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,parentContainerId: freezed == parentContainerId ? _self.parentContainerId : parentContainerId // ignore: cast_nullable_to_non_nullable
as int?,layout: freezed == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as LayoutConfig?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LayoutConfigCopyWith<$Res>? get layout {
    if (_self.layout == null) {
    return null;
  }

  return $LayoutConfigCopyWith<$Res>(_self.layout!, (value) {
    return _then(_self.copyWith(layout: value));
  });
}/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get styleConfig {
    if (_self.styleConfig == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.styleConfig!, (value) {
    return _then(_self.copyWith(styleConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [Container].
extension ContainerPatterns on Container {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Container value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Container() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Container value)  $default,){
final _that = this;
switch (_that) {
case _Container():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Container value)?  $default,){
final _that = this;
switch (_that) {
case _Container() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int pageId,  int index,  String? name,  int? parentContainerId,  LayoutConfig? layout,  StyleConfig? styleConfig,  DateTime? dateCreated,  DateTime? dateUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Container() when $default != null:
return $default(_that.id,_that.pageId,_that.index,_that.name,_that.parentContainerId,_that.layout,_that.styleConfig,_that.dateCreated,_that.dateUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int pageId,  int index,  String? name,  int? parentContainerId,  LayoutConfig? layout,  StyleConfig? styleConfig,  DateTime? dateCreated,  DateTime? dateUpdated)  $default,) {final _that = this;
switch (_that) {
case _Container():
return $default(_that.id,_that.pageId,_that.index,_that.name,_that.parentContainerId,_that.layout,_that.styleConfig,_that.dateCreated,_that.dateUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int pageId,  int index,  String? name,  int? parentContainerId,  LayoutConfig? layout,  StyleConfig? styleConfig,  DateTime? dateCreated,  DateTime? dateUpdated)?  $default,) {final _that = this;
switch (_that) {
case _Container() when $default != null:
return $default(_that.id,_that.pageId,_that.index,_that.name,_that.parentContainerId,_that.layout,_that.styleConfig,_that.dateCreated,_that.dateUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Container extends Container {
  const _Container({required this.id, required this.pageId, required this.index, this.name, this.parentContainerId, this.layout, this.styleConfig, this.dateCreated, this.dateUpdated}): super._();
  factory _Container.fromJson(Map<String, dynamic> json) => _$ContainerFromJson(json);

@override final  int id;
@override final  int pageId;
@override final  int index;
@override final  String? name;
@override final  int? parentContainerId;
@override final  LayoutConfig? layout;
@override final  StyleConfig? styleConfig;
@override final  DateTime? dateCreated;
@override final  DateTime? dateUpdated;

/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerCopyWith<_Container> get copyWith => __$ContainerCopyWithImpl<_Container>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Container&&(identical(other.id, id) || other.id == id)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentContainerId, parentContainerId) || other.parentContainerId == parentContainerId)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pageId,index,name,parentContainerId,layout,styleConfig,dateCreated,dateUpdated);

@override
String toString() {
  return 'Container(id: $id, pageId: $pageId, index: $index, name: $name, parentContainerId: $parentContainerId, layout: $layout, styleConfig: $styleConfig, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
}


}

/// @nodoc
abstract mixin class _$ContainerCopyWith<$Res> implements $ContainerCopyWith<$Res> {
  factory _$ContainerCopyWith(_Container value, $Res Function(_Container) _then) = __$ContainerCopyWithImpl;
@override @useResult
$Res call({
 int id, int pageId, int index, String? name, int? parentContainerId, LayoutConfig? layout, StyleConfig? styleConfig, DateTime? dateCreated, DateTime? dateUpdated
});


@override $LayoutConfigCopyWith<$Res>? get layout;@override $StyleConfigCopyWith<$Res>? get styleConfig;

}
/// @nodoc
class __$ContainerCopyWithImpl<$Res>
    implements _$ContainerCopyWith<$Res> {
  __$ContainerCopyWithImpl(this._self, this._then);

  final _Container _self;
  final $Res Function(_Container) _then;

/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pageId = null,Object? index = null,Object? name = freezed,Object? parentContainerId = freezed,Object? layout = freezed,Object? styleConfig = freezed,Object? dateCreated = freezed,Object? dateUpdated = freezed,}) {
  return _then(_Container(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,parentContainerId: freezed == parentContainerId ? _self.parentContainerId : parentContainerId // ignore: cast_nullable_to_non_nullable
as int?,layout: freezed == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as LayoutConfig?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LayoutConfigCopyWith<$Res>? get layout {
    if (_self.layout == null) {
    return null;
  }

  return $LayoutConfigCopyWith<$Res>(_self.layout!, (value) {
    return _then(_self.copyWith(layout: value));
  });
}/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<$Res>? get styleConfig {
    if (_self.styleConfig == null) {
    return null;
  }

  return $StyleConfigCopyWith<$Res>(_self.styleConfig!, (value) {
    return _then(_self.copyWith(styleConfig: value));
  });
}
}


/// @nodoc
mixin _$LayoutConfig {

 String? get direction; String? get alignment; String? get mainAxisAlignment; double? get spacing;
/// Create a copy of LayoutConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LayoutConfigCopyWith<LayoutConfig> get copyWith => _$LayoutConfigCopyWithImpl<LayoutConfig>(this as LayoutConfig, _$identity);

  /// Serializes this LayoutConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LayoutConfig&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.mainAxisAlignment, mainAxisAlignment) || other.mainAxisAlignment == mainAxisAlignment)&&(identical(other.spacing, spacing) || other.spacing == spacing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,direction,alignment,mainAxisAlignment,spacing);

@override
String toString() {
  return 'LayoutConfig(direction: $direction, alignment: $alignment, mainAxisAlignment: $mainAxisAlignment, spacing: $spacing)';
}


}

/// @nodoc
abstract mixin class $LayoutConfigCopyWith<$Res>  {
  factory $LayoutConfigCopyWith(LayoutConfig value, $Res Function(LayoutConfig) _then) = _$LayoutConfigCopyWithImpl;
@useResult
$Res call({
 String? direction, String? alignment, String? mainAxisAlignment, double? spacing
});




}
/// @nodoc
class _$LayoutConfigCopyWithImpl<$Res>
    implements $LayoutConfigCopyWith<$Res> {
  _$LayoutConfigCopyWithImpl(this._self, this._then);

  final LayoutConfig _self;
  final $Res Function(LayoutConfig) _then;

/// Create a copy of LayoutConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? direction = freezed,Object? alignment = freezed,Object? mainAxisAlignment = freezed,Object? spacing = freezed,}) {
  return _then(_self.copyWith(
direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,alignment: freezed == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as String?,mainAxisAlignment: freezed == mainAxisAlignment ? _self.mainAxisAlignment : mainAxisAlignment // ignore: cast_nullable_to_non_nullable
as String?,spacing: freezed == spacing ? _self.spacing : spacing // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [LayoutConfig].
extension LayoutConfigPatterns on LayoutConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LayoutConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LayoutConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LayoutConfig value)  $default,){
final _that = this;
switch (_that) {
case _LayoutConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LayoutConfig value)?  $default,){
final _that = this;
switch (_that) {
case _LayoutConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? direction,  String? alignment,  String? mainAxisAlignment,  double? spacing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LayoutConfig() when $default != null:
return $default(_that.direction,_that.alignment,_that.mainAxisAlignment,_that.spacing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? direction,  String? alignment,  String? mainAxisAlignment,  double? spacing)  $default,) {final _that = this;
switch (_that) {
case _LayoutConfig():
return $default(_that.direction,_that.alignment,_that.mainAxisAlignment,_that.spacing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? direction,  String? alignment,  String? mainAxisAlignment,  double? spacing)?  $default,) {final _that = this;
switch (_that) {
case _LayoutConfig() when $default != null:
return $default(_that.direction,_that.alignment,_that.mainAxisAlignment,_that.spacing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LayoutConfig extends LayoutConfig {
  const _LayoutConfig({this.direction, this.alignment, this.mainAxisAlignment, this.spacing}): super._();
  factory _LayoutConfig.fromJson(Map<String, dynamic> json) => _$LayoutConfigFromJson(json);

@override final  String? direction;
@override final  String? alignment;
@override final  String? mainAxisAlignment;
@override final  double? spacing;

/// Create a copy of LayoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LayoutConfigCopyWith<_LayoutConfig> get copyWith => __$LayoutConfigCopyWithImpl<_LayoutConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LayoutConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LayoutConfig&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.mainAxisAlignment, mainAxisAlignment) || other.mainAxisAlignment == mainAxisAlignment)&&(identical(other.spacing, spacing) || other.spacing == spacing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,direction,alignment,mainAxisAlignment,spacing);

@override
String toString() {
  return 'LayoutConfig(direction: $direction, alignment: $alignment, mainAxisAlignment: $mainAxisAlignment, spacing: $spacing)';
}


}

/// @nodoc
abstract mixin class _$LayoutConfigCopyWith<$Res> implements $LayoutConfigCopyWith<$Res> {
  factory _$LayoutConfigCopyWith(_LayoutConfig value, $Res Function(_LayoutConfig) _then) = __$LayoutConfigCopyWithImpl;
@override @useResult
$Res call({
 String? direction, String? alignment, String? mainAxisAlignment, double? spacing
});




}
/// @nodoc
class __$LayoutConfigCopyWithImpl<$Res>
    implements _$LayoutConfigCopyWith<$Res> {
  __$LayoutConfigCopyWithImpl(this._self, this._then);

  final _LayoutConfig _self;
  final $Res Function(_LayoutConfig) _then;

/// Create a copy of LayoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? direction = freezed,Object? alignment = freezed,Object? mainAxisAlignment = freezed,Object? spacing = freezed,}) {
  return _then(_LayoutConfig(
direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,alignment: freezed == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as String?,mainAxisAlignment: freezed == mainAxisAlignment ? _self.mainAxisAlignment : mainAxisAlignment // ignore: cast_nullable_to_non_nullable
as String?,spacing: freezed == spacing ? _self.spacing : spacing // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
