import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'wine_edit_dialog.dart';

class WineWidget extends StatelessWidget {
  final WineProps props;
  final WidgetContext context;

  const WineWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext) {
    final colorScheme = Theme.of(buildContext).colorScheme;

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      props.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (context.displayOptions?.showPrices ?? true)
                    Text(
                      '£${props.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              if (props.vintage != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Vintage: ${props.vintage}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (props.description != null &&
                  props.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  props.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (props.containsSulphites &&
                  (context.displayOptions?.showAllergens ?? true))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'SULPHITES',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEdit(BuildContext buildContext) {
    final platform = Theme.of(buildContext).platform;
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    final dialog = WineEditDialog(
      props: props,
      onSave: (updatedProps) {
        context.onUpdate?.call(updatedProps.toJson());
      },
    );

    if (isApple) {
      Navigator.of(buildContext).push(
        CupertinoPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => dialog,
        ),
      );
    } else {
      showDialog<WineProps>(
        context: buildContext,
        builder: (dialogContext) => dialog,
      );
    }
  }
}
