import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';
import 'section_edit_dialog.dart';

/// Widget that displays a section header/divider in a menu
class SectionWidget extends StatelessWidget {
  final SectionProps props;
  final WidgetContext context;

  const SectionWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext) {
    final colorScheme = Theme.of(buildContext).colorScheme;

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              props.uppercase ? props.title.toUpperCase() : props.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            // Divider
            if (props.showDivider) ...[
              const SizedBox(height: 4),
              Divider(thickness: 2, color: colorScheme.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }

  void _handleEdit(BuildContext buildContext) {
    showEditDialog(
      buildContext,
      SectionEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
  }
}
