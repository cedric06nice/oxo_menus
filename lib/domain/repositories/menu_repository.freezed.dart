// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreateMenuInput {
  String get name => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  MenuStatus? get status => throw _privateConstructorUsedError;
  StyleConfig? get styleConfig => throw _privateConstructorUsedError;
  PageSize? get pageSize => throw _privateConstructorUsedError;
  String? get area => throw _privateConstructorUsedError;

  /// Create a copy of CreateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateMenuInputCopyWith<CreateMenuInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateMenuInputCopyWith<$Res> {
  factory $CreateMenuInputCopyWith(
          CreateMenuInput value, $Res Function(CreateMenuInput) then) =
      _$CreateMenuInputCopyWithImpl<$Res, CreateMenuInput>;
  @useResult
  $Res call(
      {String name,
      String version,
      MenuStatus? status,
      StyleConfig? styleConfig,
      PageSize? pageSize,
      String? area});

  $StyleConfigCopyWith<$Res>? get styleConfig;
  $PageSizeCopyWith<$Res>? get pageSize;
}

/// @nodoc
class _$CreateMenuInputCopyWithImpl<$Res, $Val extends CreateMenuInput>
    implements $CreateMenuInputCopyWith<$Res> {
  _$CreateMenuInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? version = null,
    Object? status = freezed,
    Object? styleConfig = freezed,
    Object? pageSize = freezed,
    Object? area = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MenuStatus?,
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

  /// Create a copy of CreateMenuInput
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

  /// Create a copy of CreateMenuInput
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
abstract class _$$CreateMenuInputImplCopyWith<$Res>
    implements $CreateMenuInputCopyWith<$Res> {
  factory _$$CreateMenuInputImplCopyWith(_$CreateMenuInputImpl value,
          $Res Function(_$CreateMenuInputImpl) then) =
      __$$CreateMenuInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String version,
      MenuStatus? status,
      StyleConfig? styleConfig,
      PageSize? pageSize,
      String? area});

  @override
  $StyleConfigCopyWith<$Res>? get styleConfig;
  @override
  $PageSizeCopyWith<$Res>? get pageSize;
}

/// @nodoc
class __$$CreateMenuInputImplCopyWithImpl<$Res>
    extends _$CreateMenuInputCopyWithImpl<$Res, _$CreateMenuInputImpl>
    implements _$$CreateMenuInputImplCopyWith<$Res> {
  __$$CreateMenuInputImplCopyWithImpl(
      _$CreateMenuInputImpl _value, $Res Function(_$CreateMenuInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? version = null,
    Object? status = freezed,
    Object? styleConfig = freezed,
    Object? pageSize = freezed,
    Object? area = freezed,
  }) {
    return _then(_$CreateMenuInputImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MenuStatus?,
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

class _$CreateMenuInputImpl implements _CreateMenuInput {
  const _$CreateMenuInputImpl(
      {required this.name,
      required this.version,
      this.status,
      this.styleConfig,
      this.pageSize,
      this.area});

  @override
  final String name;
  @override
  final String version;
  @override
  final MenuStatus? status;
  @override
  final StyleConfig? styleConfig;
  @override
  final PageSize? pageSize;
  @override
  final String? area;

  @override
  String toString() {
    return 'CreateMenuInput(name: $name, version: $version, status: $status, styleConfig: $styleConfig, pageSize: $pageSize, area: $area)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMenuInputImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.styleConfig, styleConfig) ||
                other.styleConfig == styleConfig) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.area, area) || other.area == area));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, name, version, status, styleConfig, pageSize, area);

  /// Create a copy of CreateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMenuInputImplCopyWith<_$CreateMenuInputImpl> get copyWith =>
      __$$CreateMenuInputImplCopyWithImpl<_$CreateMenuInputImpl>(
          this, _$identity);
}

abstract class _CreateMenuInput implements CreateMenuInput {
  const factory _CreateMenuInput(
      {required final String name,
      required final String version,
      final MenuStatus? status,
      final StyleConfig? styleConfig,
      final PageSize? pageSize,
      final String? area}) = _$CreateMenuInputImpl;

  @override
  String get name;
  @override
  String get version;
  @override
  MenuStatus? get status;
  @override
  StyleConfig? get styleConfig;
  @override
  PageSize? get pageSize;
  @override
  String? get area;

