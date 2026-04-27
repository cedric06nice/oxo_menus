import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_definition.dart';
import 'dish_widget.dart';

final dishWidgetDefinition = PresentableWidgetDefinition<DishProps>(
  type: 'dish',
  version: '1.0.0',
  parseProps: (json) => DishProps.fromJson(json),
  render: (props, context) => DishWidget(props: props, context: context),
  defaultProps: const DishProps(name: 'New Dish', price: 0.0),
  displayName: 'Dish',
  materialIcon: Icons.restaurant_menu,
  cupertinoIcon: CupertinoIcons.list_bullet,
);
