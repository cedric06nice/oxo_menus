import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'section_widget.dart';

/// Widget definition for SectionWidget
///
/// Registers the section widget type with the widget registry,
/// defining how to parse props, render the widget, and provide defaults.
final sectionWidgetDefinition = WidgetDefinition<SectionProps>(
  type: 'section',
  version: '1.0.0',
  parseProps: (json) => SectionProps.fromJson(json),
  render: (props, context) => SectionWidget(props: props, context: context),
  defaultProps: const SectionProps(
    title: 'New Section',
    uppercase: false,
    showDivider: true,
  ),
  displayName: 'Section',
  materialIcon: Icons.title,
  cupertinoIcon: CupertinoIcons.textformat,
);
