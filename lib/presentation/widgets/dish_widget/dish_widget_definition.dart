import 'package:oxo_menus/domain/allergens/allergen_info.dart';
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
final dishWidgetDefinition = WidgetDefinition<DishProps>(
  type: 'dish',
  version: '2.0.0',
  parseProps: (json) => DishProps.fromJson(json),
  render: (props, context) => DishWidget(props: props, context: context),
  defaultProps: const DishProps(name: 'New Dish', price: 0.0),
  migrate: _migrateDishProps,
);

/// Migrate dish props from older versions
///
/// Handles migration from v1.0.0 (string-based allergens) to v2.0.0
/// (structured AllergenInfo).
DishProps _migrateDishProps(Map<String, dynamic> json) {
  // If already has allergenInfo, use as-is
  if (json.containsKey('allergenInfo') &&
      (json['allergenInfo'] as List?)?.isNotEmpty == true) {
    return DishProps.fromJson(json);
  }

  // Migrate from legacy allergens field
  final legacyAllergens = json['allergens'] as List<dynamic>? ?? [];
  final migratedAllergenInfo = <AllergenInfo>[];

  for (final allergenStr in legacyAllergens) {
    if (allergenStr is String) {
      final info = AllergenInfo.fromLegacyString(allergenStr);
      if (info != null) {
        migratedAllergenInfo.add(info);
      }
    }
  }

  // Create updated JSON with migrated allergen info
  final updatedJson = Map<String, dynamic>.from(json);
  updatedJson['allergenInfo'] = migratedAllergenInfo
      .map((a) => a.toJson())
      .toList();
  updatedJson['allergens'] = <String>[]; // Clear legacy field

  return DishProps.fromJson(updatedJson);
}
