import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/wine/wine_props.dart';
import 'package:oxo_menus/presentation/helpers/cupertino_picker_helper.dart';

class WineEditDialog extends StatefulWidget {
  final WineProps props;
  final void Function(WineProps) onSave;

  const WineEditDialog({super.key, required this.props, required this.onSave});

  @override
  State<WineEditDialog> createState() => _WineEditDialogState();
}

class _WineEditDialogState extends State<WineEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _vintageController;
  late DietaryType? _selectedDietary;
  late bool _containsSulphites;

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
    _vintageController = TextEditingController(
      text: widget.props.vintage?.toString() ?? '',
    );
    _selectedDietary = widget.props.dietary;
    _containsSulphites = widget.props.containsSulphites;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _vintageController.dispose();
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
        middle: const Text('Edit Wine'),
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
              header: const Text('WINE DETAILS'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  prefix: const Text('Name'),
                  placeholder: 'Enter wine name',
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
                  controller: _vintageController,
                  prefix: const Text('Vintage'),
                  placeholder: 'Enter vintage year',
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      CupertinoCheckbox(
                        value: _containsSulphites,
                        onChanged: (value) {
                          setState(() => _containsSulphites = value ?? false);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Flexible(child: Text('Contains sulphites')),
                    ],
                  ),
                ),
              ],
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
      title: const Text('Edit Wine'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter wine name',
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
              controller: _vintageController,
              decoration: const InputDecoration(
                labelText: 'Vintage',
                hintText: 'Enter vintage year',
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
            CheckboxListTile(
              title: const Text('Contains sulphites'),
              value: _containsSulphites,
              onChanged: (value) {
                setState(() => _containsSulphites = value ?? false);
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
    final updatedProps = WineProps(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? widget.props.price,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      vintage: int.tryParse(_vintageController.text),
      dietary: _selectedDietary,
      containsSulphites: _containsSulphites,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
