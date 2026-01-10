// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Menu _$MenuFromJson(Map<String, dynamic> json) {
  return _Menu.fromJson(json);
}

/// @nodoc
mixin _$Menu {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  MenuStatus get status => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  DateTime? get dateUpdated => throw _privateConstructorUsedError;
  String? get userCreated => throw _privateConstructorUsedError;
  String? get userUpdated => throw _privateConstructorUsedError;
  StyleConfig? get styleConfig => throw _privateConstructorUsedError;
  PageSize? get pageSize => throw _privateConstructorUsedError;
  String? get area => throw _privateConstructorUsedError;

  /// Serializes this Menu to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Menu
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuCopyWith<Menu> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuCopyWith<$Res> {
  factory $MenuCopyWith(Menu value, $Res Function(Menu) then) =
      _$MenuCopyWithImpl<$Res, Menu>;
  @useResult
  $Res call(
      {String id,
      String name,
      MenuStatus status,
      String version,
      DateTime? dateCreated,
      DateTime? dateUpdated,
      String? userCreated,
      String? userUpdated,
      StyleConfig? styleConfig,
      PageSize? pageSize,
      String? area});

  $StyleConfigCopyWith<$Res>? get styleConfig;
  $PageSizeCopyWith<$Res>? get pageSize;
}

/// @nodoc
class _$MenuCopyWithImpl<$Res, $Val extends Menu>
    implements $MenuCopyWith<$Res> {
  _$MenuCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Menu
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? version = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? userCreated = freezed,
    Object? userUpdated = freezed,
    Object? styleConfig = freezed,
    Object? pageSize = freezed,
    Object? area = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MenuStatus,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _value.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userCreated: freezed == userCreated
          ? _value.userCreated
          : userCreated // ignore: cast_nullable_to_non_nullable
              as String?,
      userUpdated: freezed == userUpdated
          ? _value.userUpdated
          : userUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
      styleConfig: freezed == styleConfig
          ? _value.styleConfig
          : styleConfig // ignore: cast_nullable_to_non_nullable
              as StyleConfig?,
      pageSize: freezed == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as PageSize?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Menu
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StyleConfigCopyWith<$Res>? get styleConfig {
    if (_value.styleConfig == null) {
      return null;
    }

    return $StyleConfigCopyWith<$Res>(_value.styleConfig!, (value) {
      return _then(_value.copyWith(styleConfig: value) as $Val);
    });
  }

  /// Create a copy of Menu
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PageSizeCopyWith<$Res>? get pageSize {
    if (_value.pageSize == null) {
      return null;
    }

    return $PageSizeCopyWith<$Res>(_value.pageSize!, (value) {
      return _then(_value.copyWith(pageSize: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MenuImplCopyWith<$Res> implements $MenuCopyWith<$Res> {
  factory _$$MenuImplCopyWith(
          _$MenuImpl value, $Res Function(_$MenuImpl) then) =
      __$$MenuImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      MenuStatus status,
      String version,
      DateTime? dateCreated,
      DateTime? dateUpdated,
      String? userCreated,
      String? userUpdated,
      StyleConfig? styleConfig,
      PageSize? pageSize,
      String? area});

  @override
  $StyleConfigCopyWith<$Res>? get styleConfig;
  @override
  $PageSizeCopyWith<$Res>? get pageSize;
}

/// @nodoc
class __$$MenuImplCopyWithImpl<$Res>
    extends _$MenuCopyWithImpl<$Res, _$MenuImpl>
    implements _$$MenuImplCopyWith<$Res> {
  __$$MenuImplCopyWithImpl(_$MenuImpl _value, $Res Function(_$MenuImpl) _then)
      : super(_value, _then);

  /// Create a copy of Menu
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? version = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? userCreated = freezed,
    Object? userUpdated = freezed,
    Object? styleConfig = freezed,
    Object? pageSize = freezed,
    Object? area = freezed,
  }) {
    return _then(_$MenuImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MenuStatus,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _value.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userCreated: freezed == userCreated
          ? _value.userCreated
          : userCreated // ignore: cast_nullable_to_non_nullable
              as String?,
      userUpdated: freezed == userUpdated
          ? _value.userUpdated
          : userUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
      styleConfig: freezed == styleConfig
          ? _value.styleConfig
          : styleConfig // ignore: cast_nullable_to_non_nullable
              as StyleConfig?,
      pageSize: freezed == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as PageSize?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuImpl implements _Menu {
  const _$MenuImpl(
      {required this.id,
      required this.name,
      required this.status,
      required this.version,
      this.dateCreated,
      this.dateUpdated,
      this.userCreated,
      this.userUpdated,
      this.styleConfig,
      this.pageSize,
      this.area});

  factory _$MenuImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final MenuStatus status;
  @override
  final String version;
  @override
  final DateTime? dateCreated;
  @override
  final DateTime? dateUpdated;
  @override
  final String? userCreated;
  @override
  final String? userUpdated;
  @override
  final StyleConfig? styleConfig;
  @override
  final PageSize? pageSize;
  @override
  final String? area;

  @override
  String toString() {
    return 'Menu(id: $id, name: $name, status: $status, version: $version, dateCreated: $dateCreated, dateUpdated: $dateUpdated, userCreated: $userCreated, userUpdated: $userUpdated, styleConfig: $styleConfig, pageSize: $pageSize, area: $area)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.dateUpdated, dateUpdated) ||
                other.dateUpdated == dateUpdated) &&
            (identical(other.userCreated, userCreated) ||
                other.userCreated == userCreated) &&
            (identical(other.userUpdated, userUpdated) ||
                other.userUpdated == userUpdated) &&
            (identical(other.styleConfig, styleConfig) ||
                other.styleConfig == styleConfig) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.area, area) || other.area == area));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      status,
      version,
      dateCreated,
      dateUpdated,
      userCreated,
      userUpdated,
      styleConfig,
      pageSize,
      area);

  /// Create a copy of Menu
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuImplCopyWith<_$MenuImpl> get copyWith =>
      __$$MenuImplCopyWithImpl<_$MenuImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuImplToJson(
      this,
    );
  }
}

abstract class _Menu implements Menu {
  const factory _Menu(
      {required final String id,
      required final String name,
      required final MenuStatus status,
      required final String version,
      final DateTime? dateCreated,
      final DateTime? dateUpdated,
      final String? userCreated,
      final String? userUpdated,
      final StyleConfig? styleConfig,
      final PageSize? pageSize,
      final String? area}) = _$MenuImpl;

  factory _Menu.fromJson(Map<String, dynamic> json) = _$MenuImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  MenuStatus get status;
  @override
  String get version;
  @override
  DateTime? get dateCreated;
  @override
  DateTime? get dateUpdated;
  @override
  String? get userCreated;
  @override
  String? get userUpdated;
  @override
  StyleConfig? get styleConfig;
  @override
  PageSize? get pageSize;
  @override
  String? get area;

  /// Create a copy of Menu
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuImplCopyWith<_$MenuImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StyleConfig _$StyleConfigFromJson(Map<String, dynamic> json) {
  return _StyleConfig.fromJson(json);
}

/// @nodoc
mixin _$StyleConfig {
  String? get fontFamily => throw _privateConstructorUsedError;
  double? get fontSize => throw _privateConstructorUsedError;
  String? get primaryColor => throw _privateConstructorUsedError;
  String? get secondaryColor => throw _privateConstructorUsedError;
  String? get backgroundColor => throw _privateConstructorUsedError;
  double? get marginTop => throw _privateConstructorUsedError;
  double? get marginBottom => throw _privateConstructorUsedError;
  double? get marginLeft => throw _privateConstructorUsedError;
  double? get marginRight => throw _privateConstructorUsedError;
  double? get padding => throw _privateConstructorUsedError;

  /// Serializes this StyleConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StyleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StyleConfigCopyWith<StyleConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StyleConfigCopyWith<$Res> {
  factory $StyleConfigCopyWith(
          StyleConfig value, $Res Function(StyleConfig) then) =
      _$StyleConfigCopyWithImpl<$Res, StyleConfig>;
  @useResult
  $Res call(
      {String? fontFamily,
      double? fontSize,
      String? primaryColor,
      String? secondaryColor,
      String? backgroundColor,
      double? marginTop,
      double? marginBottom,
      double? marginLeft,
      double? marginRight,
      double? padding});
}

/// @nodoc
class _$StyleConfigCopyWithImpl<$Res, $Val extends StyleConfig>
    implements $StyleConfigCopyWith<$Res> {
  _$StyleConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StyleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fontFamily = freezed,
    Object? fontSize = freezed,
    Object? primaryColor = freezed,
    Object? secondaryColor = freezed,
    Object? backgroundColor = freezed,
    Object? marginTop = freezed,
    Object? marginBottom = freezed,
    Object? marginLeft = freezed,
    Object? marginRight = freezed,
    Object? padding = freezed,
  }) {
    return _then(_value.copyWith(
      fontFamily: freezed == fontFamily
          ? _value.fontFamily
          : fontFamily // ignore: cast_nullable_to_non_nullable
              as String?,
      fontSize: freezed == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double?,
      primaryColor: freezed == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      secondaryColor: freezed == secondaryColor
          ? _value.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      marginTop: freezed == marginTop
          ? _value.marginTop
          : marginTop // ignore: cast_nullable_to_non_nullable
              as double?,
      marginBottom: freezed == marginBottom
          ? _value.marginBottom
          : marginBottom // ignore: cast_nullable_to_non_nullable
              as double?,
      marginLeft: freezed == marginLeft
          ? _value.marginLeft
          : marginLeft // ignore: cast_nullable_to_non_nullable
              as double?,
      marginRight: freezed == marginRight
          ? _value.marginRight
          : marginRight // ignore: cast_nullable_to_non_nullable
              as double?,
      padding: freezed == padding
          ? _value.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StyleConfigImplCopyWith<$Res>
    implements $StyleConfigCopyWith<$Res> {
  factory _$$StyleConfigImplCopyWith(
          _$StyleConfigImpl value, $Res Function(_$StyleConfigImpl) then) =
      __$$StyleConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? fontFamily,
      double? fontSize,
      String? primaryColor,
      String? secondaryColor,
      String? backgroundColor,
      double? marginTop,
      double? marginBottom,
      double? marginLeft,
      double? marginRight,
      double? padding});
}

/// @nodoc
class __$$StyleConfigImplCopyWithImpl<$Res>
    extends _$StyleConfigCopyWithImpl<$Res, _$StyleConfigImpl>
    implements _$$StyleConfigImplCopyWith<$Res> {
  __$$StyleConfigImplCopyWithImpl(
      _$StyleConfigImpl _value, $Res Function(_$StyleConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of StyleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fontFamily = freezed,
    Object? fontSize = freezed,
    Object? primaryColor = freezed,
    Object? secondaryColor = freezed,
    Object? backgroundColor = freezed,
    Object? marginTop = freezed,
    Object? marginBottom = freezed,
    Object? marginLeft = freezed,
    Object? marginRight = freezed,
    Object? padding = freezed,
  }) {
    return _then(_$StyleConfigImpl(
      fontFamily: freezed == fontFamily
          ? _value.fontFamily
          : fontFamily // ignore: cast_nullable_to_non_nullable
              as String?,
      fontSize: freezed == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double?,
      primaryColor: freezed == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      secondaryColor: freezed == secondaryColor
          ? _value.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      marginTop: freezed == marginTop
          ? _value.marginTop
          : marginTop // ignore: cast_nullable_to_non_nullable
              as double?,
      marginBottom: freezed == marginBottom
          ? _value.marginBottom
          : marginBottom // ignore: cast_nullable_to_non_nullable
              as double?,
      marginLeft: freezed == marginLeft
          ? _value.marginLeft
          : marginLeft // ignore: cast_nullable_to_non_nullable
              as double?,
      marginRight: freezed == marginRight
          ? _value.marginRight
          : marginRight // ignore: cast_nullable_to_non_nullable
              as double?,
      padding: freezed == padding
          ? _value.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StyleConfigImpl implements _StyleConfig {
  const _$StyleConfigImpl(
      {this.fontFamily,
      this.fontSize,
      this.primaryColor,
      this.secondaryColor,
      this.backgroundColor,
      this.marginTop,
      this.marginBottom,
      this.marginLeft,
      this.marginRight,
      this.padding});

  factory _$StyleConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$StyleConfigImplFromJson(json);

  @override
  final String? fontFamily;
  @override
  final double? fontSize;
  @override
  final String? primaryColor;
  @override
  final String? secondaryColor;
  @override
  final String? backgroundColor;
  @override
  final double? marginTop;
  @override
  final double? marginBottom;
  @override
  final double? marginLeft;
  @override
  final double? marginRight;
  @override
  final double? padding;

  @override
  String toString() {
    return 'StyleConfig(fontFamily: $fontFamily, fontSize: $fontSize, primaryColor: $primaryColor, secondaryColor: $secondaryColor, backgroundColor: $backgroundColor, marginTop: $marginTop, marginBottom: $marginBottom, marginLeft: $marginLeft, marginRight: $marginRight, padding: $padding)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StyleConfigImpl &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.marginTop, marginTop) ||
                other.marginTop == marginTop) &&
            (identical(other.marginBottom, marginBottom) ||
                other.marginBottom == marginBottom) &&
            (identical(other.marginLeft, marginLeft) ||
                other.marginLeft == marginLeft) &&
            (identical(other.marginRight, marginRight) ||
                other.marginRight == marginRight) &&
            (identical(other.padding, padding) || other.padding == padding));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      fontFamily,
      fontSize,
      primaryColor,
      secondaryColor,
      backgroundColor,
      marginTop,
      marginBottom,
      marginLeft,
      marginRight,
      padding);

  /// Create a copy of StyleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StyleConfigImplCopyWith<_$StyleConfigImpl> get copyWith =>
      __$$StyleConfigImplCopyWithImpl<_$StyleConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StyleConfigImplToJson(
      this,
    );
  }
}

abstract class _StyleConfig implements StyleConfig {
  const factory _StyleConfig(
      {final String? fontFamily,
      final double? fontSize,
      final String? primaryColor,
      final String? secondaryColor,
      final String? backgroundColor,
      final double? marginTop,
      final double? marginBottom,
      final double? marginLeft,
      final double? marginRight,
      final double? padding}) = _$StyleConfigImpl;

  factory _StyleConfig.fromJson(Map<String, dynamic> json) =
      _$StyleConfigImpl.fromJson;

  @override
  String? get fontFamily;
  @override
  double? get fontSize;
  @override
  String? get primaryColor;
  @override
  String? get secondaryColor;
  @override
  String? get backgroundColor;
  @override
  double? get marginTop;
  @override
  double? get marginBottom;
  @override
  double? get marginLeft;
  @override
  double? get marginRight;
  @override
  double? get padding;

  /// Create a copy of StyleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StyleConfigImplCopyWith<_$StyleConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PageSize _$PageSizeFromJson(Map<String, dynamic> json) {
  return _PageSize.fromJson(json);
}

/// @nodoc
mixin _$PageSize {
  String get name => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;

  /// Serializes this PageSize to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageSizeCopyWith<PageSize> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageSizeCopyWith<$Res> {
  factory $PageSizeCopyWith(PageSize value, $Res Function(PageSize) then) =
      _$PageSizeCopyWithImpl<$Res, PageSize>;
  @useResult
  $Res call({String name, double width, double height});
}

/// @nodoc
class _$PageSizeCopyWithImpl<$Res, $Val extends PageSize>
    implements $PageSizeCopyWith<$Res> {
  _$PageSizeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PageSizeImplCopyWith<$Res>
    implements $PageSizeCopyWith<$Res> {
  factory _$$PageSizeImplCopyWith(
          _$PageSizeImpl value, $Res Function(_$PageSizeImpl) then) =
      __$$PageSizeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double width, double height});
}

/// @nodoc
class __$$PageSizeImplCopyWithImpl<$Res>
    extends _$PageSizeCopyWithImpl<$Res, _$PageSizeImpl>
    implements _$$PageSizeImplCopyWith<$Res> {
  __$$PageSizeImplCopyWithImpl(
      _$PageSizeImpl _value, $Res Function(_$PageSizeImpl) _then)
      : super(_value, _then);

  /// Create a copy of PageSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(_$PageSizeImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PageSizeImpl implements _PageSize {
  const _$PageSizeImpl(
      {required this.name, required this.width, required this.height});

  factory _$PageSizeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageSizeImplFromJson(json);

  @override
  final String name;
  @override
  final double width;
  @override
  final double height;

  @override
  String toString() {
    return 'PageSize(name: $name, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageSizeImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, width, height);

  /// Create a copy of PageSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageSizeImplCopyWith<_$PageSizeImpl> get copyWith =>
      __$$PageSizeImplCopyWithImpl<_$PageSizeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PageSizeImplToJson(
      this,
    );
  }
}

abstract class _PageSize implements PageSize {
  const factory _PageSize(
      {required final String name,
      required final double width,
      required final double height}) = _$PageSizeImpl;

  factory _PageSize.fromJson(Map<String, dynamic> json) =
      _$PageSizeImpl.fromJson;

  @override
  String get name;
  @override
  double get width;
  @override
  double get height;

  /// Create a copy of PageSize
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageSizeImplCopyWith<_$PageSizeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
