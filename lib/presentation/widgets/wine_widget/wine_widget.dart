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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
              if (props.description != null &&
                  props.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  props.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                      color: Colors.grey[700],
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
    showDialog<WineProps>(
      context: buildContext,
      builder: (dialogContext) => WineEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
  }
}
