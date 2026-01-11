// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PageDto {
  String get id;
  @JsonKey(name: 'date_created')
  DateTime? get dateCreated;
  @JsonKey(name: 'date_updated')
  DateTime? get dateUpdated;
  @JsonKey(name: 'menu_id')
  String get menuId;
  String get name;
  int get index;

  /// Create a copy of PageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PageDtoCopyWith<PageDto> get copyWith =>
      _$PageDtoCopyWithImpl<PageDto>(this as PageDto, _$identity);

  /// Serializes this PageDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PageDto &&
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

  @override
  String toString() {
    return 'PageDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, menuId: $menuId, name: $name, index: $index)';
  }
}

/// @nodoc
abstract mixin class $PageDtoCopyWith<$Res> {
  factory $PageDtoCopyWith(PageDto value, $Res Function(PageDto) _then) =
      _$PageDtoCopyWithImpl;
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
class _$PageDtoCopyWithImpl<$Res> implements $PageDtoCopyWith<$Res> {
  _$PageDtoCopyWithImpl(this._self, this._then);

  final PageDto _self;
  final $Res Function(PageDto) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dateCreated: freezed == dateCreated
          ? _self.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _self.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      menuId: null == menuId
          ? _self.menuId
          : menuId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PageDto].
extension PageDtoPatterns on PageDto {
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
    TResult Function(_PageDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PageDto() when $default != null:
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
    TResult Function(_PageDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PageDto():
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
    TResult? Function(_PageDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PageDto() when $default != null:
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
            @JsonKey(name: 'date_created') DateTime? dateCreated,
            @JsonKey(name: 'date_updated') DateTime? dateUpdated,
            @JsonKey(name: 'menu_id') String menuId,
            String name,
            int index)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PageDto() when $default != null:
        return $default(_that.id, _that.dateCreated, _that.dateUpdated,
            _that.menuId, _that.name, _that.index);
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
            @JsonKey(name: 'date_created') DateTime? dateCreated,
            @JsonKey(name: 'date_updated') DateTime? dateUpdated,
            @JsonKey(name: 'menu_id') String menuId,
            String name,
            int index)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PageDto():
        return $default(_that.id, _that.dateCreated, _that.dateUpdated,
            _that.menuId, _that.name, _that.index);
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
            @JsonKey(name: 'date_created') DateTime? dateCreated,
            @JsonKey(name: 'date_updated') DateTime? dateUpdated,
            @JsonKey(name: 'menu_id') String menuId,
            String name,
            int index)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PageDto() when $default != null:
        return $default(_that.id, _that.dateCreated, _that.dateUpdated,
            _that.menuId, _that.name, _that.index);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PageDto extends PageDto {
  const _PageDto(
      {required this.id,
      @JsonKey(name: 'date_created') this.dateCreated,
      @JsonKey(name: 'date_updated') this.dateUpdated,
      @JsonKey(name: 'menu_id') required this.menuId,
      required this.name,
      required this.index})
      : super._();
  factory _PageDto.fromJson(Map<String, dynamic> json) =>
      _$PageDtoFromJson(json);

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

  /// Create a copy of PageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PageDtoCopyWith<_PageDto> get copyWith =>
      __$PageDtoCopyWithImpl<_PageDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PageDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PageDto &&
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

  @override
  String toString() {
    return 'PageDto(id: $id, dateCreated: $dateCreated, dateUpdated: $dateUpdated, menuId: $menuId, name: $name, index: $index)';
  }
}

/// @nodoc
abstract mixin class _$PageDtoCopyWith<$Res> implements $PageDtoCopyWith<$Res> {
  factory _$PageDtoCopyWith(_PageDto value, $Res Function(_PageDto) _then) =
      __$PageDtoCopyWithImpl;
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
class __$PageDtoCopyWithImpl<$Res> implements _$PageDtoCopyWith<$Res> {
  __$PageDtoCopyWithImpl(this._self, this._then);

  final _PageDto _self;
  final $Res Function(_PageDto) _then;

  /// Create a copy of PageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? dateCreated = freezed,
    Object? dateUpdated = freezed,
    Object? menuId = null,
    Object? name = null,
    Object? index = null,
  }) {
    return _then(_PageDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dateCreated: freezed == dateCreated
          ? _self.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateUpdated: freezed == dateUpdated
          ? _self.dateUpdated
          : dateUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      menuId: null == menuId
          ? _self.menuId
          : menuId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
