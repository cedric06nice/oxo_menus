import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/set_menu_title/set_menu_title_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_definition.dart';
import 'set_menu_title_widget.dart';

/// Widget definition for SetMenuTitleWidget
///
/// Version history:
/// - 1.0.0: Initial version
final setMenuTitleWidgetDefinition =
    PresentableWidgetDefinition<SetMenuTitleProps>(
      type: 'set_menu_title',
      version: '1.0.0',
      parseProps: (json) => SetMenuTitleProps.fromJson(json),
      render: (props, context) =>
          SetMenuTitleWidget(props: props, context: context),
      defaultProps: const SetMenuTitleProps(title: 'New Set Menu'),
      displayName: 'Set Menu Title',
      materialIcon: Icons.menu_book,
      cupertinoIcon: CupertinoIcons.doc_text,
    );
