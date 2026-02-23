import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/helpers/cupertino_picker_helper.dart';
import 'package:oxo_menus/presentation/pages/menu_list/menu_list_page.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class TemplateCreateDialog extends ConsumerStatefulWidget {
  final void Function(TemplateCreateResult) onSave;

  const TemplateCreateDialog({super.key, required this.onSave});

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

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

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

    switch (result) {
      case Success(:final value):
        setState(() {
          _sizes = value;
          _selectedSize = value.isNotEmpty ? value.first : null;
          _isLoadingSizes = false;
        });
      case Failure(:final error):
        setState(() {
          _sizeError = error.message;
          _isLoadingSizes = false;
        });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isApple ? _buildAppleForm(context) : _buildMaterialDialog(context);
  }

  Widget _buildAppleForm(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Create Template'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _canSave() ? _handleSave : null,
          child: const Text('Create'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('TEMPLATE DETAILS'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  prefix: const Text('Name'),
                  placeholder: 'Enter template name',
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
                CupertinoTextFormFieldRow(
                  controller: _versionController,
                  prefix: const Text('Version'),
                  placeholder: 'e.g. 1.0.0',
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('PAGE SIZE'),
              children: [_buildAppleSizeSelector()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleSizeSelector() {
    if (_isLoadingSizes) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CupertinoActivityIndicator(),
            SizedBox(width: 12),
            Flexible(child: Text('Loading sizes...')),
          ],
        ),
      );
    }

    if (_sizeError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error loading sizes: $_sizeError',
          style: TextStyle(color: CupertinoColors.destructiveRed),
        ),
      );
    }

    if (_sizes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No page sizes available.',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
            const SizedBox(height: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/admin/sizes');
              },
              child: const Text('Manage Page Sizes'),
            ),
          ],
        ),
      );
    }

    final sizeLabel = _selectedSize != null
        ? '${_selectedSize!.name} (${_selectedSize!.width.toInt()}x${_selectedSize!.height.toInt()} mm)'
        : 'Select';

    return CupertinoListTile(
      title: const Text('Page Size'),
      additionalInfo: Text(sizeLabel),
      trailing: const CupertinoListTileChevron(),
      onTap: () {
        showCupertinoPicker<domain.Size>(
          context,
          items: _sizes,
          currentValue: _selectedSize ?? _sizes.first,
          labelBuilder: (s) =>
              '${s.name} (${s.width.toInt()}x${s.height.toInt()} mm)',
          onSelected: (v) => setState(() => _selectedSize = v),
        );
      },
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
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
            _buildMaterialSizeDropdown(),
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

  Widget _buildMaterialSizeDropdown() {
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No page sizes available.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/admin/sizes');
            },
            child: const Text('Manage Page Sizes'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<domain.Size>(
      initialValue: _selectedSize,
      decoration: const InputDecoration(labelText: 'Page Size'),
      items: _sizes.map((domain.Size size) {
        return DropdownMenuItem<domain.Size>(
          value: size,
          child: Text(
            '${size.name} (${size.width.toInt()}x${size.height.toInt()} mm)',
          ),
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
        const SnackBar(content: Text('Please fill in all required fields')),
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
