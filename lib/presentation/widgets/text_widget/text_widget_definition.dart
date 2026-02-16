import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'text_widget.dart';

/// Widget definition for TextWidget
///
/// Registers the text widget type with the widget registry,
/// defining how to parse props, render the widget, and provide defaults.
final textWidgetDefinition = WidgetDefinition<TextProps>(
  type: 'text',
  version: '1.0.0',
  parseProps: (json) => TextProps.fromJson(json),
  render: (props, context) => TextWidget(props: props, context: context),
  defaultProps: const TextProps(
    text: 'New Text',
    fontSize: 10.0,
    align: 'left',
    bold: false,
    italic: false,
  ),
);
