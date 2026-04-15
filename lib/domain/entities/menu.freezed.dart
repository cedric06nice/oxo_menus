// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Menu {

 int get id; String get name; Status get status; String get version; DateTime? get dateCreated; DateTime? get dateUpdated; String? get userCreated; String? get userUpdated; StyleConfig? get styleConfig; PageSize? get pageSize; Area? get area; MenuDisplayOptions? get displayOptions; List<WidgetTypeConfig> get allowedWidgets;
/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuCopyWith<Menu> get copyWith => _$MenuCopyWithImpl<Menu>(this as Menu, _$identity);

  /// Serializes this Menu to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Menu&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.version, version) || other.version == version)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated)&&(identical(other.userCreated, userCreated) || other.userCreated == userCreated)&&(identical(other.userUpdated, userUpdated) || other.userUpdated == userUpdated)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.area, area) || other.area == area)&&(identical(other.displayOptions, displayOptions) || other.displayOptions == displayOptions)&&const DeepCollectionEquality().equals(other.allowedWidgets, allowedWidgets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,status,version,dateCreated,dateUpdated,userCreated,userUpdated,styleConfig,pageSize,area,displayOptions,const DeepCollectionEquality().hash(allowedWidgets));

@override
String toString() {
  return 'Menu(id: $id, name: $name, status: $status, version: $version, dateCreated: $dateCreated, dateUpdated: $dateUpdated, userCreated: $userCreated, userUpdated: $userUpdated, styleConfig: $styleConfig, pageSize: $pageSize, area: $area, displayOptions: $displayOptions, allowedWidgets: $allowedWidgets)';
}


}

/// @nodoc
abstract mixin class $MenuCopyWith<$Res>  {
  factory $MenuCopyWith(Menu value, $Res Function(Menu) _then) = _$MenuCopyWithImpl;
@useResult
$Res call({
 int id, String name, Status status, String version, DateTime? dateCreated, DateTime? dateUpdated, String? userCreated, String? userUpdated, StyleConfig? styleConfig, PageSize? pageSize, Area? area, MenuDisplayOptions? displayOptions, List<WidgetTypeConfig> allowedWidgets
});


$StyleConfigCopyWith<$Res>? get styleConfig;$PageSizeCopyWith<$Res>? get pageSize;$AreaCopyWith<$Res>? get area;$MenuDisplayOptionsCopyWith<$Res>? get displayOptions;

}
/// @nodoc
class _$MenuCopyWithImpl<$Res>
    implements $MenuCopyWith<$Res> {
  _$MenuCopyWithImpl(this._self, this._then);

  final Menu _self;
  final $Res Function(Menu) _then;

/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? version = null,Object? dateCreated = freezed,Object? dateUpdated = freezed,Object? userCreated = freezed,Object? userUpdated = freezed,Object? styleConfig = freezed,Object? pageSize = freezed,Object? area = freezed,Object? displayOptions = freezed,Object? allowedWidgets = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,userCreated: freezed == userCreated ? _self.userCreated : userCreated // ignore: cast_nullable_to_non_nullable
as String?,userUpdated: freezed == userUpdated ? _self.userUpdated : userUpdated // ignore: cast_nullable_to_non_nullable
as String?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,pageSize: freezed == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as PageSize?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as Area?,displayOptions: freezed == displayOptions ? _self.displayOptions : displayOptions // ignore: cast_nullable_to_non_nullable
as MenuDisplayOptions?,allowedWidgets: null == allowedWidgets ? _self.allowedWidgets : allowedWidgets // ignore: cast_nullable_to_non_nullable
as List<WidgetTypeConfig>,
  ));
}
/// Create a copy of Menu
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
}/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageSizeCopyWith<$Res>? get pageSize {
    if (_self.pageSize == null) {
    return null;
  }

  return $PageSizeCopyWith<$Res>(_self.pageSize!, (value) {
    return _then(_self.copyWith(pageSize: value));
  });
}/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AreaCopyWith<$Res>? get area {
    if (_self.area == null) {
    return null;
  }

  return $AreaCopyWith<$Res>(_self.area!, (value) {
    return _then(_self.copyWith(area: value));
  });
}/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuDisplayOptionsCopyWith<$Res>? get displayOptions {
    if (_self.displayOptions == null) {
    return null;
  }

  return $MenuDisplayOptionsCopyWith<$Res>(_self.displayOptions!, (value) {
    return _then(_self.copyWith(displayOptions: value));
  });
}
}


