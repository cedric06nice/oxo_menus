// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_props.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TextProps _$TextPropsFromJson(Map<String, dynamic> json) {
  return _TextProps.fromJson(json);
}

/// @nodoc
mixin _$TextProps {
  /// The text content to display
  String get text => throw _privateConstructorUsedError;

  /// Text alignment: 'left', 'center', 'right'
  String get align => throw _privateConstructorUsedError;

  /// Whether the text should be bold
  bool get bold => throw _privateConstructorUsedError;

  /// Whether the text should be italic
  bool get italic => throw _privateConstructorUsedError;

  /// Serializes this TextProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TextProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TextPropsCopyWith<TextProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextPropsCopyWith<$Res> {
  factory $TextPropsCopyWith(TextProps value, $Res Function(TextProps) then) =
      _$TextPropsCopyWithImpl<$Res, TextProps>;
  @useResult
  $Res call({String text, String align, bool bold, bool italic});
}

/// @nodoc
class _$TextPropsCopyWithImpl<$Res, $Val extends TextProps>
    implements $TextPropsCopyWith<$Res> {
  _$TextPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      align: null == align
          ? _value.align
          : align // ignore: cast_nullable_to_non_nullable
              as String,
      bold: null == bold
          ? _value.bold
          : bold // ignore: cast_nullable_to_non_nullable
              as bool,
      italic: null == italic
          ? _value.italic
          : italic // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TextPropsImplCopyWith<$Res>
    implements $TextPropsCopyWith<$Res> {
  factory _$$TextPropsImplCopyWith(
          _$TextPropsImpl value, $Res Function(_$TextPropsImpl) then) =
      __$$TextPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, String align, bool bold, bool italic});
}

/// @nodoc
class __$$TextPropsImplCopyWithImpl<$Res>
    extends _$TextPropsCopyWithImpl<$Res, _$TextPropsImpl>
    implements _$$TextPropsImplCopyWith<$Res> {
  __$$TextPropsImplCopyWithImpl(
      _$TextPropsImpl _value, $Res Function(_$TextPropsImpl) _then)
      : super(_value, _then);

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
    return _then(_$TextPropsImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      align: null == align
          ? _value.align
          : align // ignore: cast_nullable_to_non_nullable
              as String,
      bold: null == bold
          ? _value.bold
          : bold // ignore: cast_nullable_to_non_nullable
              as bool,
      italic: null == italic
          ? _value.italic
          : italic // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TextPropsImpl implements _TextProps {
  const _$TextPropsImpl(
      {required this.text,
      this.align = 'left',
      this.bold = false,
      this.italic = false});

  factory _$TextPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TextPropsImplFromJson(json);

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

  @override
  String toString() {
    return 'TextProps(text: $text, align: $align, bold: $bold, italic: $italic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextPropsImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.align, align) || other.align == align) &&
            (identical(other.bold, bold) || other.bold == bold) &&
            (identical(other.italic, italic) || other.italic == italic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, align, bold, italic);

  /// Create a copy of TextProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextPropsImplCopyWith<_$TextPropsImpl> get copyWith =>
      __$$TextPropsImplCopyWithImpl<_$TextPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TextPropsImplToJson(
      this,
    );
  }
}

abstract class _TextProps implements TextProps {
  const factory _TextProps(
      {required final String text,
      final String align,
      final bool bold,
      final bool italic}) = _$TextPropsImpl;

  factory _TextProps.fromJson(Map<String, dynamic> json) =
      _$TextPropsImpl.fromJson;

  /// The text content to display
  @override
  String get text;

  /// Text alignment: 'left', 'center', 'right'
  @override
  String get align;

  /// Whether the text should be bold
  @override
  bool get bold;

  /// Whether the text should be italic
  @override
  bool get italic;

  /// Create a copy of TextProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextPropsImplCopyWith<_$TextPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
