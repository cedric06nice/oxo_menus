// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'section_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SectionProps {
  /// The title of the section
  String get title;

  /// Whether to display the title in uppercase
  bool get uppercase;

  /// Whether to show a divider line below the title
  bool get showDivider;

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SectionPropsCopyWith<SectionProps> get copyWith =>
      _$SectionPropsCopyWithImpl<SectionProps>(
          this as SectionProps, _$identity);

  /// Serializes this SectionProps to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SectionProps &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.uppercase, uppercase) ||
                other.uppercase == uppercase) &&
            (identical(other.showDivider, showDivider) ||
                other.showDivider == showDivider));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, uppercase, showDivider);

  @override
  String toString() {
    return 'SectionProps(title: $title, uppercase: $uppercase, showDivider: $showDivider)';
  }
}

/// @nodoc
abstract mixin class $SectionPropsCopyWith<$Res> {
  factory $SectionPropsCopyWith(
          SectionProps value, $Res Function(SectionProps) _then) =
      _$SectionPropsCopyWithImpl;
  @useResult
  $Res call({String title, bool uppercase, bool showDivider});
}

/// @nodoc
class _$SectionPropsCopyWithImpl<$Res> implements $SectionPropsCopyWith<$Res> {
  _$SectionPropsCopyWithImpl(this._self, this._then);

  final SectionProps _self;
  final $Res Function(SectionProps) _then;

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? uppercase = null,
    Object? showDivider = null,
  }) {
    return _then(_self.copyWith(
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      uppercase: null == uppercase
          ? _self.uppercase
          : uppercase // ignore: cast_nullable_to_non_nullable
              as bool,
      showDivider: null == showDivider
          ? _self.showDivider
          : showDivider // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [SectionProps].
extension SectionPropsPatterns on SectionProps {
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
    TResult Function(_SectionProps value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SectionProps() when $default != null:
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
    TResult Function(_SectionProps value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SectionProps():
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
    TResult? Function(_SectionProps value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SectionProps() when $default != null:
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
    TResult Function(String title, bool uppercase, bool showDivider)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SectionProps() when $default != null:
        return $default(_that.title, _that.uppercase, _that.showDivider);
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
    TResult Function(String title, bool uppercase, bool showDivider) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SectionProps():
        return $default(_that.title, _that.uppercase, _that.showDivider);
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
    TResult? Function(String title, bool uppercase, bool showDivider)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SectionProps() when $default != null:
        return $default(_that.title, _that.uppercase, _that.showDivider);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SectionProps extends SectionProps {
  const _SectionProps(
      {required this.title, this.uppercase = false, this.showDivider = true})
      : super._();
  factory _SectionProps.fromJson(Map<String, dynamic> json) =>
      _$SectionPropsFromJson(json);

  /// The title of the section
  @override
  final String title;

  /// Whether to display the title in uppercase
  @override
  @JsonKey()
  final bool uppercase;

  /// Whether to show a divider line below the title
  @override
  @JsonKey()
  final bool showDivider;

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SectionPropsCopyWith<_SectionProps> get copyWith =>
      __$SectionPropsCopyWithImpl<_SectionProps>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SectionPropsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SectionProps &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.uppercase, uppercase) ||
                other.uppercase == uppercase) &&
            (identical(other.showDivider, showDivider) ||
                other.showDivider == showDivider));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, uppercase, showDivider);

  @override
  String toString() {
    return 'SectionProps(title: $title, uppercase: $uppercase, showDivider: $showDivider)';
  }
}

/// @nodoc
abstract mixin class _$SectionPropsCopyWith<$Res>
    implements $SectionPropsCopyWith<$Res> {
  factory _$SectionPropsCopyWith(
          _SectionProps value, $Res Function(_SectionProps) _then) =
      __$SectionPropsCopyWithImpl;
  @override
  @useResult
  $Res call({String title, bool uppercase, bool showDivider});
}

/// @nodoc
class __$SectionPropsCopyWithImpl<$Res>
    implements _$SectionPropsCopyWith<$Res> {
  __$SectionPropsCopyWithImpl(this._self, this._then);

  final _SectionProps _self;
  final $Res Function(_SectionProps) _then;

  /// Create a copy of SectionProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? title = null,
    Object? uppercase = null,
    Object? showDivider = null,
  }) {
    return _then(_SectionProps(
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      uppercase: null == uppercase
          ? _self.uppercase
          : uppercase // ignore: cast_nullable_to_non_nullable
              as bool,
      showDivider: null == showDivider
          ? _self.showDivider
          : showDivider // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
