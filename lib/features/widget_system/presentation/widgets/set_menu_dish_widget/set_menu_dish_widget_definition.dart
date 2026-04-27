import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_definition.dart';
import 'set_menu_dish_widget.dart';

final setMenuDishWidgetDefinition =
    PresentableWidgetDefinition<SetMenuDishProps>(
      type: 'set_menu_dish',
      version: '1.0.0',
      parseProps: (json) => SetMenuDishProps.fromJson(json),
      render: (props, context) =>
          SetMenuDishWidget(props: props, context: context),
      defaultProps: const SetMenuDishProps(name: 'New Set Menu Dish'),
      displayName: 'Set Menu Dish',
      materialIcon: Icons.menu_book,
      cupertinoIcon: CupertinoIcons.doc_text,
    );
