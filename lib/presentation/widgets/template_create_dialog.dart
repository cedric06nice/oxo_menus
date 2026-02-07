import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/menu_list/menu_list_page.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class TemplateCreateDialog extends ConsumerStatefulWidget {
  final void Function(TemplateCreateResult) onSave;

  const TemplateCreateDialog({
    super.key,
    required this.onSave,
  });

  @override
  ConsumerState<TemplateCreateDialog> createState() =>
      _TemplateCreateDialogState();
}

class _TemplateCreateDialogState extends ConsumerState<TemplateCreateDialog> {
  late TextEditingController _nameController;
  late TextEditingController _versionController;

  List<domain.Size> _sizes = [];
  domain.Size? _selectedSize;
  bool _isLoadingSizes = true;
  String? _sizeError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _versionController = TextEditingController(text: '1.0.0');
    _loadSizes();
  }

  Future<void> _loadSizes() async {
    final sizeRepository = ref.read(sizeRepositoryProvider);
    final result = await sizeRepository.getAll();

    if (!mounted) return;

    result.fold(
      onSuccess: (sizes) {
        setState(() {
          _sizes = sizes;
          _selectedSize = sizes.isNotEmpty ? sizes.first : null;
          _isLoadingSizes = false;
        });
      },
      onFailure: (error) {
        setState(() {
          _sizeError = error.message;
          _isLoadingSizes = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Template'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                hintText: 'Enter template name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _versionController,
              decoration: const InputDecoration(
                labelText: 'Version',
                hintText: 'Enter template version (e.g. 1.0.0)',
              ),
            ),
            const SizedBox(height: 16),
            _buildSizeDropdown(),
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
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildSizeDropdown() {
    if (_isLoadingSizes) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading sizes...'),
        ],
      );
    }

    if (_sizeError != null) {
      return Text(
        'Error loading sizes: $_sizeError',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    if (_sizes.isEmpty) {
      return Text(
        'No sizes available. Please add sizes in Directus first.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    return DropdownButtonFormField<domain.Size>(
      initialValue: _selectedSize,
      decoration: const InputDecoration(
        labelText: 'Page Size',
      ),
      items: _sizes.map((domain.Size size) {
        return DropdownMenuItem<domain.Size>(
          value: size,
          child: Text(
              '${size.name} (${size.width.toInt()}x${size.height.toInt()} mm)'),
        );
      }).toList(),
      onChanged: (size) {
        setState(() {
          _selectedSize = size;
        });
      },
    );
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty &&
        _versionController.text.trim().isNotEmpty &&
        _selectedSize != null;
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final version = _versionController.text.trim();

    if (name.isEmpty || version.isEmpty || _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all required fields')),
      );
      return;
    }

    final result = TemplateCreateResult(
      name: name,
      status: Status.draft,
      version: version,
      sizeId: _selectedSize!.id,
    );

    widget.onSave(result);
    Navigator.of(context).pop();
  }
}