  /// Create a copy of CreateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateMenuInputImplCopyWith<_$CreateMenuInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UpdateMenuInput {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  MenuStatus? get status => throw _privateConstructorUsedError;
  StyleConfig? get styleConfig => throw _privateConstructorUsedError;
  PageSize? get pageSize => throw _privateConstructorUsedError;
  String? get area => throw _privateConstructorUsedError;

  /// Create a copy of UpdateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateMenuInputCopyWith<UpdateMenuInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateMenuInputCopyWith<$Res> {
  factory $UpdateMenuInputCopyWith(
          UpdateMenuInput value, $Res Function(UpdateMenuInput) then) =
      _$UpdateMenuInputCopyWithImpl<$Res, UpdateMenuInput>;
  @useResult
  $Res call(
      {String id,
      String? name,
      String? version,
      MenuStatus? status,
      StyleConfig? styleConfig,
      PageSize? pageSize,
      String? area});

  $StyleConfigCopyWith<$Res>? get styleConfig;
  $PageSizeCopyWith<$Res>? get pageSize;
}

/// @nodoc
class _$UpdateMenuInputCopyWithImpl<$Res, $Val extends UpdateMenuInput>
    implements $UpdateMenuInputCopyWith<$Res> {
  _$UpdateMenuInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? version = freezed,
    Object? status = freezed,
    Object? styleConfig = freezed,
    Object? pageSize = freezed,
    Object? area = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MenuStatus?,
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

  /// Create a copy of UpdateMenuInput
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

  /// Create a copy of UpdateMenuInput
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
abstract class _$$UpdateMenuInputImplCopyWith<$Res>
    implements $UpdateMenuInputCopyWith<$Res> {
  factory _$$UpdateMenuInputImplCopyWith(_$UpdateMenuInputImpl value,
          $Res Function(_$UpdateMenuInputImpl) then) =
      __$$UpdateMenuInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? name,
      String? version,
      MenuStatus? status,
      StyleConfig? styleConfig,
      PageSize? pageSize,
      String? area});

  @override
  $StyleConfigCopyWith<$Res>? get styleConfig;
  @override
  $PageSizeCopyWith<$Res>? get pageSize;
}

/// @nodoc
class __$$UpdateMenuInputImplCopyWithImpl<$Res>
    extends _$UpdateMenuInputCopyWithImpl<$Res, _$UpdateMenuInputImpl>
    implements _$$UpdateMenuInputImplCopyWith<$Res> {
  __$$UpdateMenuInputImplCopyWithImpl(
      _$UpdateMenuInputImpl _value, $Res Function(_$UpdateMenuInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? version = freezed,
    Object? status = freezed,
    Object? styleConfig = freezed,
    Object? pageSize = freezed,
    Object? area = freezed,
  }) {
    return _then(_$UpdateMenuInputImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MenuStatus?,
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

class _$UpdateMenuInputImpl implements _UpdateMenuInput {
  const _$UpdateMenuInputImpl(
      {required this.id,
      this.name,
      this.version,
      this.status,
      this.styleConfig,
      this.pageSize,
      this.area});

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? version;
  @override
  final MenuStatus? status;
  @override
  final StyleConfig? styleConfig;
  @override
  final PageSize? pageSize;
  @override
  final String? area;

  @override
  String toString() {
    return 'UpdateMenuInput(id: $id, name: $name, version: $version, status: $status, styleConfig: $styleConfig, pageSize: $pageSize, area: $area)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateMenuInputImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.styleConfig, styleConfig) ||
                other.styleConfig == styleConfig) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.area, area) || other.area == area));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, version, status, styleConfig, pageSize, area);

  /// Create a copy of UpdateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateMenuInputImplCopyWith<_$UpdateMenuInputImpl> get copyWith =>
      __$$UpdateMenuInputImplCopyWithImpl<_$UpdateMenuInputImpl>(
          this, _$identity);
}

abstract class _UpdateMenuInput implements UpdateMenuInput {
  const factory _UpdateMenuInput(
      {required final String id,
      final String? name,
      final String? version,
      final MenuStatus? status,
      final StyleConfig? styleConfig,
      final PageSize? pageSize,
      final String? area}) = _$UpdateMenuInputImpl;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get version;
  @override
  MenuStatus? get status;
  @override
  StyleConfig? get styleConfig;
  @override
  PageSize? get pageSize;
  @override
  String? get area;

  /// Create a copy of UpdateMenuInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateMenuInputImplCopyWith<_$UpdateMenuInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
