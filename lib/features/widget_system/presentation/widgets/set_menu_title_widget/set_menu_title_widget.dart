import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/set_menu_title/set_menu_title_props.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_definition.dart';
import 'package:oxo_menus/shared/presentation/helpers/edit_dialog_helper.dart';
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

    final titleText = props.displayTitle;
    final pricesText = showPrices && props.formattedPrices != null
        ? '  ${props.formattedPrices}'
        : '';

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with inline prices
            Text(
              '$titleText$pricesText',
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
