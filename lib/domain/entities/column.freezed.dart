// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'column.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Column _$ColumnFromJson(Map<String, dynamic> json) {
  return _Column.fromJson(json);
}

/// @nodoc
mixin _$Column {
  String get id => throw _privateConstructorUsedError;
  String get containerId => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  int? get flex => throw _privateConstructorUsedError;
  double? get width => throw _privateConstructorUsedError;
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  DateTime? get dateUpdated => throw _privateConstructorUsedError;

  /// Serializes this Column to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Column
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColumnCopyWith<Column> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColumnCopyWith<$Res> {
  factory $ColumnCopyWith(Column value, $Res Function(Column) then) =
      _$ColumnCopyWithImpl<$Res, Column>;
  @useResult
  $Res call(
      {String id,
      String containerId,
      int index,
      int? flex,
      double? width,
      DateTime? dateCreated,
      DateTime? dateUpdated});
}

/// @nodoc
class _$ColumnCopyWithImpl<$Res, $Val extends Column>
    implements $ColumnCopyWith<$Res> {
  _$ColumnCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Column
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? containerId = null,
    Object? index = null,
    Object? flex = freezed,
    Object? width = freezed,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _value.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ColumnImplCopyWith<$Res> implements $ColumnCopyWith<$Res> {
  factory _$$ColumnImplCopyWith(
          _$ColumnImpl value, $Res Function(_$ColumnImpl) then) =
      __$$ColumnImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String containerId,
      int index,
      int? flex,
      double? width,
      DateTime? dateCreated,
      DateTime? dateUpdated});
}

/// @nodoc
class __$$ColumnImplCopyWithImpl<$Res>
    extends _$ColumnCopyWithImpl<$Res, _$ColumnImpl>
    implements _$$ColumnImplCopyWith<$Res> {
  __$$ColumnImplCopyWithImpl(
      _$ColumnImpl _value, $Res Function(_$ColumnImpl) _then)
      : super(_value, _then);

  /// Create a copy of Column
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? containerId = null,
    Object? index = null,
    Object? flex = freezed,
    Object? width = freezed,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
  }) {
    return _then(_$ColumnImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _value.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ColumnImpl implements _Column {
  const _$ColumnImpl(
      {required this.id,
      required this.containerId,
      required this.index,
      this.flex,
      this.width,
      this.dateCreated,
      this.dateUpdated});

  factory _$ColumnImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColumnImplFromJson(json);

  @override
  final String id;
  @override
  final String containerId;
  @override
  final int index;
  @override
  final int? flex;
  @override
  final double? width;
  @override
  final DateTime? dateCreated;
  @override
  final DateTime? dateUpdated;

  @override
  String toString() {
    return 'Column(id: $id, containerId: $containerId, index: $index, flex: $flex, width: $width, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColumnImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.containerId, containerId) ||
                other.containerId == containerId) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.flex, flex) || other.flex == flex) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.dateUpdated, dateUpdated) ||
                other.dateUpdated == dateUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, containerId, index, flex,
      width, dateCreated, dateUpdated);

  /// Create a copy of Column
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColumnImplCopyWith<_$ColumnImpl> get copyWith =>
      __$$ColumnImplCopyWithImpl<_$ColumnImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColumnImplToJson(
      this,
    );
  }
}

abstract class _Column implements Column {
  const factory _Column(
      {required final String id,
      required final String containerId,
      required final int index,
      final int? flex,
      final double? width,
      final DateTime? dateCreated,
      final DateTime? dateUpdated}) = _$ColumnImpl;

  factory _Column.fromJson(Map<String, dynamic> json) = _$ColumnImpl.fromJson;

  @override
  String get id;
  @override
  String get containerId;
  @override
  int get index;
  @override
  int? get flex;
  @override
  double? get width;
  @override
  DateTime? get dateCreated;
  @override
  DateTime? get dateUpdated;

  /// Create a copy of Column
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColumnImplCopyWith<_$ColumnImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
