import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/dish_to_share/dish_to_share_props.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';
import 'dish_to_share_widget.dart';

/// Widget definition for DishToShareWidget
///
/// Version history:
/// - 1.0.0: Initial version
final dishToShareWidgetDefinition =
    PresentableWidgetDefinition<DishToShareProps>(
      type: 'dish_to_share',
      version: '1.0.0',
      parseProps: (json) => DishToShareProps.fromJson(json),
      render: (props, context) =>
          DishToShareWidget(props: props, context: context),
      defaultProps: const DishToShareProps(
        name: 'New Dish To Share',
        price: 0.0,
      ),
      migrate: _migrateDishToShareProps,
      displayName: 'Dish To Share',
      materialIcon: Icons.group,
      cupertinoIcon: CupertinoIcons.person_2,
    );

DishToShareProps _migrateDishToShareProps(Map<String, dynamic> json) {
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

  // --- Dietary migration (list -> enum) ---
  final rawDietary = updatedJson['dietary'];
  if (rawDietary is List) {
    if (rawDietary.isEmpty) {
      updatedJson['dietary'] = null;
    } else {
      DietaryType? resolved;
      for (final item in rawDietary) {
        if (item is String) {
          final parsed = DietaryType.fromString(item);
          if (parsed != null) {
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

  return DishToShareProps.fromJson(updatedJson);
}