/// Adds pattern-matching-related methods to [Menu].
extension MenuPatterns on Menu {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Menu value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Menu() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Menu value)  $default,){
final _that = this;
switch (_that) {
case _Menu():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Menu value)?  $default,){
final _that = this;
switch (_that) {
case _Menu() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  Status status,  String version,  DateTime? dateCreated,  DateTime? dateUpdated,  String? userCreated,  String? userUpdated,  StyleConfig? styleConfig,  PageSize? pageSize,  Area? area,  MenuDisplayOptions? displayOptions,  List<WidgetTypeConfig> allowedWidgets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Menu() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.version,_that.dateCreated,_that.dateUpdated,_that.userCreated,_that.userUpdated,_that.styleConfig,_that.pageSize,_that.area,_that.displayOptions,_that.allowedWidgets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  Status status,  String version,  DateTime? dateCreated,  DateTime? dateUpdated,  String? userCreated,  String? userUpdated,  StyleConfig? styleConfig,  PageSize? pageSize,  Area? area,  MenuDisplayOptions? displayOptions,  List<WidgetTypeConfig> allowedWidgets)  $default,) {final _that = this;
switch (_that) {
case _Menu():
return $default(_that.id,_that.name,_that.status,_that.version,_that.dateCreated,_that.dateUpdated,_that.userCreated,_that.userUpdated,_that.styleConfig,_that.pageSize,_that.area,_that.displayOptions,_that.allowedWidgets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  Status status,  String version,  DateTime? dateCreated,  DateTime? dateUpdated,  String? userCreated,  String? userUpdated,  StyleConfig? styleConfig,  PageSize? pageSize,  Area? area,  MenuDisplayOptions? displayOptions,  List<WidgetTypeConfig> allowedWidgets)?  $default,) {final _that = this;
switch (_that) {
case _Menu() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.version,_that.dateCreated,_that.dateUpdated,_that.userCreated,_that.userUpdated,_that.styleConfig,_that.pageSize,_that.area,_that.displayOptions,_that.allowedWidgets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Menu extends Menu {
  const _Menu({required this.id, required this.name, required this.status, required this.version, this.dateCreated, this.dateUpdated, this.userCreated, this.userUpdated, this.styleConfig, this.pageSize, this.area, this.displayOptions, final  List<WidgetTypeConfig> allowedWidgets = const []}): _allowedWidgets = allowedWidgets,super._();
  factory _Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);

@override final  int id;
@override final  String name;
@override final  Status status;
@override final  String version;
@override final  DateTime? dateCreated;
@override final  DateTime? dateUpdated;
@override final  String? userCreated;
@override final  String? userUpdated;
@override final  StyleConfig? styleConfig;
@override final  PageSize? pageSize;
@override final  Area? area;
@override final  MenuDisplayOptions? displayOptions;
 final  List<WidgetTypeConfig> _allowedWidgets;
@override@JsonKey() List<WidgetTypeConfig> get allowedWidgets {
  if (_allowedWidgets is EqualUnmodifiableListView) return _allowedWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedWidgets);
}


/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuCopyWith<_Menu> get copyWith => __$MenuCopyWithImpl<_Menu>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Menu&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.version, version) || other.version == version)&&(identical(other.dateCreated, dateCreated) || other.dateCreated == dateCreated)&&(identical(other.dateUpdated, dateUpdated) || other.dateUpdated == dateUpdated)&&(identical(other.userCreated, userCreated) || other.userCreated == userCreated)&&(identical(other.userUpdated, userUpdated) || other.userUpdated == userUpdated)&&(identical(other.styleConfig, styleConfig) || other.styleConfig == styleConfig)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.area, area) || other.area == area)&&(identical(other.displayOptions, displayOptions) || other.displayOptions == displayOptions)&&const DeepCollectionEquality().equals(other._allowedWidgets, _allowedWidgets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,status,version,dateCreated,dateUpdated,userCreated,userUpdated,styleConfig,pageSize,area,displayOptions,const DeepCollectionEquality().hash(_allowedWidgets));

