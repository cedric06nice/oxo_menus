import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_display_options.freezed.dart';
part 'menu_display_options.g.dart';

/// Display options for menu-level settings
///
/// Controls what information is displayed across all widgets in a menu.
/// This is widget-agnostic and reusable by any widget type.
@freezed
abstract class MenuDisplayOptions with _$MenuDisplayOptions {
  const MenuDisplayOptions._();

  const factory MenuDisplayOptions({
    /// Whether to display prices across all widgets
    @Default(true) bool showPrices,

    /// Whether to display allergen information across all widgets
    @Default(true) bool showAllergens,
  }) = _MenuDisplayOptions;

  factory MenuDisplayOptions.fromJson(Map<String, dynamic> json) =>
      _$MenuDisplayOptionsFromJson(json);
}
