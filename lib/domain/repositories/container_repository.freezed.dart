// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreateContainerInput {
  String get pageId => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  LayoutConfig? get layout => throw _privateConstructorUsedError;

  /// Create a copy of CreateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateContainerInputCopyWith<CreateContainerInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateContainerInputCopyWith<$Res> {
  factory $CreateContainerInputCopyWith(CreateContainerInput value,
          $Res Function(CreateContainerInput) then) =
      _$CreateContainerInputCopyWithImpl<$Res, CreateContainerInput>;
  @useResult
  $Res call({String pageId, int index, String? name, LayoutConfig? layout});

  $LayoutConfigCopyWith<$Res>? get layout;
}

/// @nodoc
class _$CreateContainerInputCopyWithImpl<$Res,
        $Val extends CreateContainerInput>
    implements $CreateContainerInputCopyWith<$Res> {
  _$CreateContainerInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pageId = null,
    Object? index = null,
    Object? name = freezed,
    Object? layout = freezed,
  }) {
    return _then(_value.copyWith(
      pageId: null == pageId
          ? _value.pageId
          : pageId // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      layout: freezed == layout
          ? _value.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as LayoutConfig?,
    ) as $Val);
  }

  /// Create a copy of CreateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutConfigCopyWith<$Res>? get layout {
    if (_value.layout == null) {
      return null;
    }

    return $LayoutConfigCopyWith<$Res>(_value.layout!, (value) {
      return _then(_value.copyWith(layout: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateContainerInputImplCopyWith<$Res>
    implements $CreateContainerInputCopyWith<$Res> {
  factory _$$CreateContainerInputImplCopyWith(_$CreateContainerInputImpl value,
          $Res Function(_$CreateContainerInputImpl) then) =
      __$$CreateContainerInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String pageId, int index, String? name, LayoutConfig? layout});

  @override
  $LayoutConfigCopyWith<$Res>? get layout;
}

/// @nodoc
class __$$CreateContainerInputImplCopyWithImpl<$Res>
    extends _$CreateContainerInputCopyWithImpl<$Res, _$CreateContainerInputImpl>
    implements _$$CreateContainerInputImplCopyWith<$Res> {
  __$$CreateContainerInputImplCopyWithImpl(_$CreateContainerInputImpl _value,
      $Res Function(_$CreateContainerInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pageId = null,
    Object? index = null,
    Object? name = freezed,
    Object? layout = freezed,
  }) {
    return _then(_$CreateContainerInputImpl(
      pageId: null == pageId
          ? _value.pageId
          : pageId // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      layout: freezed == layout
          ? _value.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as LayoutConfig?,
    ));
  }
}

/// @nodoc

class _$CreateContainerInputImpl implements _CreateContainerInput {
  const _$CreateContainerInputImpl(
      {required this.pageId, required this.index, this.name, this.layout});

  @override
  final String pageId;
  @override
  final int index;
  @override
  final String? name;
  @override
  final LayoutConfig? layout;

  @override
  String toString() {
    return 'CreateContainerInput(pageId: $pageId, index: $index, name: $name, layout: $layout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateContainerInputImpl &&
            (identical(other.pageId, pageId) || other.pageId == pageId) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.layout, layout) || other.layout == layout));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pageId, index, name, layout);

  /// Create a copy of CreateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateContainerInputImplCopyWith<_$CreateContainerInputImpl>
      get copyWith =>
          __$$CreateContainerInputImplCopyWithImpl<_$CreateContainerInputImpl>(
              this, _$identity);
}

abstract class _CreateContainerInput implements CreateContainerInput {
  const factory _CreateContainerInput(
      {required final String pageId,
      required final int index,
      final String? name,
      final LayoutConfig? layout}) = _$CreateContainerInputImpl;

  @override
  String get pageId;
  @override
  int get index;
  @override
  String? get name;
  @override
  LayoutConfig? get layout;

  /// Create a copy of CreateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateContainerInputImplCopyWith<_$CreateContainerInputImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UpdateContainerInput {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get index => throw _privateConstructorUsedError;
  LayoutConfig? get layout => throw _privateConstructorUsedError;

  /// Create a copy of UpdateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateContainerInputCopyWith<UpdateContainerInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateContainerInputCopyWith<$Res> {
  factory $UpdateContainerInputCopyWith(UpdateContainerInput value,
          $Res Function(UpdateContainerInput) then) =
      _$UpdateContainerInputCopyWithImpl<$Res, UpdateContainerInput>;
  @useResult
  $Res call({String id, String? name, int? index, LayoutConfig? layout});

  $LayoutConfigCopyWith<$Res>? get layout;
}

/// @nodoc
class _$UpdateContainerInputCopyWithImpl<$Res,
        $Val extends UpdateContainerInput>
    implements $UpdateContainerInputCopyWith<$Res> {
  _$UpdateContainerInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? index = freezed,
    Object? layout = freezed,
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
      layout: freezed == layout
          ? _value.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as LayoutConfig?,
    ) as $Val);
  }

  /// Create a copy of UpdateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutConfigCopyWith<$Res>? get layout {
    if (_value.layout == null) {
      return null;
    }

    return $LayoutConfigCopyWith<$Res>(_value.layout!, (value) {
      return _then(_value.copyWith(layout: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdateContainerInputImplCopyWith<$Res>
    implements $UpdateContainerInputCopyWith<$Res> {
  factory _$$UpdateContainerInputImplCopyWith(_$UpdateContainerInputImpl value,
          $Res Function(_$UpdateContainerInputImpl) then) =
      __$$UpdateContainerInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? name, int? index, LayoutConfig? layout});

  @override
  $LayoutConfigCopyWith<$Res>? get layout;
}

/// @nodoc
class __$$UpdateContainerInputImplCopyWithImpl<$Res>
    extends _$UpdateContainerInputCopyWithImpl<$Res, _$UpdateContainerInputImpl>
    implements _$$UpdateContainerInputImplCopyWith<$Res> {
  __$$UpdateContainerInputImplCopyWithImpl(_$UpdateContainerInputImpl _value,
      $Res Function(_$UpdateContainerInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? index = freezed,
    Object? layout = freezed,
  }) {
    return _then(_$UpdateContainerInputImpl(
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
      layout: freezed == layout
          ? _value.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as LayoutConfig?,
    ));
  }
}

/// @nodoc

class _$UpdateContainerInputImpl implements _UpdateContainerInput {
  const _$UpdateContainerInputImpl(
      {required this.id, this.name, this.index, this.layout});

  @override
  final String id;
  @override
  final String? name;
  @override
  final int? index;
  @override
  final LayoutConfig? layout;

  @override
  String toString() {
    return 'UpdateContainerInput(id: $id, name: $name, index: $index, layout: $layout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateContainerInputImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.layout, layout) || other.layout == layout));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, index, layout);

  /// Create a copy of UpdateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateContainerInputImplCopyWith<_$UpdateContainerInputImpl>
      get copyWith =>
          __$$UpdateContainerInputImplCopyWithImpl<_$UpdateContainerInputImpl>(
              this, _$identity);
}

abstract class _UpdateContainerInput implements UpdateContainerInput {
  const factory _UpdateContainerInput(
      {required final String id,
      final String? name,
      final int? index,
      final LayoutConfig? layout}) = _$UpdateContainerInputImpl;

  @override
  String get id;
  @override
  String? get name;
  @override
  int? get index;
  @override
  LayoutConfig? get layout;

  /// Create a copy of UpdateContainerInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateContainerInputImplCopyWith<_$UpdateContainerInputImpl>
      get copyWith => throw _privateConstructorUsedError;
}