@override
String toString() {
  return 'Menu(id: $id, name: $name, status: $status, version: $version, dateCreated: $dateCreated, dateUpdated: $dateUpdated, userCreated: $userCreated, userUpdated: $userUpdated, styleConfig: $styleConfig, pageSize: $pageSize, area: $area, displayOptions: $displayOptions, allowedWidgets: $allowedWidgets)';
}


}

/// @nodoc
abstract mixin class _$MenuCopyWith<$Res> implements $MenuCopyWith<$Res> {
  factory _$MenuCopyWith(_Menu value, $Res Function(_Menu) _then) = __$MenuCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, Status status, String version, DateTime? dateCreated, DateTime? dateUpdated, String? userCreated, String? userUpdated, StyleConfig? styleConfig, PageSize? pageSize, Area? area, MenuDisplayOptions? displayOptions, List<WidgetTypeConfig> allowedWidgets
});


@override $StyleConfigCopyWith<$Res>? get styleConfig;@override $PageSizeCopyWith<$Res>? get pageSize;@override $AreaCopyWith<$Res>? get area;@override $MenuDisplayOptionsCopyWith<$Res>? get displayOptions;

}
/// @nodoc
class __$MenuCopyWithImpl<$Res>
    implements _$MenuCopyWith<$Res> {
  __$MenuCopyWithImpl(this._self, this._then);

  final _Menu _self;
  final $Res Function(_Menu) _then;

/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? version = null,Object? dateCreated = freezed,Object? dateUpdated = freezed,Object? userCreated = freezed,Object? userUpdated = freezed,Object? styleConfig = freezed,Object? pageSize = freezed,Object? area = freezed,Object? displayOptions = freezed,Object? allowedWidgets = null,}) {
  return _then(_Menu(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,dateCreated: freezed == dateCreated ? _self.dateCreated : dateCreated // ignore: cast_nullable_to_non_nullable
as DateTime?,dateUpdated: freezed == dateUpdated ? _self.dateUpdated : dateUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,userCreated: freezed == userCreated ? _self.userCreated : userCreated // ignore: cast_nullable_to_non_nullable
as String?,userUpdated: freezed == userUpdated ? _self.userUpdated : userUpdated // ignore: cast_nullable_to_non_nullable
as String?,styleConfig: freezed == styleConfig ? _self.styleConfig : styleConfig // ignore: cast_nullable_to_non_nullable
as StyleConfig?,pageSize: freezed == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as PageSize?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as Area?,displayOptions: freezed == displayOptions ? _self.displayOptions : displayOptions // ignore: cast_nullable_to_non_nullable
as MenuDisplayOptions?,allowedWidgets: null == allowedWidgets ? _self._allowedWidgets : allowedWidgets // ignore: cast_nullable_to_non_nullable
as List<WidgetTypeConfig>,
  ));
}

/// Create a copy of Menu
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
}/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageSizeCopyWith<$Res>? get pageSize {
    if (_self.pageSize == null) {
    return null;
  }

  return $PageSizeCopyWith<$Res>(_self.pageSize!, (value) {
    return _then(_self.copyWith(pageSize: value));
  });
}/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AreaCopyWith<$Res>? get area {
    if (_self.area == null) {
    return null;
  }

  return $AreaCopyWith<$Res>(_self.area!, (value) {
    return _then(_self.copyWith(area: value));
  });
}/// Create a copy of Menu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuDisplayOptionsCopyWith<$Res>? get displayOptions {
    if (_self.displayOptions == null) {
    return null;
  }

  return $MenuDisplayOptionsCopyWith<$Res>(_self.displayOptions!, (value) {
    return _then(_self.copyWith(displayOptions: value));
  });
}
}


