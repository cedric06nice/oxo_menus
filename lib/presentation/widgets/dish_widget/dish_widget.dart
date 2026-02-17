import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'dish_edit_dialog.dart';

/// Widget that displays a menu dish with name, price, description, and dietary information
class DishWidget extends StatelessWidget {
  final DishProps props;
  final WidgetContext context;

  const DishWidget({super.key, required this.props, required this.context});

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
              // Dish name and price row
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

              // Description
              if (props.description != null &&
                  props.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  props.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],

              // Calories and Allergens
              if (context.displayOptions?.showAllergens ?? true) ...[
                if (props.calories != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${props.calories} KCAL',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                Builder(
                  builder: (context) {
                    final formattedAllergens =
                        AllergenFormatter.formatForDisplay(
                          props.effectiveAllergenInfo,
                        );
                    if (formattedAllergens.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        formattedAllergens,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
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

  void _handleEdit(BuildContext buildContext) {
    showDialog<DishProps>(
      context: buildContext,
      builder: (dialogContext) => DishEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
  }
}
