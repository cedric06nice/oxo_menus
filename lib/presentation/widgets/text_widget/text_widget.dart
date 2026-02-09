import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'text_edit_dialog.dart';

/// Widget that displays formatted text content
class TextWidget extends StatelessWidget {
  final TextProps props;
  final WidgetContext context;

  const TextWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext) {
    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          props.text,
          textAlign: _getTextAlign(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: props.bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: props.italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  TextAlign _getTextAlign() {
    switch (props.align.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
      default:
        return TextAlign.left;
    }
  }

  void _handleEdit(BuildContext buildContext) {
    showDialog<TextProps>(
      context: buildContext,
      builder: (dialogContext) => TextEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
  }
}
