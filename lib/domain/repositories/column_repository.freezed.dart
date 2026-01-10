// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'column_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreateColumnInput {
  String get containerId => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  int? get flex => throw _privateConstructorUsedError;
  double? get width => throw _privateConstructorUsedError;

  /// Create a copy of CreateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateColumnInputCopyWith<CreateColumnInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateColumnInputCopyWith<$Res> {
  factory $CreateColumnInputCopyWith(
          CreateColumnInput value, $Res Function(CreateColumnInput) then) =
      _$CreateColumnInputCopyWithImpl<$Res, CreateColumnInput>;
  @useResult
  $Res call({String containerId, int index, int? flex, double? width});
}

/// @nodoc
class _$CreateColumnInputCopyWithImpl<$Res, $Val extends CreateColumnInput>
    implements $CreateColumnInputCopyWith<$Res> {
  _$CreateColumnInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? containerId = null,
    Object? index = null,
    Object? flex = freezed,
    Object? width = freezed,
  }) {
    return _then(_value.copyWith(
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
abstract class _$$CreateColumnInputImplCopyWith<$Res>
    implements $CreateColumnInputCopyWith<$Res> {
  factory _$$CreateColumnInputImplCopyWith(_$CreateColumnInputImpl value,
          $Res Function(_$CreateColumnInputImpl) then) =
      __$$CreateColumnInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String containerId, int index, int? flex, double? width});
}

/// @nodoc
class __$$CreateColumnInputImplCopyWithImpl<$Res>
    extends _$CreateColumnInputCopyWithImpl<$Res, _$CreateColumnInputImpl>
    implements _$$CreateColumnInputImplCopyWith<$Res> {
  __$$CreateColumnInputImplCopyWithImpl(_$CreateColumnInputImpl _value,
      $Res Function(_$CreateColumnInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? containerId = null,
    Object? index = null,
    Object? flex = freezed,
    Object? width = freezed,
  }) {
    return _then(_$CreateColumnInputImpl(
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

class _$CreateColumnInputImpl implements _CreateColumnInput {
  const _$CreateColumnInputImpl(
      {required this.containerId, required this.index, this.flex, this.width});

  @override
  final String containerId;
  @override
  final int index;
  @override
  final int? flex;
  @override
  final double? width;

  @override
  String toString() {
    return 'CreateColumnInput(containerId: $containerId, index: $index, flex: $flex, width: $width)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateColumnInputImpl &&
            (identical(other.containerId, containerId) ||
                other.containerId == containerId) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.flex, flex) || other.flex == flex) &&
            (identical(other.width, width) || other.width == width));
  }

  @override
  int get hashCode => Object.hash(runtimeType, containerId, index, flex, width);

  /// Create a copy of CreateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateColumnInputImplCopyWith<_$CreateColumnInputImpl> get copyWith =>
      __$$CreateColumnInputImplCopyWithImpl<_$CreateColumnInputImpl>(
          this, _$identity);
}

abstract class _CreateColumnInput implements CreateColumnInput {
  const factory _CreateColumnInput(
      {required final String containerId,
      required final int index,
      final int? flex,
      final double? width}) = _$CreateColumnInputImpl;

  @override
  String get containerId;
  @override
  int get index;
  @override
  int? get flex;
  @override
  double? get width;

  /// Create a copy of CreateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateColumnInputImplCopyWith<_$CreateColumnInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UpdateColumnInput {
  String get id => throw _privateConstructorUsedError;
  int? get index => throw _privateConstructorUsedError;
  int? get flex => throw _privateConstructorUsedError;
  double? get width => throw _privateConstructorUsedError;

  /// Create a copy of UpdateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateColumnInputCopyWith<UpdateColumnInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateColumnInputCopyWith<$Res> {
  factory $UpdateColumnInputCopyWith(
          UpdateColumnInput value, $Res Function(UpdateColumnInput) then) =
      _$UpdateColumnInputCopyWithImpl<$Res, UpdateColumnInput>;
  @useResult
  $Res call({String id, int? index, int? flex, double? width});
}

/// @nodoc
class _$UpdateColumnInputCopyWithImpl<$Res, $Val extends UpdateColumnInput>
    implements $UpdateColumnInputCopyWith<$Res> {
  _$UpdateColumnInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? index = freezed,
    Object? flex = freezed,
    Object? width = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
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
abstract class _$$UpdateColumnInputImplCopyWith<$Res>
    implements $UpdateColumnInputCopyWith<$Res> {
  factory _$$UpdateColumnInputImplCopyWith(_$UpdateColumnInputImpl value,
          $Res Function(_$UpdateColumnInputImpl) then) =
      __$$UpdateColumnInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int? index, int? flex, double? width});
}

/// @nodoc
class __$$UpdateColumnInputImplCopyWithImpl<$Res>
    extends _$UpdateColumnInputCopyWithImpl<$Res, _$UpdateColumnInputImpl>
    implements _$$UpdateColumnInputImplCopyWith<$Res> {
  __$$UpdateColumnInputImplCopyWithImpl(_$UpdateColumnInputImpl _value,
      $Res Function(_$UpdateColumnInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? index = freezed,
    Object? flex = freezed,
    Object? width = freezed,
  }) {
    return _then(_$UpdateColumnInputImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
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

class _$UpdateColumnInputImpl implements _UpdateColumnInput {
  const _$UpdateColumnInputImpl(
      {required this.id, this.index, this.flex, this.width});

  @override
  final String id;
  @override
  final int? index;
  @override
  final int? flex;
  @override
  final double? width;

  @override
  String toString() {
    return 'UpdateColumnInput(id: $id, index: $index, flex: $flex, width: $width)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateColumnInputImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.flex, flex) || other.flex == flex) &&
            (identical(other.width, width) || other.width == width));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, index, flex, width);

  /// Create a copy of UpdateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateColumnInputImplCopyWith<_$UpdateColumnInputImpl> get copyWith =>
      __$$UpdateColumnInputImplCopyWithImpl<_$UpdateColumnInputImpl>(
          this, _$identity);
}

abstract class _UpdateColumnInput implements UpdateColumnInput {
  const factory _UpdateColumnInput(
      {required final String id,
      final int? index,
      final int? flex,
      final double? width}) = _$UpdateColumnInputImpl;

  @override
  String get id;
  @override
  int? get index;
  @override
  int? get flex;
  @override
  double? get width;

  /// Create a copy of UpdateColumnInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateColumnInputImplCopyWith<_$UpdateColumnInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
