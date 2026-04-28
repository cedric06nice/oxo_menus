import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/core/di/app_scope.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/features/menu_list/presentation/widgets/template_create_dialog_controller.dart';
import 'package:oxo_menus/shared/data/repositories/area_repository_impl.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/repositories/area_repository.dart';
import 'package:oxo_menus/shared/presentation/helpers/cupertino_picker_helper.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
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

class TemplateCreateDialog extends StatefulWidget {
  final void Function(TemplateCreateResult) onSave;

  /// Invoked when the user taps the "Manage Sizes" CTA shown when no sizes
  /// exist yet. The screen wires this through `MenuListRouter.pushAdminSizes`
  /// so the user can return to the dialog with back navigation.
  final VoidCallback? onOpenSizes;

  /// Optional injection points for tests — production wiring builds these
  /// from the surrounding [AppScope].
  final SizeRepository? sizeRepository;
  final AreaRepository? areaRepository;

  const TemplateCreateDialog({
    super.key,
    required this.onSave,
    this.onOpenSizes,
    this.sizeRepository,
    this.areaRepository,
  });

  @override
  State<TemplateCreateDialog> createState() => _TemplateCreateDialogState();
}

class _TemplateCreateDialogState extends State<TemplateCreateDialog> {
  late TextEditingController _nameController;
  late TextEditingController _versionController;
  late TemplateCreateDialogController _settingsController;

  domain.Size? _selectedSize;
  Area? _selectedArea;
  bool _settingsBound = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _versionController = TextEditingController(text: '1.0.0');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_settingsBound) {
      _settingsController = TemplateCreateDialogController(
        sizeRepository: widget.sizeRepository ?? _resolveSizeRepository(),
        areaRepository: widget.areaRepository ?? _resolveAreaRepository(),
      );
      _settingsController.addListener(_onSettingsChanged);
      _settingsBound = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _settingsController.loadSizes();
        _settingsController.loadAreas();
      });
    }
  }

  SizeRepository _resolveSizeRepository() {
    final dataSource = AppScope.read(context).container.directusDataSource;
    return SizeRepositoryImpl(dataSource: dataSource);
  }

  AreaRepository _resolveAreaRepository() {
    final dataSource = AppScope.read(context).container.directusDataSource;
    return AreaRepositoryImpl(dataSource: dataSource);
  }

  void _onSettingsChanged() {
    if (!mounted) {
      return;
    }
    final state = _settingsController.state;
    if (_selectedSize == null && state.sizes.isNotEmpty) {
      setState(() => _selectedSize = state.sizes.first);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _settingsController
      ..removeListener(_onSettingsChanged)
      ..dispose();
    _nameController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = _settingsController.state;

    return isApplePlatform(context)
        ? _buildAppleForm(context, settingsState)
        : _buildMaterialDialog(context, settingsState);
  }

  Widget _buildAppleForm(
    BuildContext context,
    TemplateCreateDialogState settingsState,
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

  Widget _buildAppleSizeSelector(TemplateCreateDialogState settingsState) {
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

  Widget _buildAppleAreaSelector(TemplateCreateDialogState settingsState) {
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
    TemplateCreateDialogState settingsState,
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

  Widget _buildMaterialSizeDropdown(TemplateCreateDialogState settingsState) {
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

  Widget _buildMaterialAreaDropdown(TemplateCreateDialogState settingsState) {
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
