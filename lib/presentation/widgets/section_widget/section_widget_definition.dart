import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';
import 'section_widget.dart';

/// Widget definition for SectionWidget
///
/// Registers the section widget type with the widget registry,
/// defining how to parse props, render the widget, and provide defaults.
final sectionWidgetDefinition = PresentableWidgetDefinition<SectionProps>(
  type: 'section',
  version: '1.0.0',
  parseProps: (json) => SectionProps.fromJson(json),
  render: (props, context) => SectionWidget(props: props, context: context),
  defaultProps: const SectionProps(
    title: 'New Section',
    uppercase: true,
    showDivider: false,
  ),
  displayName: 'Section',
  materialIcon: Icons.title,
  cupertinoIcon: CupertinoIcons.textformat,
);
