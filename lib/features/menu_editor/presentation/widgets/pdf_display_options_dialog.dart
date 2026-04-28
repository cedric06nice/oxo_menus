import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Dialog shown before PDF preview to select display options.
///
/// Returns [MenuDisplayOptions] on confirm, or null on cancel.
/// Does not persist to server — options are transient for the preview.
class PdfDisplayOptionsDialog extends StatefulWidget {
  const PdfDisplayOptionsDialog({super.key});

  @override
  State<PdfDisplayOptionsDialog> createState() =>
      _PdfDisplayOptionsDialogState();
}

class _PdfDisplayOptionsDialogState extends State<PdfDisplayOptionsDialog> {
  bool _showPrices = true;
  bool _showAllergens = false;

  @override
  Widget build(BuildContext context) {
    return isApplePlatform(context)
        ? _buildCupertinoDialog(context)
        : _buildMaterialDialog(context);
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('PDF Options'),
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
          onPressed: _handlePreview,
          child: const Text('Preview'),
        ),
      ],
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('PDF Options'),
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
        ElevatedButton(onPressed: _handlePreview, child: const Text('Preview')),
      ],
    );
  }

  void _handlePreview() {
    Navigator.of(context).pop(
      MenuDisplayOptions(
        showPrices: _showPrices,
        showAllergens: _showAllergens,
      ),
    );
  }
}
