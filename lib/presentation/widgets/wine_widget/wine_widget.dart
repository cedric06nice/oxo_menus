import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/shared/price_formatter.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';
import 'package:oxo_menus/presentation/widgets/common/price_cell.dart';
import 'wine_edit_dialog.dart';

class WineWidget extends StatelessWidget {
  final WineProps props;
  final WidgetContext context;

  const WineWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext) {
    final colorScheme = Theme.of(buildContext).colorScheme;
    final alignment = context.alignment;
    final showPrice = context.displayOptions?.showPrices ?? true;
    final showAllergens = context.displayOptions?.showAllergens ?? true;
    final textAlign = alignment.textAlign;

    const nameStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    const priceStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: alignment.crossAxis,
            children: [
              if (alignment.isJustified) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(child: Text(props.displayName, style: nameStyle)),
                    if (showPrice)
                      PriceCell(price: props.price, style: priceStyle),
                  ],
                ),
              ] else ...[
                Text(props.displayName, textAlign: textAlign, style: nameStyle),
                if (showPrice)
                  Text(
                    formatPrice(props.price),
                    textAlign: textAlign,
                    style: priceStyle,
                  ),
              ],
              if (props.vintage != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Vintage: ${props.vintage}',
                  textAlign: textAlign,
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
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (props.containsSulphites && showAllergens)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'SULPHITES',
                    textAlign: textAlign,
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

  Future<void> _handleEdit(BuildContext buildContext) async {
    context.onEditStarted?.call();
    await showEditDialog(
      buildContext,
      WineEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
    context.onEditEnded?.call();
  }
}
