// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Container _$ContainerFromJson(Map<String, dynamic> json) {
  return _Container.fromJson(json);
}

/// @nodoc
mixin _$Container {
  String get id => throw _privateConstructorUsedError;
  String get pageId => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  LayoutConfig? get layout => throw _privateConstructorUsedError;
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  DateTime? get dateUpdated => throw _privateConstructorUsedError;

  /// Serializes this Container to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Container
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContainerCopyWith<Container> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContainerCopyWith<$Res> {
  factory $ContainerCopyWith(Container value, $Res Function(Container) then) =
      _$ContainerCopyWithImpl<$Res, Container>;
  @useResult
  $Res call(
      {String id,
      String pageId,
      int index,
      String? name,
      LayoutConfig? layout,
      DateTime? dateCreated,
      DateTime? dateUpdated});

  $LayoutConfigCopyWith<$Res>? get layout;
}

/// @nodoc
class _$ContainerCopyWithImpl<$Res, $Val extends Container>
    implements $ContainerCopyWith<$Res> {
  _$ContainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Container
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageId = null,
    Object? index = null,
    Object? name = freezed,
    Object? layout = freezed,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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

  /// Create a copy of Container
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
abstract class _$$ContainerImplCopyWith<$Res>
    implements $ContainerCopyWith<$Res> {
  factory _$$ContainerImplCopyWith(
          _$ContainerImpl value, $Res Function(_$ContainerImpl) then) =
      __$$ContainerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String pageId,
      int index,
      String? name,
      LayoutConfig? layout,
      DateTime? dateCreated,
      DateTime? dateUpdated});

  @override
  $LayoutConfigCopyWith<$Res>? get layout;
}