/// @nodoc
mixin _$StyleConfig {

 String? get fontFamily; double? get fontSize; String? get primaryColor; String? get secondaryColor; String? get backgroundColor; double? get margin; double? get marginTop; double? get marginBottom; double? get marginLeft; double? get marginRight; double? get padding; double? get paddingTop; double? get paddingBottom; double? get paddingLeft; double? get paddingRight; BorderType? get borderType; VerticalAlignment? get verticalAlignment;
/// Create a copy of StyleConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StyleConfigCopyWith<StyleConfig> get copyWith => _$StyleConfigCopyWithImpl<StyleConfig>(this as StyleConfig, _$identity);

  /// Serializes this StyleConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StyleConfig&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.marginTop, marginTop) || other.marginTop == marginTop)&&(identical(other.marginBottom, marginBottom) || other.marginBottom == marginBottom)&&(identical(other.marginLeft, marginLeft) || other.marginLeft == marginLeft)&&(identical(other.marginRight, marginRight) || other.marginRight == marginRight)&&(identical(other.padding, padding) || other.padding == padding)&&(identical(other.paddingTop, paddingTop) || other.paddingTop == paddingTop)&&(identical(other.paddingBottom, paddingBottom) || other.paddingBottom == paddingBottom)&&(identical(other.paddingLeft, paddingLeft) || other.paddingLeft == paddingLeft)&&(identical(other.paddingRight, paddingRight) || other.paddingRight == paddingRight)&&(identical(other.borderType, borderType) || other.borderType == borderType)&&(identical(other.verticalAlignment, verticalAlignment) || other.verticalAlignment == verticalAlignment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fontFamily,fontSize,primaryColor,secondaryColor,backgroundColor,margin,marginTop,marginBottom,marginLeft,marginRight,padding,paddingTop,paddingBottom,paddingLeft,paddingRight,borderType,verticalAlignment);

@override
String toString() {
  return 'StyleConfig(fontFamily: $fontFamily, fontSize: $fontSize, primaryColor: $primaryColor, secondaryColor: $secondaryColor, backgroundColor: $backgroundColor, margin: $margin, marginTop: $marginTop, marginBottom: $marginBottom, marginLeft: $marginLeft, marginRight: $marginRight, padding: $padding, paddingTop: $paddingTop, paddingBottom: $paddingBottom, paddingLeft: $paddingLeft, paddingRight: $paddingRight, borderType: $borderType, verticalAlignment: $verticalAlignment)';
}


}

/// @nodoc
abstract mixin class $StyleConfigCopyWith<$Res>  {
  factory $StyleConfigCopyWith(StyleConfig value, $Res Function(StyleConfig) _then) = _$StyleConfigCopyWithImpl;
@useResult
$Res call({
 String? fontFamily, double? fontSize, String? primaryColor, String? secondaryColor, String? backgroundColor, double? margin, double? marginTop, double? marginBottom, double? marginLeft, double? marginRight, double? padding, double? paddingTop, double? paddingBottom, double? paddingLeft, double? paddingRight, BorderType? borderType, VerticalAlignment? verticalAlignment
});




}
/// @nodoc
class _$StyleConfigCopyWithImpl<$Res>
    implements $StyleConfigCopyWith<$Res> {
  _$StyleConfigCopyWithImpl(this._self, this._then);

  final StyleConfig _self;
  final $Res Function(StyleConfig) _then;

/// Create a copy of StyleConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fontFamily = freezed,Object? fontSize = freezed,Object? primaryColor = freezed,Object? secondaryColor = freezed,Object? backgroundColor = freezed,Object? margin = freezed,Object? marginTop = freezed,Object? marginBottom = freezed,Object? marginLeft = freezed,Object? marginRight = freezed,Object? padding = freezed,Object? paddingTop = freezed,Object? paddingBottom = freezed,Object? paddingLeft = freezed,Object? paddingRight = freezed,Object? borderType = freezed,Object? verticalAlignment = freezed,}) {
  return _then(_self.copyWith(
fontFamily: freezed == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String?,fontSize: freezed == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double?,primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String?,secondaryColor: freezed == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as String?,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,margin: freezed == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as double?,marginTop: freezed == marginTop ? _self.marginTop : marginTop // ignore: cast_nullable_to_non_nullable
as double?,marginBottom: freezed == marginBottom ? _self.marginBottom : marginBottom // ignore: cast_nullable_to_non_nullable
as double?,marginLeft: freezed == marginLeft ? _self.marginLeft : marginLeft // ignore: cast_nullable_to_non_nullable
as double?,marginRight: freezed == marginRight ? _self.marginRight : marginRight // ignore: cast_nullable_to_non_nullable
as double?,padding: freezed == padding ? _self.padding : padding // ignore: cast_nullable_to_non_nullable
as double?,paddingTop: freezed == paddingTop ? _self.paddingTop : paddingTop // ignore: cast_nullable_to_non_nullable
as double?,paddingBottom: freezed == paddingBottom ? _self.paddingBottom : paddingBottom // ignore: cast_nullable_to_non_nullable
as double?,paddingLeft: freezed == paddingLeft ? _self.paddingLeft : paddingLeft // ignore: cast_nullable_to_non_nullable
as double?,paddingRight: freezed == paddingRight ? _self.paddingRight : paddingRight // ignore: cast_nullable_to_non_nullable
as double?,borderType: freezed == borderType ? _self.borderType : borderType // ignore: cast_nullable_to_non_nullable
as BorderType?,verticalAlignment: freezed == verticalAlignment ? _self.verticalAlignment : verticalAlignment // ignore: cast_nullable_to_non_nullable
as VerticalAlignment?,
  ));
}

}


