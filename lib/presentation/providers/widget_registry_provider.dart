import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/dish_to_share_widget/dish_to_share_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/set_menu_dish_widget/set_menu_dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/wine_widget/wine_widget_definition.dart';

/// All built-in widget definitions.
///
/// To add a new widget type, add its definition to this list.
final allWidgetDefinitions = <PresentableWidgetDefinition>[
  dishWidgetDefinition,
  dishToShareWidgetDefinition,
  imageWidgetDefinition,
  sectionWidgetDefinition,
  setMenuDishWidgetDefinition,
  textWidgetDefinition,
  wineWidgetDefinition,
];

/// Global widget registry provider
///
/// This provider creates and initializes the widget registry with all
/// available widget types. It should be accessed whenever you need to
/// look up a widget definition by type.
final widgetRegistryProvider = Provider<PresentableWidgetRegistry>((ref) {
  final registry = PresentableWidgetRegistry();
  for (final definition in allWidgetDefinitions) {
    registry.register(definition);
  }
  return registry;
});
