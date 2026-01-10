// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PageDto _$PageDtoFromJson(Map<String, dynamic> json) {
  return _PageDto.fromJson(json);
}

/// @nodoc
mixin _$PageDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'menu_id')
  String get menuId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;

  /// Serializes this PageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageDtoCopyWith<PageDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageDtoCopyWith<$Res> {
  factory $PageDtoCopyWith(PageDto value, $Res Function(PageDto) then) =
      _$PageDtoCopyWithImpl<$Res, PageDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'date_created') DateTime? dateCreated,
      @JsonKey(name: 'date_updated') DateTime? dateUpdated,
      @JsonKey(name: 'menu_id') String menuId,
      String name,
      int index});
}

/// @nodoc
class _$PageDtoCopyWithImpl<$Res, $Val extends PageDto>
    implements $PageDtoCopyWith<$Res> {
  _$PageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? menuId = null,
    Object? name = null,
    Object? index = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _value.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      menuId: null == menuId
          ? _value.menuId
          : menuId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PageDtoImplCopyWith<$Res> implements $PageDtoCopyWith<$Res> {
  factory _$$PageDtoImplCopyWith(
          _$PageDtoImpl value, $Res Function(_$PageDtoImpl) then) =
      __$$PageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'date_created') DateTime? dateCreated,
      @JsonKey(name: 'date_updated') DateTime? dateUpdated,
      @JsonKey(name: 'menu_id') String menuId,
      String name,
      int index});
}

/// @nodoc
class __$$PageDtoImplCopyWithImpl<$Res>
    extends _$PageDtoCopyWithImpl<$Res, _$PageDtoImpl>
    implements _$$PageDtoImplCopyWith<$Res> {
  __$$PageDtoImplCopyWithImpl(
      _$PageDtoImpl _value, $Res Function(_$PageDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? menuId = null,
    Object? name = null,
    Object? index = null,
  }) {
    return _then(_$PageDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _value.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      menuId: null == menuId
          ? _value.menuId
          : menuId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PageDtoImpl implements _PageDto {
  const _$PageDtoImpl(
      {required this.id,
      @JsonKey(name: 'date_created') this.dateCreated,
      @JsonKey(name: 'date_updated') this.dateUpdated,
      @JsonKey(name: 'menu_id') required this.menuId,
      required this.name,
      required this.index});

  factory _$PageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @override
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;
  @override
  @JsonKey(name: 'menu_id')
  final String menuId;
  @override
  final String name;
  @override
  final int index;

  @override
  String toString() {
    return 'PageDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, menuId: $menuId, name: $name, index: $index)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.dateUpdated, dateUpdated) ||
                other.dateUpdated == dateUpdated) &&
            (identical(other.menuId, menuId) || other.menuId == menuId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.index, index) || other.index == index));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, dateCreated, dateUpdated, menuId, name, index);

  /// Create a copy of PageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageDtoImplCopyWith<_$PageDtoImpl> get copyWith =>
      __$$PageDtoImplCopyWithImpl<_$PageDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PageDtoImplToJson(
      this,
    );
  }
}

abstract class _PageDto implements PageDto {
  const factory _PageDto(
      {required final String id,
      @JsonKey(name: 'date_created') final DateTime? dateCreated,
      @JsonKey(name: 'date_updated') final DateTime? dateUpdated,
      @JsonKey(name: 'menu_id') required final String menuId,
      required final String name,
      required final int index}) = _$PageDtoImpl;

  factory _PageDto.fromJson(Map<String, dynamic> json) = _$PageDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated;
  @override
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated;
  @override
  @JsonKey(name: 'menu_id')
  String get menuId;
  @override
  String get name;
  @override
  int get index;

  /// Create a copy of PageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageDtoImplCopyWith<_$PageDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
