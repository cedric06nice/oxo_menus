import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/allergens/domain/allergen_info.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/dish/price_variant.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/shared/presentation/helpers/cupertino_picker_helper.dart';
import 'package:oxo_menus/features/allergens/presentation/widgets/allergen_selector.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_edit_scaffold.dart';

/// Dialog for editing dish properties
class DishEditDialog extends StatefulWidget {
  final DishProps props;
  final void Function(DishProps) onSave;

  const DishEditDialog({super.key, required this.props, required this.onSave});

  @override
  State<DishEditDialog> createState() => _DishEditDialogState();
}

class _VariantRowControllers {
  final TextEditingController label;
  final TextEditingController price;

  _VariantRowControllers({required this.label, required this.price});

  factory _VariantRowControllers.fromVariant(PriceVariant variant) =>
      _VariantRowControllers(
        label: TextEditingController(text: variant.label),
        price: TextEditingController(text: _formatPrice(variant.price)),
      );

  factory _VariantRowControllers.empty() => _VariantRowControllers(
    label: TextEditingController(),
    price: TextEditingController(),
  );

  void dispose() {
    label.dispose();
    price.dispose();
  }

  static String _formatPrice(double price) {
    if (price == price.truncateToDouble()) {
      return price.toStringAsFixed(0);
    }
    return price.toString();
  }
}

class _DishEditDialogState extends State<DishEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late DietaryType? _selectedDietary;
  late List<AllergenInfo> _selectedAllergens;
  late bool _useMultiplePrices;
  late List<_VariantRowControllers> _variantControllers;
  String? _variantError;

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
    _selectedAllergens = List.from(widget.props.allergenInfo);
    _useMultiplePrices = widget.props.priceVariants.isNotEmpty;
    _variantControllers = widget.props.priceVariants.isNotEmpty
        ? widget.props.priceVariants
              .map(_VariantRowControllers.fromVariant)
              .toList()
        : [_VariantRowControllers.empty(), _VariantRowControllers.empty()];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    for (final row in _variantControllers) {
      row.dispose();
    }
    super.dispose();
  }

  void _toggleMultiplePrices(bool value) {
    setState(() {
      _useMultiplePrices = value;
      _variantError = null;
      if (value && _variantControllers.isEmpty) {
        _variantControllers = [
          _VariantRowControllers.empty(),
          _VariantRowControllers.empty(),
        ];
      }
    });
  }

  void _addVariantRow() {
    setState(() {
      _variantControllers.add(_VariantRowControllers.empty());
    });
  }

  void _removeVariantRow(int index) {
    setState(() {
      _variantControllers[index].dispose();
      _variantControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveEditScaffold(
      title: 'Edit Dish',
      onSave: _handleSave,
      appleFormChildren: _buildAppleFormChildren(context),
      materialFormChildren: _buildMaterialFormChildren(context),
    );
  }

  List<Widget> _buildAppleFormChildren(BuildContext context) {
    final dietaryLabel = _selectedDietary?.displayName ?? 'None';

    return [
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
          if (!_useMultiplePrices)
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
        header: const Text('PRICING'),
        children: [
          CupertinoListTile(
            title: const Text('Use multiple prices'),
            trailing: CupertinoSwitch(
              value: _useMultiplePrices,
              onChanged: _toggleMultiplePrices,
            ),
          ),
          if (_useMultiplePrices) ...[
            for (var i = 0; i < _variantControllers.length; i++)
              CupertinoListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _variantControllers[i].label,
                        placeholder: 'Label',
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: CupertinoTextField(
                        controller: _variantControllers[i].price,
                        placeholder: '£',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _removeVariantRow(i),
                      child: const Icon(CupertinoIcons.minus_circle),
                    ),
                  ],
                ),
              ),
            CupertinoListTile(
              title: const Text('Add price'),
              leading: const Icon(CupertinoIcons.add_circled),
              onTap: _addVariantRow,
            ),
            if (_variantError != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _variantError!,
                  style: const TextStyle(color: CupertinoColors.systemRed),
                ),
              ),
          ],
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
      AllergenSelector(
        initialSelection: _selectedAllergens,
        onChanged: (allergens) {
          setState(() => _selectedAllergens = allergens);
        },
      ),
    ];
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

  List<Widget> _buildMaterialFormChildren(BuildContext context) {
    return [
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
      if (!_useMultiplePrices)
        TextField(
          controller: _priceController,
          decoration: const InputDecoration(
            labelText: 'Price',
            hintText: 'Enter price',
            prefixText: '£',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      if (!_useMultiplePrices) const SizedBox(height: 12),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Use multiple prices'),
        value: _useMultiplePrices,
        onChanged: _toggleMultiplePrices,
      ),
      if (_useMultiplePrices) ...[
        for (var i = 0; i < _variantControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _variantControllers[i].label,
                    decoration: const InputDecoration(
                      labelText: 'Label',
                      hintText: 'e.g. Small, Per 6',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _variantControllers[i].price,
                    decoration: const InputDecoration(
                      labelText: 'Variant price',
                      prefixText: '£',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove price',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeVariantRow(i),
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: _addVariantRow,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add price'),
        ),
        if (_variantError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              _variantError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
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
          Text('Dietary type', style: Theme.of(context).textTheme.titleMedium),
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
    ];
  }

  void _handleSave() {
    if (_useMultiplePrices) {
      final parsedVariants = <PriceVariant>[];
      for (final row in _variantControllers) {
        final label = row.label.text.trim();
        final priceText = row.price.text.trim();
        final price = double.tryParse(priceText);
        if (label.isEmpty) {
          setState(() => _variantError = 'Each price needs a label.');
          return;
        }
        if (price == null) {
          setState(() => _variantError = 'Enter a valid price for "$label".');
          return;
        }
        parsedVariants.add(PriceVariant(label: label, price: price));
      }
      if (parsedVariants.isEmpty) {
        setState(() => _variantError = 'Add at least one price.');
        return;
      }
      setState(() => _variantError = null);

      final updatedProps = DishProps(
        name: _nameController.text.trim(),
        price: parsedVariants.first.price,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        calories: int.tryParse(_caloriesController.text),
        allergenInfo: _selectedAllergens,
        dietary: _selectedDietary,
        priceVariants: parsedVariants,
      );

      widget.onSave(updatedProps);
      Navigator.of(context).pop();
      return;
    }

    final updatedProps = DishProps(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? widget.props.price,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      calories: int.tryParse(_caloriesController.text),
      allergenInfo: _selectedAllergens,
      dietary: _selectedDietary,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
