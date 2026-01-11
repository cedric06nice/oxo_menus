// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'widget_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateWidgetInput {
  String get columnId;
  String get type;
  String get version;
  int get index;
  Map<String, dynamic> get props;
  WidgetStyle? get style;

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreateWidgetInputCopyWith<CreateWidgetInput> get copyWith =>
      _$CreateWidgetInputCopyWithImpl<CreateWidgetInput>(
          this as CreateWidgetInput, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateWidgetInput &&
            (identical(other.columnId, columnId) ||
                other.columnId == columnId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality().equals(other.props, props) &&
            (identical(other.style, style) || other.style == style));
  }

  @override
  int get hashCode => Object.hash(runtimeType, columnId, type, version, index,
      const DeepCollectionEquality().hash(props), style);

  @override
  String toString() {
    return 'CreateWidgetInput(columnId: $columnId, type: $type, version: $version, index: $index, props: $props, style: $style)';
  }
}

/// @nodoc
abstract mixin class $CreateWidgetInputCopyWith<$Res> {
  factory $CreateWidgetInputCopyWith(
          CreateWidgetInput value, $Res Function(CreateWidgetInput) _then) =
      _$CreateWidgetInputCopyWithImpl;
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
class _$CreateWidgetInputCopyWithImpl<$Res>
    implements $CreateWidgetInputCopyWith<$Res> {
  _$CreateWidgetInputCopyWithImpl(this._self, this._then);

  final CreateWidgetInput _self;
  final $Res Function(CreateWidgetInput) _then;

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
    return _then(_self.copyWith(
      columnId: null == columnId
          ? _self.columnId
          : columnId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      props: null == props
          ? _self.props
          : props // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      style: freezed == style
          ? _self.style
          : style // ignore: cast_nullable_to_non_nullable
              as WidgetStyle?,
    ));
  }

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WidgetStyleCopyWith<$Res>? get style {
    if (_self.style == null) {
      return null;
    }

    return $WidgetStyleCopyWith<$Res>(_self.style!, (value) {
      return _then(_self.copyWith(style: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CreateWidgetInput].
extension CreateWidgetInputPatterns on CreateWidgetInput {
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
    TResult Function(_CreateWidgetInput value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreateWidgetInput() when $default != null:
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
    TResult Function(_CreateWidgetInput value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateWidgetInput():
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
    TResult? Function(_CreateWidgetInput value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateWidgetInput() when $default != null:
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
    TResult Function(String columnId, String type, String version, int index,
            Map<String, dynamic> props, WidgetStyle? style)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreateWidgetInput() when $default != null:
        return $default(_that.columnId, _that.type, _that.version, _that.index,
            _that.props, _that.style);
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
    TResult Function(String columnId, String type, String version, int index,
            Map<String, dynamic> props, WidgetStyle? style)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateWidgetInput():
        return $default(_that.columnId, _that.type, _that.version, _that.index,
            _that.props, _that.style);
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
    TResult? Function(String columnId, String type, String version, int index,
            Map<String, dynamic> props, WidgetStyle? style)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateWidgetInput() when $default != null:
        return $default(_that.columnId, _that.type, _that.version, _that.index,
            _that.props, _that.style);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CreateWidgetInput implements CreateWidgetInput {
  const _CreateWidgetInput(
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

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CreateWidgetInputCopyWith<_CreateWidgetInput> get copyWith =>
      __$CreateWidgetInputCopyWithImpl<_CreateWidgetInput>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CreateWidgetInput &&
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

  @override
  String toString() {
    return 'CreateWidgetInput(columnId: $columnId, type: $type, version: $version, index: $index, props: $props, style: $style)';
  }
}

/// @nodoc
abstract mixin class _$CreateWidgetInputCopyWith<$Res>
    implements $CreateWidgetInputCopyWith<$Res> {
  factory _$CreateWidgetInputCopyWith(
          _CreateWidgetInput value, $Res Function(_CreateWidgetInput) _then) =
      __$CreateWidgetInputCopyWithImpl;
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
class __$CreateWidgetInputCopyWithImpl<$Res>
    implements _$CreateWidgetInputCopyWith<$Res> {
  __$CreateWidgetInputCopyWithImpl(this._self, this._then);

  final _CreateWidgetInput _self;
  final $Res Function(_CreateWidgetInput) _then;

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? columnId = null,
    Object? type = null,
    Object? version = null,
    Object? index = null,
    Object? props = null,
    Object? style = freezed,
  }) {
    return _then(_CreateWidgetInput(
      columnId: null == columnId
          ? _self.columnId
          : columnId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      index: null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      props: null == props
          ? _self._props
          : props // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      style: freezed == style
          ? _self.style
          : style // ignore: cast_nullable_to_non_nullable
              as WidgetStyle?,
    ));
  }

  /// Create a copy of CreateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WidgetStyleCopyWith<$Res>? get style {
    if (_self.style == null) {
      return null;
    }

    return $WidgetStyleCopyWith<$Res>(_self.style!, (value) {
      return _then(_self.copyWith(style: value));
    });
  }
}

/// @nodoc
mixin _$UpdateWidgetInput {
  String get id;
  String? get type;
  String? get version;
  int? get index;
  Map<String, dynamic>? get props;
  WidgetStyle? get style;

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UpdateWidgetInputCopyWith<UpdateWidgetInput> get copyWith =>
      _$UpdateWidgetInputCopyWithImpl<UpdateWidgetInput>(
          this as UpdateWidgetInput, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UpdateWidgetInput &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality().equals(other.props, props) &&
            (identical(other.style, style) || other.style == style));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, type, version, index,
      const DeepCollectionEquality().hash(props), style);

  @override
  String toString() {
    return 'UpdateWidgetInput(id: $id, type: $type, version: $version, index: $index, props: $props, style: $style)';
  }
}

/// @nodoc
abstract mixin class $UpdateWidgetInputCopyWith<$Res> {
  factory $UpdateWidgetInputCopyWith(
          UpdateWidgetInput value, $Res Function(UpdateWidgetInput) _then) =
      _$UpdateWidgetInputCopyWithImpl;
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
class _$UpdateWidgetInputCopyWithImpl<$Res>
    implements $UpdateWidgetInputCopyWith<$Res> {
  _$UpdateWidgetInputCopyWithImpl(this._self, this._then);

  final UpdateWidgetInput _self;
  final $Res Function(UpdateWidgetInput) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      index: freezed == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
      props: freezed == props
          ? _self.props
          : props // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      style: freezed == style
          ? _self.style
          : style // ignore: cast_nullable_to_non_nullable
              as WidgetStyle?,
    ));
  }

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WidgetStyleCopyWith<$Res>? get style {
    if (_self.style == null) {
      return null;
    }

    return $WidgetStyleCopyWith<$Res>(_self.style!, (value) {
      return _then(_self.copyWith(style: value));
    });
  }
}

/// Adds pattern-matching-related methods to [UpdateWidgetInput].
extension UpdateWidgetInputPatterns on UpdateWidgetInput {
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
    TResult Function(_UpdateWidgetInput value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UpdateWidgetInput() when $default != null:
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
    TResult Function(_UpdateWidgetInput value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpdateWidgetInput():
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
    TResult? Function(_UpdateWidgetInput value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpdateWidgetInput() when $default != null:
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
    TResult Function(String id, String? type, String? version, int? index,
            Map<String, dynamic>? props, WidgetStyle? style)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UpdateWidgetInput() when $default != null:
        return $default(_that.id, _that.type, _that.version, _that.index,
            _that.props, _that.style);
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
    TResult Function(String id, String? type, String? version, int? index,
            Map<String, dynamic>? props, WidgetStyle? style)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpdateWidgetInput():
        return $default(_that.id, _that.type, _that.version, _that.index,
            _that.props, _that.style);
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
    TResult? Function(String id, String? type, String? version, int? index,
            Map<String, dynamic>? props, WidgetStyle? style)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpdateWidgetInput() when $default != null:
        return $default(_that.id, _that.type, _that.version, _that.index,
            _that.props, _that.style);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _UpdateWidgetInput implements UpdateWidgetInput {
  const _UpdateWidgetInput(
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

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateWidgetInputCopyWith<_UpdateWidgetInput> get copyWith =>
      __$UpdateWidgetInputCopyWithImpl<_UpdateWidgetInput>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateWidgetInput &&
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

  @override
  String toString() {
    return 'UpdateWidgetInput(id: $id, type: $type, version: $version, index: $index, props: $props, style: $style)';
  }
}

/// @nodoc
abstract mixin class _$UpdateWidgetInputCopyWith<$Res>
    implements $UpdateWidgetInputCopyWith<$Res> {
  factory _$UpdateWidgetInputCopyWith(
          _UpdateWidgetInput value, $Res Function(_UpdateWidgetInput) _then) =
      __$UpdateWidgetInputCopyWithImpl;
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
class __$UpdateWidgetInputCopyWithImpl<$Res>
    implements _$UpdateWidgetInputCopyWith<$Res> {
  __$UpdateWidgetInputCopyWithImpl(this._self, this._then);

  final _UpdateWidgetInput _self;
  final $Res Function(_UpdateWidgetInput) _then;

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = freezed,
    Object? version = freezed,
    Object? index = freezed,
    Object? props = freezed,
    Object? style = freezed,
  }) {
    return _then(_UpdateWidgetInput(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      index: freezed == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int?,
      props: freezed == props
          ? _self._props
          : props // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      style: freezed == style
          ? _self.style
          : style // ignore: cast_nullable_to_non_nullable
              as WidgetStyle?,
    ));
  }

  /// Create a copy of UpdateWidgetInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WidgetStyleCopyWith<$Res>? get style {
    if (_self.style == null) {
      return null;
    }

    return $WidgetStyleCopyWith<$Res>(_self.style!, (value) {
      return _then(_self.copyWith(style: value));
    });
  }
}

// dart format on
