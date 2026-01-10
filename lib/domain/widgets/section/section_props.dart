import 'package:freezed_annotation/freezed_annotation.dart';

part 'section_props.freezed.dart';
part 'section_props.g.dart';

/// Properties for the SectionWidget
///
/// Represents a section header or divider in a menu.
@freezed
class SectionProps with _$SectionProps {
  const factory SectionProps({
    /// The title of the section
    required String title,

    /// Whether to display the title in uppercase
    @Default(false) bool uppercase,

    /// Whether to show a divider line below the title
    @Default(true) bool showDivider,
  }) = _SectionProps;

  factory SectionProps.fromJson(Map<String, dynamic> json) =>
      _$SectionPropsFromJson(json);
}
