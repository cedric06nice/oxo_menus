// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MenuDto _$MenuDtoFromJson(Map<String, dynamic> json) {
  return _MenuDto.fromJson(json);
}

/// @nodoc
mixin _$MenuDto {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_created')
  String? get userCreated => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_updated')
  String? get userUpdated => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  @JsonKey(name: 'style_json')
  Map<String, dynamic>? get styleJson => throw _privateConstructorUsedError;
  String? get area => throw _privateConstructorUsedError;
  Map<String, dynamic>? get size => throw _privateConstructorUsedError;

  /// Serializes this MenuDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuDtoCopyWith<MenuDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuDtoCopyWith<$Res> {
  factory $MenuDtoCopyWith(MenuDto value, $Res Function(MenuDto) then) =
      _$MenuDtoCopyWithImpl<$Res, MenuDto>;
  @useResult
  $Res call(
      {String id,
      String status,
      @JsonKey(name: 'date_created') DateTime? dateCreated,
      @JsonKey(name: 'date_updated') DateTime? dateUpdated,
      @JsonKey(name: 'user_created') String? userCreated,
      @JsonKey(name: 'user_updated') String? userUpdated,
      String name,
      String version,
      @JsonKey(name: 'style_json') Map<String, dynamic>? styleJson,
      String? area,
      Map<String, dynamic>? size});
}

/// @nodoc
class _$MenuDtoCopyWithImpl<$Res, $Val extends MenuDto>
    implements $MenuDtoCopyWith<$Res> {
  _$MenuDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? userCreated = freezed,
    Object? userUpdated = freezed,
    Object? name = null,
    Object? version = null,
    Object? styleJson = freezed,
    Object? area = freezed,
    Object? size = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      styleJson: freezed == styleJson
          ? _value.styleJson
          : styleJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenuDtoImplCopyWith<$Res> implements $MenuDtoCopyWith<$Res> {
  factory _$$MenuDtoImplCopyWith(
          _$MenuDtoImpl value, $Res Function(_$MenuDtoImpl) then) =
      __$$MenuDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      @JsonKey(name: 'date_created') DateTime? dateCreated,
      @JsonKey(name: 'date_updated') DateTime? dateUpdated,
      @JsonKey(name: 'user_created') String? userCreated,
      @JsonKey(name: 'user_updated') String? userUpdated,
      String name,
      String version,
      @JsonKey(name: 'style_json') Map<String, dynamic>? styleJson,
      String? area,
      Map<String, dynamic>? size});
}

/// @nodoc
class __$$MenuDtoImplCopyWithImpl<$Res>
    extends _$MenuDtoCopyWithImpl<$Res, _$MenuDtoImpl>
    implements _$$MenuDtoImplCopyWith<$Res> {
  __$$MenuDtoImplCopyWithImpl(
      _$MenuDtoImpl _value, $Res Function(_$MenuDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of MenuDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? userCreated = freezed,
    Object? userUpdated = freezed,
    Object? name = null,
    Object? version = null,
    Object? styleJson = freezed,
    Object? area = freezed,
    Object? size = freezed,
  }) {
    return _then(_$MenuDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      styleJson: freezed == styleJson
          ? _value._styleJson
          : styleJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value._size
          : size // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuDtoImpl implements _MenuDto {
  const _$MenuDtoImpl(
      {required this.id,
      required this.status,
      @JsonKey(name: 'date_created') this.dateCreated,
      @JsonKey(name: 'date_updated') this.dateUpdated,
      @JsonKey(name: 'user_created') this.userCreated,
      @JsonKey(name: 'user_updated') this.userUpdated,
      required this.name,
      required this.version,
      @JsonKey(name: 'style_json') final Map<String, dynamic>? styleJson,
      this.area,
      final Map<String, dynamic>? size})
      : _styleJson = styleJson,
        _size = size;

  factory _$MenuDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
  @override
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @override
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;
  @override
  @JsonKey(name: 'user_created')
  final String? userCreated;
  @override
  @JsonKey(name: 'user_updated')
  final String? userUpdated;
  @override
  final String name;
  @override
  final String version;
  final Map<String, dynamic>? _styleJson;
  @override
  @JsonKey(name: 'style_json')
  Map<String, dynamic>? get styleJson {
    final value = _styleJson;
    if (value == null) return null;
    if (_styleJson is EqualUnmodifiableMapView) return _styleJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? area;
  final Map<String, dynamic>? _size;
  @override
  Map<String, dynamic>? get size {
    final value = _size;
    if (value == null) return null;
    if (_size is EqualUnmodifiableMapView) return _size;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MenuDto(id: $id, status: $status, dateCreated: $dateCreated, dateUpdated: $dateUpdated, userCreated: $userCreated, userUpdated: $userUpdated, name: $name, version: $version, styleJson: $styleJson, area: $area, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.dateUpdated, dateUpdated) ||
                other.dateUpdated == dateUpdated) &&
            (identical(other.userCreated, userCreated) ||
                other.userCreated == userCreated) &&
            (identical(other.userUpdated, userUpdated) ||
                other.userUpdated == userUpdated) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality()
                .equals(other._styleJson, _styleJson) &&
            (identical(other.area, area) || other.area == area) &&
            const DeepCollectionEquality().equals(other._size, _size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      status,
      dateCreated,
      dateUpdated,
      userCreated,
      userUpdated,
      name,
      version,
      const DeepCollectionEquality().hash(_styleJson),
      area,
      const DeepCollectionEquality().hash(_size));

  /// Create a copy of MenuDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuDtoImplCopyWith<_$MenuDtoImpl> get copyWith =>
      __$$MenuDtoImplCopyWithImpl<_$MenuDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuDtoImplToJson(
      this,
    );
  }
}

abstract class _MenuDto implements MenuDto {
  const factory _MenuDto(
      {required final String id,
      required final String status,
      @JsonKey(name: 'date_created') final DateTime? dateCreated,
      @JsonKey(name: 'date_updated') final DateTime? dateUpdated,
      @JsonKey(name: 'user_created') final String? userCreated,
      @JsonKey(name: 'user_updated') final String? userUpdated,
      required final String name,
      required final String version,
      @JsonKey(name: 'style_json') final Map<String, dynamic>? styleJson,
      final String? area,
      final Map<String, dynamic>? size}) = _$MenuDtoImpl;

  factory _MenuDto.fromJson(Map<String, dynamic> json) = _$MenuDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated;
  @override
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated;
  @override
  @JsonKey(name: 'user_created')
  String? get userCreated;
  @override
  @JsonKey(name: 'user_updated')
  String? get userUpdated;
  @override
  String get name;
  @override
  String get version;
  @override
  @JsonKey(name: 'style_json')
  Map<String, dynamic>? get styleJson;
  @override
  String? get area;
  @override
  Map<String, dynamic>? get size;

  /// Create a copy of MenuDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuDtoImplCopyWith<_$MenuDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
