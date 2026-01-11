// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuDto {
  String get id;
  String get status;
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated;
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated;
  @JsonKey(name: 'user_created')
  String? get userCreated;
  @JsonKey(name: 'user_updated')
  String? get userUpdated;
  String get name;
  String get version;
  @JsonKey(name: 'style_json')
  Map<String, dynamic>? get styleJson;
  String? get area;
  Map<String, dynamic>? get size;

  /// Create a copy of MenuDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MenuDtoCopyWith<MenuDto> get copyWith =>
      _$MenuDtoCopyWithImpl<MenuDto>(this as MenuDto, _$identity);

  /// Serializes this MenuDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MenuDto &&
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
            const DeepCollectionEquality().equals(other.styleJson, styleJson) &&
            (identical(other.area, area) || other.area == area) &&
            const DeepCollectionEquality().equals(other.size, size));
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
      const DeepCollectionEquality().hash(styleJson),
      area,
      const DeepCollectionEquality().hash(size));

  @override
  String toString() {
    return 'MenuDto(id: $id, status: $status, dateCreated: $dateCreated, dateUpdated: $dateUpdated, userCreated: $userCreated, userUpdated: $userUpdated, name: $name, version: $version, styleJson: $styleJson, area: $area, size: $size)';
  }
}

/// @nodoc
abstract mixin class $MenuDtoCopyWith<$Res> {
  factory $MenuDtoCopyWith(MenuDto value, $Res Function(MenuDto) _then) =
      _$MenuDtoCopyWithImpl;
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
class _$MenuDtoCopyWithImpl<$Res> implements $MenuDtoCopyWith<$Res> {
  _$MenuDtoCopyWithImpl(this._self, this._then);

  final MenuDto _self;
  final $Res Function(MenuDto) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      dateCreated: freezed == dateCreated
          ? _self.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _self.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userCreated: freezed == userCreated
          ? _self.userCreated
          : userCreated // ignore: cast_nullable_to_non_nullable
              as String?,
      userUpdated: freezed == userUpdated
          ? _self.userUpdated
          : userUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      styleJson: freezed == styleJson
          ? _self.styleJson
          : styleJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      area: freezed == area
          ? _self.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MenuDto].
extension MenuDtoPatterns on MenuDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MenuDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MenuDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MenuDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MenuDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MenuDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MenuDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String status,
            @JsonKey(name: 'date_created') DateTime? dateCreated,
            @JsonKey(name: 'date_updated') DateTime? dateUpdated,
            @JsonKey(name: 'user_created') String? userCreated,
            @JsonKey(name: 'user_updated') String? userUpdated,
            String name,
            String version,
            @JsonKey(name: 'style_json') Map<String, dynamic>? styleJson,
            String? area,
            Map<String, dynamic>? size)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MenuDto() when $default != null:
        return $default(
            _that.id,
            _that.status,
            _that.dateCreated,
            _that.dateUpdated,
            _that.userCreated,
            _that.userUpdated,
            _that.name,
            _that.version,
            _that.styleJson,
            _that.area,
            _that.size);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String status,
            @JsonKey(name: 'date_created') DateTime? dateCreated,
            @JsonKey(name: 'date_updated') DateTime? dateUpdated,
            @JsonKey(name: 'user_created') String? userCreated,
            @JsonKey(name: 'user_updated') String? userUpdated,
            String name,
            String version,
            @JsonKey(name: 'style_json') Map<String, dynamic>? styleJson,
            String? area,
            Map<String, dynamic>? size)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MenuDto():
        return $default(
            _that.id,
            _that.status,
            _that.dateCreated,
            _that.dateUpdated,
            _that.userCreated,
            _that.userUpdated,
            _that.name,
            _that.version,
            _that.styleJson,
            _that.area,
            _that.size);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String status,
            @JsonKey(name: 'date_created') DateTime? dateCreated,
            @JsonKey(name: 'date_updated') DateTime? dateUpdated,
            @JsonKey(name: 'user_created') String? userCreated,
            @JsonKey(name: 'user_updated') String? userUpdated,
            String name,
            String version,
            @JsonKey(name: 'style_json') Map<String, dynamic>? styleJson,
            String? area,
            Map<String, dynamic>? size)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MenuDto() when $default != null:
        return $default(
            _that.id,
            _that.status,
            _that.dateCreated,
            _that.dateUpdated,
            _that.userCreated,
            _that.userUpdated,
            _that.name,
            _that.version,
            _that.styleJson,
            _that.area,
            _that.size);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MenuDto extends MenuDto {
  const _MenuDto(
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
        _size = size,
        super._();
  factory _MenuDto.fromJson(Map<String, dynamic> json) =>
      _$MenuDtoFromJson(json);

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

  /// Create a copy of MenuDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MenuDtoCopyWith<_MenuDto> get copyWith =>
      __$MenuDtoCopyWithImpl<_MenuDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MenuDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MenuDto &&
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

  @override
  String toString() {
    return 'MenuDto(id: $id, status: $status, dateCreated: $dateCreated, dateUpdated: $dateUpdated, userCreated: $userCreated, userUpdated: $userUpdated, name: $name, version: $version, styleJson: $styleJson, area: $area, size: $size)';
  }
}

/// @nodoc
abstract mixin class _$MenuDtoCopyWith<$Res> implements $MenuDtoCopyWith<$Res> {
  factory _$MenuDtoCopyWith(_MenuDto value, $Res Function(_MenuDto) _then) =
      __$MenuDtoCopyWithImpl;
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
class __$MenuDtoCopyWithImpl<$Res> implements _$MenuDtoCopyWith<$Res> {
  __$MenuDtoCopyWithImpl(this._self, this._then);

  final _MenuDto _self;
  final $Res Function(_MenuDto) _then;

  /// Create a copy of MenuDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_MenuDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      dateCreated: freezed == dateCreated
          ? _self.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _self.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userCreated: freezed == userCreated
          ? _self.userCreated
          : userCreated // ignore: cast_nullable_to_non_nullable
              as String?,
      userUpdated: freezed == userUpdated
          ? _self.userUpdated
          : userUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      styleJson: freezed == styleJson
          ? _self._styleJson
          : styleJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      area: freezed == area
          ? _self.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _self._size
          : size // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
