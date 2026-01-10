// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'widget_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreateWidgetInput {
  String get columnId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  Map<String, dynamic> get props => throw _privateConstructorUsedError;
  WidgetStyle? get style => throw _privateConstructorUsedError;

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateWidgetInputCopyWith<CreateWidgetInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateWidgetInputCopyWith<$Res> {
  factory $CreateWidgetInputCopyWith(
          CreateWidgetInput value, $Res Function(CreateWidgetInput) then) =
      _$CreateWidgetInputCopyWithImpl<$Res, CreateWidgetInput>;
  @useResult
  $Res call(
      {String columnId,
      String type,
      String version,
      int index,
      Map<String, dynamic> props,
      WidgetStyle? style});

  $WidgetStyleCopyWith<$Res>? get style;
}

/// @nodoc
class _$CreateWidgetInputCopyWithImpl<$Res, $Val extends CreateWidgetInput>
    implements $CreateWidgetInputCopyWith<$Res> {
  _$CreateWidgetInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columnId = null,
    Object? type = null,
    Object? version = null,
    Object? index = null,
    Object? props = null,
    Object? style = freezed,
  }) {
    return _then(_value.copyWith(
      columnId: null == columnId
          ? _value.columnId
          : columnId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      props: null == props
          ? _value.props
          : props // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as WidgetStyle?,
    ) as $Val);
  }

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WidgetStyleCopyWith<$Res>? get style {
    if (_value.style == null) {
      return null;
    }

    return $WidgetStyleCopyWith<$Res>(_value.style!, (value) {
      return _then(_value.copyWith(style: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateWidgetInputImplCopyWith<$Res>
    implements $CreateWidgetInputCopyWith<$Res> {
  factory _$$CreateWidgetInputImplCopyWith(_$CreateWidgetInputImpl value,
          $Res Function(_$CreateWidgetInputImpl) then) =
      __$$CreateWidgetInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String columnId,
      String type,
      String version,
      int index,
      Map<String, dynamic> props,
      WidgetStyle? style});

  @override
  $WidgetStyleCopyWith<$Res>? get style;
}

/// @nodoc
class __$$CreateWidgetInputImplCopyWithImpl<$Res>
    extends _$CreateWidgetInputCopyWithImpl<$Res, _$CreateWidgetInputImpl>
    implements _$$CreateWidgetInputImplCopyWith<$Res> {
  __$$CreateWidgetInputImplCopyWithImpl(_$CreateWidgetInputImpl _value,
      $Res Function(_$CreateWidgetInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columnId = null,
    Object? type = null,
    Object? version = null,
    Object? index = null,
    Object? props = null,
    Object? style = freezed,
  }) {
    return _then(_$CreateWidgetInputImpl(
      columnId: null == columnId
          ? _value.columnId
          : columnId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      props: null == props
          ? _value._props
          : props // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as WidgetStyle?,
    ));
  }
}

/// @nodoc

class _$CreateWidgetInputImpl implements _CreateWidgetInput {
  const _$CreateWidgetInputImpl(
      {required this.columnId,
      required this.type,
      required this.version,
      required this.index,
      required final Map<String, dynamic> props,
      this.style})
      : _props = props;

  @override
  final String columnId;
  @override
  final String type;
  @override
  final String version;
  @override
  final int index;
  final Map<String, dynamic> _props;
  @override
  Map<String, dynamic> get props {
    if (_props is EqualUnmodifiableMapView) return _props;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_props);
  }

  @override
  final WidgetStyle? style;

  @override
  String toString() {
    return 'CreateWidgetInput(columnId: $columnId, type: $type, version: $version, index: $index, props: $props, style: $style)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateWidgetInputImpl &&
            (identical(other.columnId, columnId) ||
                other.columnId == columnId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality().equals(other._props, _props) &&
            (identical(other.style, style) || other.style == style));
  }

  @override
  int get hashCode => Object.hash(runtimeType, columnId, type, version, index,
      const DeepCollectionEquality().hash(_props), style);

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateWidgetInputImplCopyWith<_$CreateWidgetInputImpl> get copyWith =>
      __$$CreateWidgetInputImplCopyWithImpl<_$CreateWidgetInputImpl>(
          this, _$identity);
}

abstract class _CreateWidgetInput implements CreateWidgetInput {
  const factory _CreateWidgetInput(
      {required final String columnId,
      required final String type,
      required final String version,
      required final int index,
      required final Map<String, dynamic> props,
      final WidgetStyle? style}) = _$CreateWidgetInputImpl;

  @override
  String get columnId;
  @override
  String get type;
  @override
  String get version;
  @override
  int get index;
  @override
  Map<String, dynamic> get props;
  @override
  WidgetStyle? get style;

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateWidgetInputImplCopyWith<_$CreateWidgetInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UpdateWidgetInput {
  String get id => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  int? get index => throw _privateConstructorUsedError;
  Map<String, dynamic>? get props => throw _privateConstructorUsedError;
  WidgetStyle? get style => throw _privateConstructorUsedError;

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateWidgetInputCopyWith<UpdateWidgetInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateWidgetInputCopyWith<$Res> {
  factory $UpdateWidgetInputCopyWith(
          UpdateWidgetInput value, $Res Function(UpdateWidgetInput) then) =
      _$UpdateWidgetInputCopyWithImpl<$Res, UpdateWidgetInput>;
  @useResult
  $Res call(
      {String id,
      String? type,
      String? version,
      int? index,
      Map<String, dynamic>? props,
      WidgetStyle? style});

  $WidgetStyleCopyWith<$Res>? get style;
}

/// @nodoc
class _$UpdateWidgetInputCopyWithImpl<$Res, $Val extends UpdateWidgetInput>
    implements $UpdateWidgetInputCopyWith<$Res> {
  _$UpdateWidgetInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = freezed,
    Object? version = freezed,
    Object? index = freezed,
    Object? props = freezed,
    Object? style = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
      props: freezed == props
          ? _value.props
          : props // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as WidgetStyle?,
    ) as $Val);
  }

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WidgetStyleCopyWith<$Res>? get style {
    if (_value.style == null) {
      return null;
    }

    return $WidgetStyleCopyWith<$Res>(_value.style!, (value) {
      return _then(_value.copyWith(style: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdateWidgetInputImplCopyWith<$Res>
    implements $UpdateWidgetInputCopyWith<$Res> {
  factory _$$UpdateWidgetInputImplCopyWith(_$UpdateWidgetInputImpl value,
          $Res Function(_$UpdateWidgetInputImpl) then) =
      __$$UpdateWidgetInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? type,
      String? version,
      int? index,
      Map<String, dynamic>? props,
      WidgetStyle? style});

  @override
  $WidgetStyleCopyWith<$Res>? get style;
}

/// @nodoc
class __$$UpdateWidgetInputImplCopyWithImpl<$Res>
    extends _$UpdateWidgetInputCopyWithImpl<$Res, _$UpdateWidgetInputImpl>
    implements _$$UpdateWidgetInputImplCopyWith<$Res> {
  __$$UpdateWidgetInputImplCopyWithImpl(_$UpdateWidgetInputImpl _value,
      $Res Function(_$UpdateWidgetInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = freezed,
    Object? version = freezed,
    Object? index = freezed,
    Object? props = freezed,
    Object? style = freezed,
  }) {
    return _then(_$UpdateWidgetInputImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      index: freezed == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
      props: freezed == props
          ? _value._props
          : props // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as WidgetStyle?,
    ));
  }
}

/// @nodoc

class _$UpdateWidgetInputImpl implements _UpdateWidgetInput {
  const _$UpdateWidgetInputImpl(
      {required this.id,
      this.type,
      this.version,
      this.index,
      final Map<String, dynamic>? props,
      this.style})
      : _props = props;

  @override
  final String id;
  @override
  final String? type;
  @override
  final String? version;
  @override
  final int? index;
  final Map<String, dynamic>? _props;
  @override
  Map<String, dynamic>? get props {
    final value = _props;
    if (value == null) return null;
    if (_props is EqualUnmodifiableMapView) return _props;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final WidgetStyle? style;

  @override
  String toString() {
    return 'UpdateWidgetInput(id: $id, type: $type, version: $version, index: $index, props: $props, style: $style)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateWidgetInputImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality().equals(other._props, _props) &&
            (identical(other.style, style) || other.style == style));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, type, version, index,
      const DeepCollectionEquality().hash(_props), style);

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateWidgetInputImplCopyWith<_$UpdateWidgetInputImpl> get copyWith =>
      __$$UpdateWidgetInputImplCopyWithImpl<_$UpdateWidgetInputImpl>(
          this, _$identity);
}

abstract class _UpdateWidgetInput implements UpdateWidgetInput {
  const factory _UpdateWidgetInput(
      {required final String id,
      final String? type,
      final String? version,
      final int? index,
      final Map<String, dynamic>? props,
      final WidgetStyle? style}) = _$UpdateWidgetInputImpl;

  @override
  String get id;
  @override
  String? get type;
  @override
  String? get version;
  @override
  int? get index;
  @override
  Map<String, dynamic>? get props;
  @override
  WidgetStyle? get style;

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateWidgetInputImplCopyWith<_$UpdateWidgetInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
