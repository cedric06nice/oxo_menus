import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_state.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';

/// Page for creating a new admin template
///
/// Provides a full-page form for template creation,
/// supporting deep linking and bookmarking on web.
class AdminTemplateCreatorPage extends ConsumerStatefulWidget {
  const AdminTemplateCreatorPage({super.key});

  @override
  ConsumerState<AdminTemplateCreatorPage> createState() =>
      _AdminTemplateCreatorPageState();
}

class _AdminTemplateCreatorPageState
    extends ConsumerState<AdminTemplateCreatorPage> {
  late TextEditingController _nameController;
  late TextEditingController _versionController;

  domain.Size? _selectedSize;
  Area? _selectedArea;
  bool _isSaving = false;

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
    _listenForConnectivityRestore();
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

  void _listenForConnectivityRestore() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOnline = next.value == ConnectivityStatus.online;
      final settingsState = ref.read(menuSettingsProvider);
      if (wasOffline && isOnline && settingsState.errorMessage != null) {
        final notifier = ref.read(menuSettingsProvider.notifier);
        notifier.loadSizes();
        notifier.loadAreas();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty &&
        _versionController.text.trim().isNotEmpty &&
        _selectedSize != null &&
        !_isSaving;
  }

  Future<void> _handleCreate() async {
    if (!_canSave()) return;

    setState(() => _isSaving = true);

    final result = await ref
        .read(menuSettingsProvider.notifier)
        .createTemplate(
          name: _nameController.text.trim(),
          version: _versionController.text.trim(),
          status: Status.draft,
          sizeId: _selectedSize!.id,
          areaId: _selectedArea?.id,
        );

    if (!mounted) return;

    result.fold(
      onSuccess: (menu) {
        context.go(AppRoutes.adminTemplateEditor(menu.id));
      },
      onFailure: (error) {
        setState(() => _isSaving = false);
        showThemedSnackBar(
          context,
          'Failed to create template: ${error.message}',
          isError: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(menuSettingsProvider);

    return AuthenticatedScaffold(
      title: 'Create Template',
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
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
                  _buildSizeDropdown(settingsState),
                  const SizedBox(height: 16),
                  _buildAreaDropdown(settingsState),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _canSave() ? _handleCreate : null,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeDropdown(MenuSettingsState settingsState) {
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
            onPressed: () => context.push(AppRoutes.adminSizes),
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

  Widget _buildAreaDropdown(MenuSettingsState settingsState) {
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
}
