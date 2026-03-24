import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';
import 'set_menu_dish_widget.dart';

/// Widget definition for SetMenuDishWidget
///
/// Version history:
/// - 1.0.0: Initial version
final setMenuDishWidgetDefinition =
    PresentableWidgetDefinition<SetMenuDishProps>(
      type: 'set_menu_dish',
      version: '1.0.0',
      parseProps: (json) => SetMenuDishProps.fromJson(json),
      render: (props, context) =>
          SetMenuDishWidget(props: props, context: context),
      defaultProps: const SetMenuDishProps(name: 'New Set Menu Dish'),
      migrate: _migrateSetMenuDishProps,
      displayName: 'Set Menu Dish',
      materialIcon: Icons.menu_book,
      cupertinoIcon: CupertinoIcons.doc_text,
    );

SetMenuDishProps _migrateSetMenuDishProps(Map<String, dynamic> json) {
  final updatedJson = Map<String, dynamic>.from(json);

  // --- Allergen migration ---
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

  return SetMenuDishProps.fromJson(updatedJson);
}
