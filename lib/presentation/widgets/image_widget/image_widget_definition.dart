import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'image_widget.dart';

/// Widget definition for ImageWidget
///
/// Registers the image widget type with the widget registry,
/// defining how to parse props, render the widget, and provide defaults.
final imageWidgetDefinition = WidgetDefinition<ImageProps>(
  type: 'image',
  version: '1.0.0',
  parseProps: (json) => ImageProps.fromJson(json),
  render: (props, context) => ImageWidget(props: props, context: context),
  defaultProps: const ImageProps(
    fileId: 'placeholder',
    align: 'center',
    fit: 'contain',
  ),
);
