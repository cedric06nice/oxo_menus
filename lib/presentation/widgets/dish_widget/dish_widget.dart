import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widgets/shared/price_formatter.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';
import 'package:oxo_menus/presentation/widgets/common/price_cell.dart';
import 'dish_edit_dialog.dart';

/// Widget that displays a menu dish with name, price, description, and dietary information
class DishWidget extends StatelessWidget {
  final DishProps props;
  final WidgetContext context;

  const DishWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext) {
    final colorScheme = Theme.of(buildContext).colorScheme;
    final alignment = context.alignment;
    final showPrice = context.displayOptions?.showPrices ?? true;
    final showAllergens = context.displayOptions?.showAllergens ?? true;
    final textAlign = alignment.textAlign;

    const nameStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    const priceStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    final hasVariants = props.hasMultiplePrices;

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: alignment.crossAxis,
            children: [
              if (hasVariants) ...[
                Text(props.displayName, textAlign: textAlign, style: nameStyle),
                if (showPrice)
                  for (final variant in props.priceVariants)
                    if (alignment.isJustified)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(variant.label, style: priceStyle),
                          ),
                          PriceCell(price: variant.price, style: priceStyle),
                        ],
                      )
                    else
                      Text(
                        '${variant.label} — ${formatPrice(variant.price)}',
                        textAlign: textAlign,
                        style: priceStyle,
                      ),
              ] else if (alignment.isJustified) ...[
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
              if (showAllergens) ...[
                if (props.calories != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${props.calories} KCAL',
                      textAlign: textAlign,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Builder(
                  builder: (ctx) {
                    final formattedAllergens =
                        AllergenFormatter.formatForDisplay(props.allergenInfo);
                    if (formattedAllergens.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        formattedAllergens,
                        textAlign: textAlign,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ],
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
      DishEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
    context.onEditEnded?.call();
  }
}
