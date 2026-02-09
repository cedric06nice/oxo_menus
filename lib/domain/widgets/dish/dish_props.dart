import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';

part 'dish_props.freezed.dart';
part 'dish_props.g.dart';

/// Properties for the DishWidget
///
/// Represents a menu dish with name, price, description, and dietary information.
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

    /// Dietary type (Vegetarian or Vegan)
    DietaryType? dietary,
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

  /// Display name: uppercased dish name with optional dietary abbreviation
  String get displayName {
    final upper = name.toUpperCase();
    if (dietary == null) return upper;
    return '$upper ${dietary!.abbreviation}';
  }
}
