import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';
import 'wine_widget.dart';

final wineWidgetDefinition = PresentableWidgetDefinition<WineProps>(
  type: 'wine',
  version: '1.0.0',
  parseProps: (json) => WineProps.fromJson(json),
  render: (props, context) => WineWidget(props: props, context: context),
  defaultProps: const WineProps(name: 'New Wine', price: 0.0),
  displayName: 'Wine',
  materialIcon: Icons.wine_bar,
  cupertinoIcon: CupertinoIcons.drop,
);
