import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_definition.dart';
import 'package:oxo_menus/shared/presentation/helpers/edit_dialog_helper.dart';
import 'section_edit_dialog.dart';

/// Widget that displays a section header/divider in a menu
class SectionWidget extends StatelessWidget {
  final SectionProps props;
  final WidgetContext context;

  const SectionWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext) {
    final colorScheme = Theme.of(buildContext).colorScheme;
    // Section has no price line, so `justified` falls back to `start`.
    final alignment = context.alignment.isJustified
        ? WidgetAlignment.start
        : context.alignment;

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: alignment.crossAxis,
          children: [
            // Section title
            Text(
              props.uppercase ? props.title.toUpperCase() : props.title,
              textAlign: alignment.textAlign,
              style: const TextStyle(
                fontFamily: 'LibreBaskerville',
                fontSize: 17,
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

  Future<void> _handleEdit(BuildContext buildContext) async {
    context.onEditStarted?.call();
    await showEditDialog(
      buildContext,
      SectionEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
    context.onEditEnded?.call();
  }
}
