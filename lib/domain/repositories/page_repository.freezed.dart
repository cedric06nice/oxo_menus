// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreatePageInput {
  String get menuId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;

  /// Create a copy of CreatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatePageInputCopyWith<CreatePageInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePageInputCopyWith<$Res> {
  factory $CreatePageInputCopyWith(
          CreatePageInput value, $Res Function(CreatePageInput) then) =
      _$CreatePageInputCopyWithImpl<$Res, CreatePageInput>;
  @useResult
  $Res call({String menuId, String name, int index});
}

/// @nodoc
class _$CreatePageInputCopyWithImpl<$Res, $Val extends CreatePageInput>
    implements $CreatePageInputCopyWith<$Res> {
  _$CreatePageInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuId = null,
    Object? name = null,
    Object? index = null,
  }) {
    return _then(_value.copyWith(
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
abstract class _$$CreatePageInputImplCopyWith<$Res>
    implements $CreatePageInputCopyWith<$Res> {
  factory _$$CreatePageInputImplCopyWith(_$CreatePageInputImpl value,
          $Res Function(_$CreatePageInputImpl) then) =
      __$$CreatePageInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String menuId, String name, int index});
}

/// @nodoc
class __$$CreatePageInputImplCopyWithImpl<$Res>
    extends _$CreatePageInputCopyWithImpl<$Res, _$CreatePageInputImpl>
    implements _$$CreatePageInputImplCopyWith<$Res> {
  __$$CreatePageInputImplCopyWithImpl(
      _$CreatePageInputImpl _value, $Res Function(_$CreatePageInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuId = null,
    Object? name = null,
    Object? index = null,
  }) {
    return _then(_$CreatePageInputImpl(
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

class _$CreatePageInputImpl implements _CreatePageInput {
  const _$CreatePageInputImpl(
      {required this.menuId, required this.name, required this.index});

  @override
  final String menuId;
  @override
  final String name;
  @override
  final int index;

  @override
  String toString() {
    return 'CreatePageInput(menuId: $menuId, name: $name, index: $index)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePageInputImpl &&
            (identical(other.menuId, menuId) || other.menuId == menuId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(runtimeType, menuId, name, index);

  /// Create a copy of CreatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePageInputImplCopyWith<_$CreatePageInputImpl> get copyWith =>
      __$$CreatePageInputImplCopyWithImpl<_$CreatePageInputImpl>(
          this, _$identity);
}

abstract class _CreatePageInput implements CreatePageInput {
  const factory _CreatePageInput(
      {required final String menuId,
      required final String name,
      required final int index}) = _$CreatePageInputImpl;

  @override
  String get menuId;
  @override
  String get name;
  @override
  int get index;

  /// Create a copy of CreatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatePageInputImplCopyWith<_$CreatePageInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UpdatePageInput {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get index => throw _privateConstructorUsedError;

  /// Create a copy of UpdatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdatePageInputCopyWith<UpdatePageInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdatePageInputCopyWith<$Res> {
  factory $UpdatePageInputCopyWith(
          UpdatePageInput value, $Res Function(UpdatePageInput) then) =
      _$UpdatePageInputCopyWithImpl<$Res, UpdatePageInput>;
  @useResult
  $Res call({String id, String? name, int? index});
}

/// @nodoc
class _$UpdatePageInputCopyWithImpl<$Res, $Val extends UpdatePageInput>
    implements $UpdatePageInputCopyWith<$Res> {
  _$UpdatePageInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? index = freezed,
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
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdatePageInputImplCopyWith<$Res>
    implements $UpdatePageInputCopyWith<$Res> {
  factory _$$UpdatePageInputImplCopyWith(_$UpdatePageInputImpl value,
          $Res Function(_$UpdatePageInputImpl) then) =
      __$$UpdatePageInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? name, int? index});
}

/// @nodoc
class __$$UpdatePageInputImplCopyWithImpl<$Res>
    extends _$UpdatePageInputCopyWithImpl<$Res, _$UpdatePageInputImpl>
    implements _$$UpdatePageInputImplCopyWith<$Res> {
  __$$UpdatePageInputImplCopyWithImpl(
      _$UpdatePageInputImpl _value, $Res Function(_$UpdatePageInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? index = freezed,
  }) {
    return _then(_$UpdatePageInputImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$UpdatePageInputImpl implements _UpdatePageInput {
  const _$UpdatePageInputImpl({required this.id, this.name, this.index});

  @override
  final String id;
  @override
  final String? name;
  @override
  final int? index;

  @override
  String toString() {
    return 'UpdatePageInput(id: $id, name: $name, index: $index)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdatePageInputImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, index);

  /// Create a copy of UpdatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdatePageInputImplCopyWith<_$UpdatePageInputImpl> get copyWith =>
      __$$UpdatePageInputImplCopyWithImpl<_$UpdatePageInputImpl>(
          this, _$identity);
}

abstract class _UpdatePageInput implements UpdatePageInput {
  const factory _UpdatePageInput(
      {required final String id,
      final String? name,
      final int? index}) = _$UpdatePageInputImpl;

  @override
  String get id;
  @override
  String? get name;
  @override
  int? get index;

  /// Create a copy of UpdatePageInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdatePageInputImplCopyWith<_$UpdatePageInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
