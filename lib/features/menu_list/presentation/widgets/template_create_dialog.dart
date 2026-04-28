import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/presentation/helpers/cupertino_picker_helper.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_settings/menu_settings_provider.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_settings/menu_settings_state.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Result from the template create dialog
class TemplateCreateResult {
  final String name;
  final Status status;
  final String version;
  final int sizeId;
  final int? areaId;

  const TemplateCreateResult({
    required this.name,
    required this.status,
    required this.version,
    required this.sizeId,
    this.areaId,
  });
}

class TemplateCreateDialog extends ConsumerStatefulWidget {
  final void Function(TemplateCreateResult) onSave;

  /// Invoked when the user taps the "Manage Sizes" CTA shown when no sizes
  /// exist yet. The screen wires this through `MenuListRouter.pushAdminSizes`
  /// so the user can return to the dialog with back navigation.
  final VoidCallback? onOpenSizes;

  const TemplateCreateDialog({
    super.key,
    required this.onSave,
    this.onOpenSizes,
  });

  @override
  ConsumerState<TemplateCreateDialog> createState() =>
      _TemplateCreateDialogState();
}

class _TemplateCreateDialogState extends ConsumerState<TemplateCreateDialog> {
  late TextEditingController _nameController;
  late TextEditingController _versionController;

  domain.Size? _selectedSize;
  Area? _selectedArea;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _versionController = TextEditingController(text: '1.0.0');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(menuSettingsProvider.notifier);
      notifier.loadSizes();
      notifier.loadAreas();
    });
    _listenForSizesLoaded();
  }

  void _listenForSizesLoaded() {
    ref.listenManual(menuSettingsProvider, (prev, next) {
      final hadNoSizes = prev?.sizes.isEmpty ?? true;
      if (hadNoSizes && next.sizes.isNotEmpty && _selectedSize == null) {
        setState(() => _selectedSize = next.sizes.first);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(menuSettingsProvider);

    return isApplePlatform(context)
        ? _buildAppleForm(context, settingsState)
        : _buildMaterialDialog(context, settingsState);
  }

  Widget _buildAppleForm(
    BuildContext context,
    MenuSettingsState settingsState,
  ) {
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
              children: [_buildAppleSizeSelector(settingsState)],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('AREA'),
              children: [_buildAppleAreaSelector(settingsState)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleSizeSelector(MenuSettingsState settingsState) {
    if (settingsState.isLoadingSizes && settingsState.sizes.isEmpty) {
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

    if (settingsState.errorMessage != null && settingsState.sizes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error loading sizes: ${settingsState.errorMessage}',
          style: TextStyle(color: CupertinoColors.destructiveRed),
        ),
      );
    }

    if (settingsState.sizes.isEmpty) {
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
              onPressed: widget.onOpenSizes == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      widget.onOpenSizes!();
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
          items: settingsState.sizes,
          currentValue: _selectedSize ?? settingsState.sizes.first,
          labelBuilder: (s) =>
              '${s.name} (${s.width.toInt()}x${s.height.toInt()} mm)',
          onSelected: (v) => setState(() => _selectedSize = v),
        );
      },
    );
  }

  Widget _buildAppleAreaSelector(MenuSettingsState settingsState) {
    if (settingsState.isLoadingAreas && settingsState.areas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CupertinoActivityIndicator(),
            SizedBox(width: 12),
            Flexible(child: Text('Loading areas...')),
          ],
        ),
      );
    }

    final areaLabel = _selectedArea?.name ?? 'None';

    return CupertinoListTile(
      title: const Text('Area'),
      additionalInfo: Text(areaLabel),
      trailing: const CupertinoListTileChevron(),
      onTap: () {
        final items = [const Area(id: 0, name: 'None'), ...settingsState.areas];
        showCupertinoPicker<Area>(
          context,
          items: items,
          currentValue: _selectedArea ?? items.first,
          labelBuilder: (a) => a.name,
          onSelected: (v) =>
              setState(() => _selectedArea = v.id == 0 ? null : v),
        );
      },
    );
  }

  Widget _buildMaterialDialog(
    BuildContext context,
    MenuSettingsState settingsState,
  ) {
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
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _versionController,
              decoration: const InputDecoration(
                labelText: 'Version',
                hintText: 'Enter template version (e.g. 1.0.0)',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _buildMaterialSizeDropdown(settingsState),
            const SizedBox(height: 16),
            _buildMaterialAreaDropdown(settingsState),
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

  Widget _buildMaterialSizeDropdown(MenuSettingsState settingsState) {
    if (settingsState.isLoadingSizes && settingsState.sizes.isEmpty) {
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

    if (settingsState.errorMessage != null && settingsState.sizes.isEmpty) {
      return Text(
        'Error loading sizes: ${settingsState.errorMessage}',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    if (settingsState.sizes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No page sizes available.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onOpenSizes == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    widget.onOpenSizes!();
                  },
            child: const Text('Manage Page Sizes'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<domain.Size>(
      initialValue: _selectedSize,
      decoration: const InputDecoration(labelText: 'Page Size'),
      items: settingsState.sizes.map((domain.Size size) {
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

  Widget _buildMaterialAreaDropdown(MenuSettingsState settingsState) {
    if (settingsState.isLoadingAreas && settingsState.areas.isEmpty) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading areas...'),
        ],
      );
    }

    return DropdownButtonFormField<Area?>(
      initialValue: _selectedArea,
      decoration: const InputDecoration(labelText: 'Area'),
      items: [
        const DropdownMenuItem<Area?>(value: null, child: Text('None')),
        ...settingsState.areas.map((area) {
          return DropdownMenuItem<Area?>(value: area, child: Text(area.name));
        }),
      ],
      onChanged: (area) {
        setState(() {
          _selectedArea = area;
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
      showThemedSnackBar(context, 'Please fill in all required fields');
      return;
    }

    final result = TemplateCreateResult(
      name: name,
      status: Status.draft,
      version: version,
      sizeId: _selectedSize!.id,
      areaId: _selectedArea?.id,
    );

    widget.onSave(result);
    Navigator.of(context).pop();
  }
}
