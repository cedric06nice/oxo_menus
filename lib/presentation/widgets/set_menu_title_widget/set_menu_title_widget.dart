import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/set_menu_title/set_menu_title_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';
import 'set_menu_title_edit_dialog.dart';

/// Widget that displays a set menu title with optional subtitle and prices
class SetMenuTitleWidget extends StatelessWidget {
  final SetMenuTitleProps props;
  final WidgetContext context;

  const SetMenuTitleWidget({
    super.key,
    required this.props,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    final colorScheme = Theme.of(buildContext).colorScheme;
    final showPrices = context.displayOptions?.showPrices ?? true;

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              props.displayTitle,
              style: const TextStyle(
                fontFamily: 'LibreBaskerville',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            // Subtitle
            if (props.subtitle != null && props.subtitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                props.subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // Price lines
            if (showPrices) ...[
              if (props.formattedPrice1 != null) ...[
                const SizedBox(height: 8),
                Text(
                  props.formattedPrice1!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (props.formattedPrice2 != null) ...[
                const SizedBox(height: 4),
                Text(
                  props.formattedPrice2!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
      SetMenuTitleEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
    context.onEditEnded?.call();
  }
}
