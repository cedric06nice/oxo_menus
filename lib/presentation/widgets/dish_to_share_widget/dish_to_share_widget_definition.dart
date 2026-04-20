import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/dish_to_share/dish_to_share_props.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';
import 'dish_to_share_widget.dart';

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
      displayName: 'Dish To Share',
      materialIcon: Icons.group,
      cupertinoIcon: CupertinoIcons.person_2,
    );
