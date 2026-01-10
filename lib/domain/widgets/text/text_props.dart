import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_props.freezed.dart';
part 'text_props.g.dart';

/// Properties for the TextWidget
///
/// Represents a text block with formatting options.
@freezed
class TextProps with _$TextProps {
  const factory TextProps({
    /// The text content to display
    required String text,

    /// Text alignment: 'left', 'center', 'right'
    @Default('left') String align,

    /// Whether the text should be bold
    @Default(false) bool bold,

    /// Whether the text should be italic
    @Default(false) bool italic,
  }) = _TextProps;

  factory TextProps.fromJson(Map<String, dynamic> json) =>
      _$TextPropsFromJson(json);
}
