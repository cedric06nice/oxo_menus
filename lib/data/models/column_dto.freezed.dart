// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'column_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ColumnDto _$ColumnDtoFromJson(Map<String, dynamic> json) {
  return _ColumnDto.fromJson(json);
}

/// @nodoc
mixin _$ColumnDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'container_id')
  String get containerId => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  int? get flex => throw _privateConstructorUsedError;
  double? get width => throw _privateConstructorUsedError;

  /// Serializes this ColumnDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ColumnDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColumnDtoCopyWith<ColumnDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColumnDtoCopyWith<$Res> {
  factory $ColumnDtoCopyWith(ColumnDto value, $Res Function(ColumnDto) then) =
      _$ColumnDtoCopyWithImpl<$Res, ColumnDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'date_created') DateTime? dateCreated,
      @JsonKey(name: 'date_updated') DateTime? dateUpdated,
      @JsonKey(name: 'container_id') String containerId,
      int index,
      int? flex,
      double? width});
}

/// @nodoc
class _$ColumnDtoCopyWithImpl<$Res, $Val extends ColumnDto>
    implements $ColumnDtoCopyWith<$Res> {
  _$ColumnDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColumnDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? containerId = null,
    Object? index = null,
    Object? flex = freezed,
    Object? width = freezed,
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
      containerId: null == containerId
          ? _value.containerId
          : containerId // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      flex: freezed == flex
          ? _value.flex
          : flex // ignore: cast_nullable_to_non_nullable
              as int?,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ColumnDtoImplCopyWith<$Res>
    implements $ColumnDtoCopyWith<$Res> {
  factory _$$ColumnDtoImplCopyWith(
          _$ColumnDtoImpl value, $Res Function(_$ColumnDtoImpl) then) =
      __$$ColumnDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'date_created') DateTime? dateCreated,
      @JsonKey(name: 'date_updated') DateTime? dateUpdated,
      @JsonKey(name: 'container_id') String containerId,
      int index,
      int? flex,
      double? width});
}

/// @nodoc
class __$$ColumnDtoImplCopyWithImpl<$Res>
    extends _$ColumnDtoCopyWithImpl<$Res, _$ColumnDtoImpl>
    implements _$$ColumnDtoImplCopyWith<$Res> {
  __$$ColumnDtoImplCopyWithImpl(
      _$ColumnDtoImpl _value, $Res Function(_$ColumnDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ColumnDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? containerId = null,
    Object? index = null,
    Object? flex = freezed,
    Object? width = freezed,
  }) {
    return _then(_$ColumnDtoImpl(
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
      containerId: null == containerId
          ? _value.containerId
          : containerId // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      flex: freezed == flex
          ? _value.flex
          : flex // ignore: cast_nullable_to_non_nullable
              as int?,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ColumnDtoImpl implements _ColumnDto {
  const _$ColumnDtoImpl(
      {required this.id,
      @JsonKey(name: 'date_created') this.dateCreated,
      @JsonKey(name: 'date_updated') this.dateUpdated,
      @JsonKey(name: 'container_id') required this.containerId,
      required this.index,
      this.flex,
      this.width});

  factory _$ColumnDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColumnDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @override
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;
  @override
  @JsonKey(name: 'container_id')
  final String containerId;
  @override
  final int index;
  @override
  final int? flex;
  @override
  final double? width;

  @override
  String toString() {
    return 'ColumnDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, containerId: $containerId, index: $index, flex: $flex, width: $width)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColumnDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.dateUpdated, dateUpdated) ||
                other.dateUpdated == dateUpdated) &&
            (identical(other.containerId, containerId) ||
                other.containerId == containerId) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.flex, flex) || other.flex == flex) &&
            (identical(other.width, width) || other.width == width));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, dateCreated, dateUpdated,
      containerId, index, flex, width);

  /// Create a copy of ColumnDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColumnDtoImplCopyWith<_$ColumnDtoImpl> get copyWith =>
      __$$ColumnDtoImplCopyWithImpl<_$ColumnDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColumnDtoImplToJson(
      this,
    );
  }
}

abstract class _ColumnDto implements ColumnDto {
  const factory _ColumnDto(
      {required final String id,
      @JsonKey(name: 'date_created') final DateTime? dateCreated,
      @JsonKey(name: 'date_updated') final DateTime? dateUpdated,
      @JsonKey(name: 'container_id') required final String containerId,
      required final int index,
      final int? flex,
      final double? width}) = _$ColumnDtoImpl;

  factory _ColumnDto.fromJson(Map<String, dynamic> json) =
      _$ColumnDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated;
  @override
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated;
  @override
  @JsonKey(name: 'container_id')
  String get containerId;
  @override
  int get index;
  @override
  int? get flex;
  @override
  double? get width;

  /// Create a copy of ColumnDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColumnDtoImplCopyWith<_$ColumnDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
