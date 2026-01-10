import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'dish_widget.dart';

/// Widget definition for DishWidget
///
/// Registers the dish widget type with the widget registry,
/// defining how to parse props, render the widget, and provide defaults.
final dishWidgetDefinition = WidgetDefinition<DishProps>(
  type: 'dish',
  version: '1.0.0',
  parseProps: (json) => DishProps.fromJson(json),
  render: (props, context) => DishWidget(
    props: props,
    context: context,
  ),
  defaultProps: const DishProps(
    name: 'New Dish',
    price: 0.0,
    showPrice: true,
    showAllergens: true,
  ),
);
