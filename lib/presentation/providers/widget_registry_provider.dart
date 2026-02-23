import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/wine_widget/wine_widget_definition.dart';

/// All built-in widget definitions.
///
/// To add a new widget type, add its definition to this list.
final allWidgetDefinitions = <WidgetDefinition>[
  dishWidgetDefinition,
  imageWidgetDefinition,
  sectionWidgetDefinition,
  textWidgetDefinition,
  wineWidgetDefinition,
];

/// Global widget registry provider
///
/// This provider creates and initializes the widget registry with all
/// available widget types. It should be accessed whenever you need to
/// look up a widget definition by type.
///
/// Example usage:
/// ```dart
/// final registry = ref.watch(widgetRegistryProvider);
/// final definition = registry.getDefinition('dish');
/// if (definition != null) {
///   final props = definition.parseProps(jsonData);
///   final widget = definition.render(props, context);
/// }
/// ```
final widgetRegistryProvider = Provider<WidgetRegistry>((ref) {
  final registry = WidgetRegistry();
  for (final definition in allWidgetDefinitions) {
    registry.register(definition);
  }
  return registry;
});
