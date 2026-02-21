import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';

/// Result returned from the SizeCreateEditDialog
class SizeCreateEditResult {
  final String name;
  final double width;
  final double height;
  final Status status;
  final String direction;

  const SizeCreateEditResult({
    required this.name,
    required this.width,
    required this.height,
    required this.status,
    required this.direction,
  });
}

/// Dialog for creating or editing a page size
class SizeCreateEditDialog extends StatefulWidget {
  final domain.Size? existingSize;
  final void Function(SizeCreateEditResult) onSave;

  const SizeCreateEditDialog({
    super.key,
    this.existingSize,
    required this.onSave,
  });

  @override
  State<SizeCreateEditDialog> createState() => _SizeCreateEditDialogState();
}

class _SizeCreateEditDialogState extends State<SizeCreateEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late String _direction;
  late Status _status;

  bool get _isEditMode => widget.existingSize != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSize;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _widthController = TextEditingController(
      text: existing != null ? existing.width.toString() : '',
    );
    _heightController = TextEditingController(
      text: existing != null ? existing.height.toString() : '',
    );
    _direction = existing?.direction ?? 'portrait';
    _status = existing?.status ?? Status.draft;

    _nameController.addListener(_onFieldChanged);
    _widthController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Page Size' : 'Create Page Size'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              autofocus: !_isEditMode,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _widthController,
              decoration: const InputDecoration(labelText: 'Width (mm)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (mm)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _direction,
              decoration: const InputDecoration(labelText: 'Direction'),
              items: const [
                DropdownMenuItem(value: 'portrait', child: Text('Portrait')),
                DropdownMenuItem(value: 'landscape', child: Text('Landscape')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _direction = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Status>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: Status.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(
                    status.name[0].toUpperCase() + status.name.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
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
          onPressed: _canSave() ? _handleSave : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  bool _canSave() {
    final name = _nameController.text.trim();
    final width = double.tryParse(_widthController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    return name.isNotEmpty &&
        width != null &&
        width > 0 &&
        height != null &&
        height > 0;
  }

  void _handleSave() {
    final result = SizeCreateEditResult(
      name: _nameController.text.trim(),
      width: double.parse(_widthController.text.trim()),
      height: double.parse(_heightController.text.trim()),
      status: _status,
      direction: _direction,
    );

    widget.onSave(result);
    Navigator.of(context).pop();
  }
}
