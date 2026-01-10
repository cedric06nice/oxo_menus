import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';

/// Dialog for editing dish properties
class DishEditDialog extends StatefulWidget {
  final DishProps props;
  final void Function(DishProps) onSave;

  const DishEditDialog({
    super.key,
    required this.props,
    required this.onSave,
  });

  @override
  State<DishEditDialog> createState() => _DishEditDialogState();
}

class _DishEditDialogState extends State<DishEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _allergensController;
  late TextEditingController _dietaryController;
  late bool _showPrice;
  late bool _showAllergens;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.props.name);
    _priceController =
        TextEditingController(text: widget.props.price.toString());
    _descriptionController =
        TextEditingController(text: widget.props.description ?? '');
    _allergensController =
        TextEditingController(text: widget.props.allergens.join(', '));
    _dietaryController =
        TextEditingController(text: widget.props.dietary.join(', '));
    _showPrice = widget.props.showPrice;
    _showAllergens = widget.props.showAllergens;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _allergensController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Dish'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter dish name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
                prefixText: '\$',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _allergensController,
              decoration: const InputDecoration(
                labelText: 'Allergens',
                hintText: 'Comma-separated (e.g., Dairy, Gluten)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dietaryController,
              decoration: const InputDecoration(
                labelText: 'Dietary',
                hintText: 'Comma-separated (e.g., Vegan, Gluten-Free)',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Show Price'),
              value: _showPrice,
              onChanged: (value) => setState(() => _showPrice = value),
              dense: true,
            ),
            SwitchListTile(
              title: const Text('Show Allergens'),
              value: _showAllergens,
              onChanged: (value) => setState(() => _showAllergens = value),
              dense: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _handleSave() {
    final updatedProps = DishProps(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? widget.props.price,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      allergens: _allergensController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      dietary: _dietaryController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      showPrice: _showPrice,
      showAllergens: _showAllergens,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