/// Adds pattern-matching-related methods to [StyleConfig].
extension StyleConfigPatterns on StyleConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StyleConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StyleConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StyleConfig value)  $default,){
final _that = this;
switch (_that) {
case _StyleConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StyleConfig value)?  $default,){
final _that = this;
switch (_that) {
case _StyleConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? fontFamily,  double? fontSize,  String? primaryColor,  String? secondaryColor,  String? backgroundColor,  double? margin,  double? marginTop,  double? marginBottom,  double? marginLeft,  double? marginRight,  double? padding,  double? paddingTop,  double? paddingBottom,  double? paddingLeft,  double? paddingRight,  BorderType? borderType,  VerticalAlignment? verticalAlignment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StyleConfig() when $default != null:
return $default(_that.fontFamily,_that.fontSize,_that.primaryColor,_that.secondaryColor,_that.backgroundColor,_that.margin,_that.marginTop,_that.marginBottom,_that.marginLeft,_that.marginRight,_that.padding,_that.paddingTop,_that.paddingBottom,_that.paddingLeft,_that.paddingRight,_that.borderType,_that.verticalAlignment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? fontFamily,  double? fontSize,  String? primaryColor,  String? secondaryColor,  String? backgroundColor,  double? margin,  double? marginTop,  double? marginBottom,  double? marginLeft,  double? marginRight,  double? padding,  double? paddingTop,  double? paddingBottom,  double? paddingLeft,  double? paddingRight,  BorderType? borderType,  VerticalAlignment? verticalAlignment)  $default,) {final _that = this;
switch (_that) {
case _StyleConfig():
return $default(_that.fontFamily,_that.fontSize,_that.primaryColor,_that.secondaryColor,_that.backgroundColor,_that.margin,_that.marginTop,_that.marginBottom,_that.marginLeft,_that.marginRight,_that.padding,_that.paddingTop,_that.paddingBottom,_that.paddingLeft,_that.paddingRight,_that.borderType,_that.verticalAlignment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? fontFamily,  double? fontSize,  String? primaryColor,  String? secondaryColor,  String? backgroundColor,  double? margin,  double? marginTop,  double? marginBottom,  double? marginLeft,  double? marginRight,  double? padding,  double? paddingTop,  double? paddingBottom,  double? paddingLeft,  double? paddingRight,  BorderType? borderType,  VerticalAlignment? verticalAlignment)?  $default,) {final _that = this;
switch (_that) {
case _StyleConfig() when $default != null:
return $default(_that.fontFamily,_that.fontSize,_that.primaryColor,_that.secondaryColor,_that.backgroundColor,_that.margin,_that.marginTop,_that.marginBottom,_that.marginLeft,_that.marginRight,_that.padding,_that.paddingTop,_that.paddingBottom,_that.paddingLeft,_that.paddingRight,_that.borderType,_that.verticalAlignment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StyleConfig extends StyleConfig {
  const _StyleConfig({this.fontFamily, this.fontSize, this.primaryColor, this.secondaryColor, this.backgroundColor, this.margin, this.marginTop, this.marginBottom, this.marginLeft, this.marginRight, this.padding, this.paddingTop, this.paddingBottom, this.paddingLeft, this.paddingRight, this.borderType, this.verticalAlignment}): super._();
  factory _StyleConfig.fromJson(Map<String, dynamic> json) => _$StyleConfigFromJson(json);

@override final  String? fontFamily;
@override final  double? fontSize;
@override final  String? primaryColor;
@override final  String? secondaryColor;
@override final  String? backgroundColor;
@override final  double? margin;
@override final  double? marginTop;
@override final  double? marginBottom;
@override final  double? marginLeft;
@override final  double? marginRight;
@override final  double? padding;
@override final  double? paddingTop;
@override final  double? paddingBottom;
@override final  double? paddingLeft;
@override final  double? paddingRight;
@override final  BorderType? borderType;
@override final  VerticalAlignment? verticalAlignment;

/// Create a copy of StyleConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StyleConfigCopyWith<_StyleConfig> get copyWith => __$StyleConfigCopyWithImpl<_StyleConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StyleConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StyleConfig&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.margin, margin) || other.margin == margin)&&(identical(other.marginTop, marginTop) || other.marginTop == marginTop)&&(identical(other.marginBottom, marginBottom) || other.marginBottom == marginBottom)&&(identical(other.marginLeft, marginLeft) || other.marginLeft == marginLeft)&&(identical(other.marginRight, marginRight) || other.marginRight == marginRight)&&(identical(other.padding, padding) || other.padding == padding)&&(identical(other.paddingTop, paddingTop) || other.paddingTop == paddingTop)&&(identical(other.paddingBottom, paddingBottom) || other.paddingBottom == paddingBottom)&&(identical(other.paddingLeft, paddingLeft) || other.paddingLeft == paddingLeft)&&(identical(other.paddingRight, paddingRight) || other.paddingRight == paddingRight)&&(identical(other.borderType, borderType) || other.borderType == borderType)&&(identical(other.verticalAlignment, verticalAlignment) || other.verticalAlignment == verticalAlignment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fontFamily,fontSize,primaryColor,secondaryColor,backgroundColor,margin,marginTop,marginBottom,marginLeft,marginRight,padding,paddingTop,paddingBottom,paddingLeft,paddingRight,borderType,verticalAlignment);

@override
String toString() {
  return 'StyleConfig(fontFamily: $fontFamily, fontSize: $fontSize, primaryColor: $primaryColor, secondaryColor: $secondaryColor, backgroundColor: $backgroundColor, margin: $margin, marginTop: $marginTop, marginBottom: $marginBottom, marginLeft: $marginLeft, marginRight: $marginRight, padding: $padding, paddingTop: $paddingTop, paddingBottom: $paddingBottom, paddingLeft: $paddingLeft, paddingRight: $paddingRight, borderType: $borderType, verticalAlignment: $verticalAlignment)';
}


}

/// @nodoc
abstract mixin class _$StyleConfigCopyWith<$Res> implements $StyleConfigCopyWith<$Res> {
  factory _$StyleConfigCopyWith(_StyleConfig value, $Res Function(_StyleConfig) _then) = __$StyleConfigCopyWithImpl;
@override @useResult
$Res call({
 String? fontFamily, double? fontSize, String? primaryColor, String? secondaryColor, String? backgroundColor, double? margin, double? marginTop, double? marginBottom, double? marginLeft, double? marginRight, double? padding, double? paddingTop, double? paddingBottom, double? paddingLeft, double? paddingRight, BorderType? borderType, VerticalAlignment? verticalAlignment
});




}
/// @nodoc
class __$StyleConfigCopyWithImpl<$Res>
    implements _$StyleConfigCopyWith<$Res> {
  __$StyleConfigCopyWithImpl(this._self, this._then);

  final _StyleConfig _self;
  final $Res Function(_StyleConfig) _then;

/// Create a copy of StyleConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fontFamily = freezed,Object? fontSize = freezed,Object? primaryColor = freezed,Object? secondaryColor = freezed,Object? backgroundColor = freezed,Object? margin = freezed,Object? marginTop = freezed,Object? marginBottom = freezed,Object? marginLeft = freezed,Object? marginRight = freezed,Object? padding = freezed,Object? paddingTop = freezed,Object? paddingBottom = freezed,Object? paddingLeft = freezed,Object? paddingRight = freezed,Object? borderType = freezed,Object? verticalAlignment = freezed,}) {
  return _then(_StyleConfig(
fontFamily: freezed == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String?,fontSize: freezed == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double?,primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String?,secondaryColor: freezed == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as String?,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,margin: freezed == margin ? _self.margin : margin // ignore: cast_nullable_to_non_nullable
as double?,marginTop: freezed == marginTop ? _self.marginTop : marginTop // ignore: cast_nullable_to_non_nullable
as double?,marginBottom: freezed == marginBottom ? _self.marginBottom : marginBottom // ignore: cast_nullable_to_non_nullable
as double?,marginLeft: freezed == marginLeft ? _self.marginLeft : marginLeft // ignore: cast_nullable_to_non_nullable
as double?,marginRight: freezed == marginRight ? _self.marginRight : marginRight // ignore: cast_nullable_to_non_nullable
as double?,padding: freezed == padding ? _self.padding : padding // ignore: cast_nullable_to_non_nullable
as double?,paddingTop: freezed == paddingTop ? _self.paddingTop : paddingTop // ignore: cast_nullable_to_non_nullable
as double?,paddingBottom: freezed == paddingBottom ? _self.paddingBottom : paddingBottom // ignore: cast_nullable_to_non_nullable
as double?,paddingLeft: freezed == paddingLeft ? _self.paddingLeft : paddingLeft // ignore: cast_nullable_to_non_nullable
as double?,paddingRight: freezed == paddingRight ? _self.paddingRight : paddingRight // ignore: cast_nullable_to_non_nullable
as double?,borderType: freezed == borderType ? _self.borderType : borderType // ignore: cast_nullable_to_non_nullable
as BorderType?,verticalAlignment: freezed == verticalAlignment ? _self.verticalAlignment : verticalAlignment // ignore: cast_nullable_to_non_nullable
as VerticalAlignment?,
  ));
}


}


/// @nodoc
mixin _$PageSize {

 String get name; double get width; double get height;
/// Create a copy of PageSize
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageSizeCopyWith<PageSize> get copyWith => _$PageSizeCopyWithImpl<PageSize>(this as PageSize, _$identity);

  /// Serializes this PageSize to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageSize&&(identical(other.name, name) || other.name == name)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,width,height);

@override
String toString() {
  return 'PageSize(name: $name, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $PageSizeCopyWith<$Res>  {
  factory $PageSizeCopyWith(PageSize value, $Res Function(PageSize) _then) = _$PageSizeCopyWithImpl;
@useResult
$Res call({
 String name, double width, double height
});




}
/// @nodoc
class _$PageSizeCopyWithImpl<$Res>
    implements $PageSizeCopyWith<$Res> {
  _$PageSizeCopyWithImpl(this._self, this._then);

  final PageSize _self;
  final $Res Function(PageSize) _then;

/// Create a copy of PageSize
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? width = null,Object? height = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PageSize].
extension PageSizePatterns on PageSize {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageSize value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageSize() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageSize value)  $default,){
final _that = this;
switch (_that) {
case _PageSize():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageSize value)?  $default,){
final _that = this;
switch (_that) {
case _PageSize() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double width,  double height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageSize() when $default != null:
return $default(_that.name,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double width,  double height)  $default,) {final _that = this;
switch (_that) {
case _PageSize():
return $default(_that.name,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double width,  double height)?  $default,) {final _that = this;
switch (_that) {
case _PageSize() when $default != null:
return $default(_that.name,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PageSize extends PageSize {
  const _PageSize({required this.name, required this.width, required this.height}): super._();
  factory _PageSize.fromJson(Map<String, dynamic> json) => _$PageSizeFromJson(json);

@override final  String name;
@override final  double width;
@override final  double height;

/// Create a copy of PageSize
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageSizeCopyWith<_PageSize> get copyWith => __$PageSizeCopyWithImpl<_PageSize>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PageSizeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageSize&&(identical(other.name, name) || other.name == name)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,width,height);

@override
String toString() {
  return 'PageSize(name: $name, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$PageSizeCopyWith<$Res> implements $PageSizeCopyWith<$Res> {
  factory _$PageSizeCopyWith(_PageSize value, $Res Function(_PageSize) _then) = __$PageSizeCopyWithImpl;
@override @useResult
$Res call({
 String name, double width, double height
});




}
/// @nodoc
class __$PageSizeCopyWithImpl<$Res>
    implements _$PageSizeCopyWith<$Res> {
  __$PageSizeCopyWithImpl(this._self, this._then);

  final _PageSize _self;
  final $Res Function(_PageSize) _then;

/// Create a copy of PageSize
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? width = null,Object? height = null,}) {
  return _then(_PageSize(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
