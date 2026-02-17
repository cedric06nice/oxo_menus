import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'dish_widget.dart';

/// Widget definition for DishWidget
///
/// Registers the dish widget type with the widget registry,
/// defining how to parse props, render the widget, and provide defaults.
///
/// Version history:
/// - 1.0.0: Initial version with string-based allergens
/// - 2.0.0: Added structured allergenInfo with UK allergen support
/// - 3.0.0: Changed dietary from `List<String>` to DietaryType? enum
/// - 4.0.0: Added optional calories (int?) field
final dishWidgetDefinition = WidgetDefinition<DishProps>(
  type: 'dish',
  version: '4.0.0',
  parseProps: (json) => DishProps.fromJson(json),
  render: (props, context) => DishWidget(props: props, context: context),
  defaultProps: const DishProps(name: 'New Dish', price: 0.0),
  migrate: _migrateDishProps,
);

/// Migrate dish props from older versions
///
/// Handles migration from v1.0.0 (string-based allergens) to v2.0.0
/// (structured AllergenInfo) and v2.0.0 to v3.0.0 (dietary enum).
DishProps _migrateDishProps(Map<String, dynamic> json) {
  final updatedJson = Map<String, dynamic>.from(json);

  // --- Allergen migration (v1 -> v2) ---
  if (!updatedJson.containsKey('allergenInfo') ||
      (updatedJson['allergenInfo'] as List?)?.isEmpty == true) {
    final legacyAllergens = updatedJson['allergens'] as List<dynamic>? ?? [];
    final migratedAllergenInfo = <AllergenInfo>[];
    for (final allergenStr in legacyAllergens) {
      if (allergenStr is String) {
        final info = AllergenInfo.fromLegacyString(allergenStr);
        if (info != null) migratedAllergenInfo.add(info);
      }
    }
    updatedJson['allergenInfo'] = migratedAllergenInfo
        .map((a) => a.toJson())
        .toList();
    updatedJson['allergens'] = <String>[];
  }

  // --- Dietary migration (v2 -> v3) ---
  final rawDietary = updatedJson['dietary'];
  if (rawDietary is List) {
    // Legacy List<String> format (including empty lists)
    if (rawDietary.isEmpty) {
      updatedJson['dietary'] = null;
    } else {
      DietaryType? resolved;
      for (final item in rawDietary) {
        if (item is String) {
          final parsed = DietaryType.fromString(item);
          if (parsed != null) {
            // Prefer vegan over vegetarian (vegan is more restrictive)
            if (parsed == DietaryType.vegan) {
              resolved = DietaryType.vegan;
              break;
            }
            resolved ??= parsed;
          }
        }
      }
      updatedJson['dietary'] = resolved?.name;
    }
  }
  // If rawDietary is already a String or null, fromJson handles it directly

  return DishProps.fromJson(updatedJson);
}
