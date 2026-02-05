import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';

part 'dish_props.freezed.dart';
part 'dish_props.g.dart';

/// Properties for the DishWidget
///
/// Represents a menu dish with name, price, description, dietary information,
/// and display preferences.
@freezed
abstract class DishProps with _$DishProps {
  const DishProps._();

  @JsonSerializable(explicitToJson: true)
  const factory DishProps({
    /// The name of the dish
    required String name,

    /// The price of the dish
    required double price,

    /// Optional description of the dish
    String? description,

    /// Legacy allergens field (for backward compatibility)
    /// @deprecated Use allergenInfo instead
    @Default([]) List<String> allergens,

    /// Structured allergen information with UK allergen types
    @Default([]) List<AllergenInfo> allergenInfo,

    /// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
    @Default([]) List<String> dietary,

    /// Whether to display the price
    @Default(true) bool showPrice,

    /// Whether to display allergen information
    @Default(true) bool showAllergens,
  }) = _DishProps;

  factory DishProps.fromJson(Map<String, dynamic> json) =>
      _$DishPropsFromJson(json);

  /// Get effective allergen info, migrating from legacy format if needed
  ///
  /// Returns [allergenInfo] if present, otherwise attempts to migrate
  /// from the legacy [allergens] list.
  List<AllergenInfo> get effectiveAllergenInfo {
    if (allergenInfo.isNotEmpty) {
      return allergenInfo;
    }
    // Migrate from legacy format
    return allergens
        .map((s) => AllergenInfo.fromLegacyString(s))
        .whereType<AllergenInfo>()
        .toList();
  }
}
