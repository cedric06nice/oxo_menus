import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';

/// Dialog for editing menu-level display options
class MenuDisplayOptionsDialog extends StatefulWidget {
  final MenuDisplayOptions? displayOptions;
  final ValueChanged<MenuDisplayOptions> onSave;

  const MenuDisplayOptionsDialog({
    super.key,
    this.displayOptions,
    required this.onSave,
  });

  @override
  State<MenuDisplayOptionsDialog> createState() =>
      _MenuDisplayOptionsDialogState();
}

class _MenuDisplayOptionsDialogState extends State<MenuDisplayOptionsDialog> {
  late bool _showPrices;
  late bool _showAllergens;

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    _showPrices = widget.displayOptions?.showPrices ?? true;
    _showAllergens = widget.displayOptions?.showAllergens ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return _isApple
        ? _buildCupertinoDialog(context)
        : _buildMaterialDialog(context);
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Display Options'),
      content: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: Text('Show Prices')),
              CupertinoSwitch(
                value: _showPrices,
                onChanged: (value) => setState(() => _showPrices = value),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: Text('Show Allergens')),
              CupertinoSwitch(
                value: _showAllergens,
                onChanged: (value) => setState(() => _showAllergens = value),
              ),
            ],
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Display Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Show Prices'),
            subtitle: const Text('Display prices for all dishes'),
            value: _showPrices,
            onChanged: (value) => setState(() => _showPrices = value),
          ),
          SwitchListTile(
            title: const Text('Show Allergens'),
            subtitle: const Text('Display allergen information for all dishes'),
            value: _showAllergens,
            onChanged: (value) => setState(() => _showAllergens = value),
          ),
        ],
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
    final options = MenuDisplayOptions(
      showPrices: _showPrices,
      showAllergens: _showAllergens,
    );
    widget.onSave(options);
    Navigator.of(context).pop();
  }
}
