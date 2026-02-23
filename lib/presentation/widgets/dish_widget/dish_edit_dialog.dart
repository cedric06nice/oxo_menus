import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/presentation/helpers/cupertino_picker_helper.dart';
import 'package:oxo_menus/presentation/widgets/allergen_selector/allergen_selector.dart';

/// Dialog for editing dish properties
class DishEditDialog extends StatefulWidget {
  final DishProps props;
  final void Function(DishProps) onSave;

  const DishEditDialog({super.key, required this.props, required this.onSave});

  @override
  State<DishEditDialog> createState() => _DishEditDialogState();
}

class _DishEditDialogState extends State<DishEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late DietaryType? _selectedDietary;
  late List<AllergenInfo> _selectedAllergens;

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.props.name);
    _priceController = TextEditingController(
      text: widget.props.price.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.props.description ?? '',
    );
    _caloriesController = TextEditingController(
      text: widget.props.calories?.toString() ?? '',
    );
    _selectedDietary = widget.props.dietary;
    _selectedAllergens = List.from(widget.props.effectiveAllergenInfo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isApple ? _buildAppleForm(context) : _buildMaterialDialog(context);
  }

  Widget _buildAppleForm(BuildContext context) {
    final dietaryLabel = _selectedDietary?.displayName ?? 'None';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Dish'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('DISH DETAILS'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  prefix: const Text('Name'),
                  placeholder: 'Enter dish name',
                ),
                CupertinoTextFormFieldRow(
                  controller: _descriptionController,
                  prefix: const Text('Description'),
                  placeholder: 'Enter description',
                  maxLines: 3,
                ),
                CupertinoTextFormFieldRow(
                  controller: _priceController,
                  prefix: const Text('Price (£)'),
                  placeholder: 'Enter price',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                CupertinoTextFormFieldRow(
                  controller: _caloriesController,
                  prefix: const Text('Calories'),
                  placeholder: 'Enter calories',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('OPTIONS'),
              children: [
                CupertinoListTile(
                  title: const Text('Dietary type'),
                  additionalInfo: Text(dietaryLabel),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _showDietaryPicker(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AllergenSelector(
                initialSelection: _selectedAllergens,
                onChanged: (allergens) {
                  setState(() => _selectedAllergens = allergens);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDietaryPicker(BuildContext context) {
    final items = [null, ...DietaryType.values];
    showCupertinoPicker<DietaryType?>(
      context,
      items: items,
      currentValue: _selectedDietary,
      labelBuilder: (type) => type?.displayName ?? 'None',
      onSelected: (value) => setState(() => _selectedDietary = value),
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter description',
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
                prefixText: '£',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories',
                hintText: 'Enter calories',
                suffixText: 'KCAL',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dietary type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
              ],
            ),
            DropdownButton<DietaryType?>(
              value: _selectedDietary,
              isExpanded: true,
              items: [
                const DropdownMenuItem<DietaryType?>(
                  value: null,
                  child: Text('None'),
                ),
                ...DietaryType.values.map(
                  (type) => DropdownMenuItem<DietaryType?>(
                    value: type,
                    child: Text(type.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedDietary = value);
              },
            ),
            const SizedBox(height: 12),
            AllergenSelector(
              initialSelection: _selectedAllergens,
              onChanged: (allergens) {
                setState(() => _selectedAllergens = allergens);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _handleSave, child: const Text('Save')),
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
      calories: int.tryParse(_caloriesController.text),
      allergens: const [], // Clear legacy field
      allergenInfo: _selectedAllergens,
      dietary: _selectedDietary,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