/// @nodoc
class __$$ContainerImplCopyWithImpl<$Res>
    extends _$ContainerCopyWithImpl<$Res, _$ContainerImpl>
    implements _$$ContainerImplCopyWith<$Res> {
  __$$ContainerImplCopyWithImpl(
      _$ContainerImpl _value, $Res Function(_$ContainerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Container
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageId = null,
    Object? index = null,
    Object? name = freezed,
    Object? layout = freezed,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
  }) {
    return _then(_$ContainerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$ContainerImpl implements _Container {
  const _$ContainerImpl(
      {required this.id,
      required this.pageId,
      required this.index,
      this.name,
      this.layout,
      this.dateCreated,
      this.dateUpdated});

  factory _$ContainerImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContainerImplFromJson(json);

  @override
  final String id;
  @override
  final String pageId;
  @override
  final int index;
  @override
  final String? name;
  @override
  final LayoutConfig? layout;
  @override
  final DateTime? dateCreated;
  @override
  final DateTime? dateUpdated;

  @override
  String toString() {
    return 'Container(id: $id, pageId: $pageId, index: $index, name: $name, layout: $layout, dateCreated: $dateCreated, dateUpdated: $dateUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContainerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageId, pageId) || other.pageId == pageId) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.dateUpdated, dateUpdated) ||
                other.dateUpdated == dateUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, pageId, index, name, layout, dateCreated, dateUpdated);

  /// Create a copy of Container
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerImplCopyWith<_$ContainerImpl> get copyWith =>
      __$$ContainerImplCopyWithImpl<_$ContainerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContainerImplToJson(
      this,
    );
  }
}

abstract class _Container implements Container {
  const factory _Container(
      {required final String id,
      required final String pageId,
      required final int index,
      final String? name,
      final LayoutConfig? layout,
      final DateTime? dateCreated,
      final DateTime? dateUpdated}) = _$ContainerImpl;

  factory _Container.fromJson(Map<String, dynamic> json) =
      _$ContainerImpl.fromJson;

  @override
  String get id;
  @override
  String get pageId;
  @override
  int get index;
  @override
  String? get name;
  @override
  LayoutConfig? get layout;
  @override
  DateTime? get dateCreated;
  @override
  DateTime? get dateUpdated;

  /// Create a copy of Container
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContainerImplCopyWith<_$ContainerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LayoutConfig _$LayoutConfigFromJson(Map<String, dynamic> json) {
  return _LayoutConfig.fromJson(json);
}

/// @nodoc
mixin _$LayoutConfig {
  String? get direction => throw _privateConstructorUsedError;
  String? get alignment => throw _privateConstructorUsedError;
  double? get spacing => throw _privateConstructorUsedError;

  /// Serializes this LayoutConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LayoutConfigCopyWith<LayoutConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayoutConfigCopyWith<$Res> {
  factory $LayoutConfigCopyWith(
          LayoutConfig value, $Res Function(LayoutConfig) then) =
      _$LayoutConfigCopyWithImpl<$Res, LayoutConfig>;
  @useResult
  $Res call({String? direction, String? alignment, double? spacing});
}

/// @nodoc
class _$LayoutConfigCopyWithImpl<$Res, $Val extends LayoutConfig>
    implements $LayoutConfigCopyWith<$Res> {
  _$LayoutConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? direction = freezed,
    Object? alignment = freezed,
    Object? spacing = freezed,
  }) {
    return _then(_value.copyWith(
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
      alignment: freezed == alignment
          ? _value.alignment
          : alignment // ignore: cast_nullable_to_non_nullable
              as String?,
      spacing: freezed == spacing
          ? _value.spacing
          : spacing // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LayoutConfigImplCopyWith<$Res>
    implements $LayoutConfigCopyWith<$Res> {
  factory _$$LayoutConfigImplCopyWith(
          _$LayoutConfigImpl value, $Res Function(_$LayoutConfigImpl) then) =
      __$$LayoutConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? direction, String? alignment, double? spacing});
}

/// @nodoc
class __$$LayoutConfigImplCopyWithImpl<$Res>
    extends _$LayoutConfigCopyWithImpl<$Res, _$LayoutConfigImpl>
    implements _$$LayoutConfigImplCopyWith<$Res> {
  __$$LayoutConfigImplCopyWithImpl(
      _$LayoutConfigImpl _value, $Res Function(_$LayoutConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? direction = freezed,
    Object? alignment = freezed,
    Object? spacing = freezed,
  }) {
    return _then(_$LayoutConfigImpl(
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
      alignment: freezed == alignment
          ? _value.alignment
          : alignment // ignore: cast_nullable_to_non_nullable
              as String?,
      spacing: freezed == spacing
          ? _value.spacing
          : spacing // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LayoutConfigImpl implements _LayoutConfig {
  const _$LayoutConfigImpl({this.direction, this.alignment, this.spacing});

  factory _$LayoutConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$LayoutConfigImplFromJson(json);

  @override
  final String? direction;
  @override
  final String? alignment;
  @override
  final double? spacing;

  @override
  String toString() {
    return 'LayoutConfig(direction: $direction, alignment: $alignment, spacing: $spacing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LayoutConfigImpl &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.alignment, alignment) ||
                other.alignment == alignment) &&
            (identical(other.spacing, spacing) || other.spacing == spacing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, direction, alignment, spacing);

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LayoutConfigImplCopyWith<_$LayoutConfigImpl> get copyWith =>
      __$$LayoutConfigImplCopyWithImpl<_$LayoutConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LayoutConfigImplToJson(
      this,
    );
  }
}

abstract class _LayoutConfig implements LayoutConfig {
  const factory _LayoutConfig(
      {final String? direction,
      final String? alignment,
      final double? spacing}) = _$LayoutConfigImpl;

  factory _LayoutConfig.fromJson(Map<String, dynamic> json) =
      _$LayoutConfigImpl.fromJson;

  @override
  String? get direction;
  @override
  String? get alignment;
  @override
  double? get spacing;

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LayoutConfigImplCopyWith<_$LayoutConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
