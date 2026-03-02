import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';
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
      child: SizedBox(
        width: double.infinity,
        child: Text(
          props.text,
          textAlign: _getTextAlign(),
          style: TextStyle(
            fontSize: props.fontSize,
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

  Future<void> _handleEdit(BuildContext buildContext) async {
    context.onEditStarted?.call();
    await showEditDialog(
      buildContext,
      TextEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
    context.onEditEnded?.call();
  }
}
