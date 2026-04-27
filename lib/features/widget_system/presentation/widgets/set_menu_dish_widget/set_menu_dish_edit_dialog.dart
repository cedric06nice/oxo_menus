import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/allergens/domain/allergen_info.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/shared/presentation/helpers/cupertino_picker_helper.dart';
import 'package:oxo_menus/features/allergens/presentation/widgets/allergen_selector.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_edit_scaffold.dart';

/// Dialog for editing set menu dish properties
class SetMenuDishEditDialog extends StatefulWidget {
  final SetMenuDishProps props;
  final void Function(SetMenuDishProps) onSave;

  const SetMenuDishEditDialog({
    super.key,
    required this.props,
    required this.onSave,
  });

  @override
  State<SetMenuDishEditDialog> createState() => _SetMenuDishEditDialogState();
}

class _SetMenuDishEditDialogState extends State<SetMenuDishEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late TextEditingController _supplementPriceController;
  late DietaryType? _selectedDietary;
  late List<AllergenInfo> _selectedAllergens;
  late bool _hasSupplement;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.props.name);
    _descriptionController = TextEditingController(
      text: widget.props.description ?? '',
    );
    _caloriesController = TextEditingController(
      text: widget.props.calories?.toString() ?? '',
    );
    _supplementPriceController = TextEditingController(
      text: widget.props.supplementPrice.toString(),
    );
    _selectedDietary = widget.props.dietary;
    _selectedAllergens = List.from(widget.props.allergenInfo);
    _hasSupplement = widget.props.hasSupplement;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _supplementPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveEditScaffold(
      title: 'Edit Set Menu Dish',
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
          CupertinoTextFormFieldRow(
            controller: _caloriesController,
            prefix: const Text('Calories'),
            placeholder: 'Enter calories',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      CupertinoFormSection.insetGrouped(
        header: const Text('SUPPLEMENT'),
        children: [
          CupertinoListTile(
            title: const Text('Has supplement'),
            trailing: CupertinoSwitch(
              value: _hasSupplement,
              onChanged: (value) => setState(() => _hasSupplement = value),
            ),
          ),
          if (_hasSupplement)
            CupertinoTextFormFieldRow(
              controller: _supplementPriceController,
              prefix: const Text('Price (£)'),
              placeholder: 'Enter supplement price',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
      SwitchListTile(
        title: const Text('Supplement'),
        value: _hasSupplement,
        onChanged: (value) => setState(() => _hasSupplement = value),
        contentPadding: EdgeInsets.zero,
      ),
      if (_hasSupplement) ...[
        const SizedBox(height: 12),
        TextField(
          controller: _supplementPriceController,
          decoration: const InputDecoration(
            labelText: 'Supplement price',
            hintText: 'Enter supplement price',
            prefixText: '£',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
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
    final updatedProps = SetMenuDishProps(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      calories: int.tryParse(_caloriesController.text),
      allergenInfo: _selectedAllergens,
      dietary: _selectedDietary,
      hasSupplement: _hasSupplement,
      supplementPrice: _hasSupplement
          ? (double.tryParse(_supplementPriceController.text) ?? 0.0)
          : 0.0,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
