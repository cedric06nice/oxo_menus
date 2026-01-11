// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TextProps {
  /// The text content to display
  String get text;

  /// Text alignment: 'left', 'center', 'right'
  String get align;

  /// Whether the text should be bold
  bool get bold;

  /// Whether the text should be italic
  bool get italic;

  /// Create a copy of TextProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TextPropsCopyWith<TextProps> get copyWith =>
      _$TextPropsCopyWithImpl<TextProps>(this as TextProps, _$identity);

  /// Serializes this TextProps to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TextProps &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.align, align) || other.align == align) &&
            (identical(other.bold, bold) || other.bold == bold) &&
            (identical(other.italic, italic) || other.italic == italic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, align, bold, italic);

  @override
  String toString() {
    return 'TextProps(text: $text, align: $align, bold: $bold, italic: $italic)';
  }
}

/// @nodoc
abstract mixin class $TextPropsCopyWith<$Res> {
  factory $TextPropsCopyWith(TextProps value, $Res Function(TextProps) _then) =
      _$TextPropsCopyWithImpl;
  @useResult
  $Res call({String text, String align, bool bold, bool italic});
}

/// @nodoc
class _$TextPropsCopyWithImpl<$Res> implements $TextPropsCopyWith<$Res> {
  _$TextPropsCopyWithImpl(this._self, this._then);

  final TextProps _self;
  final $Res Function(TextProps) _then;

  /// Create a copy of TextProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? align = null,
    Object? bold = null,
    Object? italic = null,
  }) {
    return _then(_self.copyWith(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      align: null == align
          ? _self.align
          : align // ignore: cast_nullable_to_non_nullable
              as String,
      bold: null == bold
          ? _self.bold
          : bold // ignore: cast_nullable_to_non_nullable
              as bool,
      italic: null == italic
          ? _self.italic
          : italic // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [TextProps].
extension TextPropsPatterns on TextProps {
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
    TResult Function(_TextProps value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TextProps() when $default != null:
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
    TResult Function(_TextProps value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextProps():
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
    TResult? Function(_TextProps value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextProps() when $default != null:
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
    TResult Function(String text, String align, bool bold, bool italic)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TextProps() when $default != null:
        return $default(_that.text, _that.align, _that.bold, _that.italic);
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
    TResult Function(String text, String align, bool bold, bool italic)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextProps():
        return $default(_that.text, _that.align, _that.bold, _that.italic);
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
    TResult? Function(String text, String align, bool bold, bool italic)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextProps() when $default != null:
        return $default(_that.text, _that.align, _that.bold, _that.italic);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TextProps extends TextProps {
  const _TextProps(
      {required this.text,
      this.align = 'left',
      this.bold = false,
      this.italic = false})
      : super._();
  factory _TextProps.fromJson(Map<String, dynamic> json) =>
      _$TextPropsFromJson(json);

  /// The text content to display
  @override
  final String text;

  /// Text alignment: 'left', 'center', 'right'
  @override
  @JsonKey()
  final String align;

  /// Whether the text should be bold
  @override
  @JsonKey()
  final bool bold;

  /// Whether the text should be italic
  @override
  @JsonKey()
  final bool italic;

  /// Create a copy of TextProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TextPropsCopyWith<_TextProps> get copyWith =>
      __$TextPropsCopyWithImpl<_TextProps>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TextPropsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TextProps &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.align, align) || other.align == align) &&
            (identical(other.bold, bold) || other.bold == bold) &&
            (identical(other.italic, italic) || other.italic == italic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, align, bold, italic);

  @override
  String toString() {
    return 'TextProps(text: $text, align: $align, bold: $bold, italic: $italic)';
  }
}

/// @nodoc
abstract mixin class _$TextPropsCopyWith<$Res>
    implements $TextPropsCopyWith<$Res> {
  factory _$TextPropsCopyWith(
          _TextProps value, $Res Function(_TextProps) _then) =
      __$TextPropsCopyWithImpl;
  @override
  @useResult
  $Res call({String text, String align, bool bold, bool italic});
}

/// @nodoc
class __$TextPropsCopyWithImpl<$Res> implements _$TextPropsCopyWith<$Res> {
  __$TextPropsCopyWithImpl(this._self, this._then);

  final _TextProps _self;
  final $Res Function(_TextProps) _then;

  /// Create a copy of TextProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? align = null,
    Object? bold = null,
    Object? italic = null,
  }) {
    return _then(_TextProps(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      align: null == align
          ? _self.align
          : align // ignore: cast_nullable_to_non_nullable
              as String,
      bold: null == bold
          ? _self.bold
          : bold // ignore: cast_nullable_to_non_nullable
              as bool,
      italic: null == italic
          ? _self.italic
          : italic // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
