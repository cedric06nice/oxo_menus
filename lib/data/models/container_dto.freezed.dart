// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ContainerDto _$ContainerDtoFromJson(Map<String, dynamic> json) {
  return _ContainerDto.fromJson(json);
}

/// @nodoc
mixin _$ContainerDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'page_id')
  String get pageId => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'layout_json')
  Map<String, dynamic>? get layoutJson => throw _privateConstructorUsedError;

  /// Serializes this ContainerDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContainerDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContainerDtoCopyWith<ContainerDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContainerDtoCopyWith<$Res> {
  factory $ContainerDtoCopyWith(
          ContainerDto value, $Res Function(ContainerDto) then) =
      _$ContainerDtoCopyWithImpl<$Res, ContainerDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'date_created') DateTime? dateCreated,
      @JsonKey(name: 'date_updated') DateTime? dateUpdated,
      @JsonKey(name: 'page_id') String pageId,
      int index,
      String? name,
      @JsonKey(name: 'layout_json') Map<String, dynamic>? layoutJson});
}

/// @nodoc
class _$ContainerDtoCopyWithImpl<$Res, $Val extends ContainerDto>
    implements $ContainerDtoCopyWith<$Res> {
  _$ContainerDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContainerDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? pageId = null,
    Object? index = null,
    Object? name = freezed,
    Object? layoutJson = freezed,
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
      layoutJson: freezed == layoutJson
          ? _value.layoutJson
          : layoutJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContainerDtoImplCopyWith<$Res>
    implements $ContainerDtoCopyWith<$Res> {
  factory _$$ContainerDtoImplCopyWith(
          _$ContainerDtoImpl value, $Res Function(_$ContainerDtoImpl) then) =
      __$$ContainerDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'date_created') DateTime? dateCreated,
      @JsonKey(name: 'date_updated') DateTime? dateUpdated,
      @JsonKey(name: 'page_id') String pageId,
      int index,
      String? name,
      @JsonKey(name: 'layout_json') Map<String, dynamic>? layoutJson});
}

/// @nodoc
class __$$ContainerDtoImplCopyWithImpl<$Res>
    extends _$ContainerDtoCopyWithImpl<$Res, _$ContainerDtoImpl>
    implements _$$ContainerDtoImplCopyWith<$Res> {
  __$$ContainerDtoImplCopyWithImpl(
      _$ContainerDtoImpl _value, $Res Function(_$ContainerDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContainerDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? pageId = null,
    Object? index = null,
    Object? name = freezed,
    Object? layoutJson = freezed,
  }) {
    return _then(_$ContainerDtoImpl(
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
      layoutJson: freezed == layoutJson
          ? _value._layoutJson
          : layoutJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContainerDtoImpl implements _ContainerDto {
  const _$ContainerDtoImpl(
      {required this.id,
      @JsonKey(name: 'date_created') this.dateCreated,
      @JsonKey(name: 'date_updated') this.dateUpdated,
      @JsonKey(name: 'page_id') required this.pageId,
      required this.index,
      this.name,
      @JsonKey(name: 'layout_json') final Map<String, dynamic>? layoutJson})
      : _layoutJson = layoutJson;

  factory _$ContainerDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContainerDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @override
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;
  @override
  @JsonKey(name: 'page_id')
  final String pageId;
  @override
  final int index;
  @override
  final String? name;
  final Map<String, dynamic>? _layoutJson;
  @override
  @JsonKey(name: 'layout_json')
  Map<String, dynamic>? get layoutJson {
    final value = _layoutJson;
    if (value == null) return null;
    if (_layoutJson is EqualUnmodifiableMapView) return _layoutJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ContainerDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, pageId: $pageId, index: $index, name: $name, layoutJson: $layoutJson)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContainerDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.dateUpdated, dateUpdated) ||
                other.dateUpdated == dateUpdated) &&
            (identical(other.pageId, pageId) || other.pageId == pageId) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._layoutJson, _layoutJson));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, dateCreated, dateUpdated,
      pageId, index, name, const DeepCollectionEquality().hash(_layoutJson));

  /// Create a copy of ContainerDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerDtoImplCopyWith<_$ContainerDtoImpl> get copyWith =>
      __$$ContainerDtoImplCopyWithImpl<_$ContainerDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContainerDtoImplToJson(
      this,
    );
  }
}

abstract class _ContainerDto implements ContainerDto {
  const factory _ContainerDto(
      {required final String id,
      @JsonKey(name: 'date_created') final DateTime? dateCreated,
      @JsonKey(name: 'date_updated') final DateTime? dateUpdated,
      @JsonKey(name: 'page_id') required final String pageId,
      required final int index,
      final String? name,
      @JsonKey(name: 'layout_json')
      final Map<String, dynamic>? layoutJson}) = _$ContainerDtoImpl;

  factory _ContainerDto.fromJson(Map<String, dynamic> json) =
      _$ContainerDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated;
  @override
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated;
  @override
  @JsonKey(name: 'page_id')
  String get pageId;
  @override
  int get index;
  @override
  String? get name;
  @override
  @JsonKey(name: 'layout_json')
  Map<String, dynamic>? get layoutJson;

  /// Create a copy of ContainerDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContainerDtoImplCopyWith<_$ContainerDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
