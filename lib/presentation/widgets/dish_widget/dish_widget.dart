import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'dish_edit_dialog.dart';

/// Widget that displays a menu dish with name, price, description, and dietary information
class DishWidget extends StatelessWidget {
  final DishProps props;
  final WidgetContext context;

  const DishWidget({
    super.key,
    required this.props,
    required this.context,
  });

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
                      props.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (props.showPrice)
                    Text(
                      '\$${props.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              // Description
              if (props.description != null && props.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  props.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              // Allergens
              if (props.showAllergens && props.allergens.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: props.allergens
                      .map((allergen) => Chip(
                            label: Text(
                              allergen,
                              style: const TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.orange[100],
                          ))
                      .toList(),
                ),
              ],

              // Dietary
              if (props.dietary.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: props.dietary
                      .map((diet) => Chip(
                            label: Text(
                              diet,
                              style: const TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.green[100],
                          ))
                      .toList(),
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
