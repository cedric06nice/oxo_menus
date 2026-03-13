import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
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

  List<domain.Size> _sizes = [];
  domain.Size? _selectedSize;
  bool _isLoadingSizes = true;
  String? _sizeError;
  bool _isSaving = false;

  List<Area> _areas = [];
  Area? _selectedArea;
  bool _isLoadingAreas = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _versionController = TextEditingController(text: '1.0.0');
    _loadSizes();
    _loadAreas();
    _listenForConnectivityRestore();
  }

  void _listenForConnectivityRestore() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOnline = next.value == ConnectivityStatus.online;
      if (wasOffline && isOnline && _sizeError != null) {
        _loadSizes();
        _loadAreas();
      }
    });
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

  Future<void> _loadAreas() async {
    final areaRepository = ref.read(areaRepositoryProvider);
    final result = await areaRepository.getAll();

    if (!mounted) return;

    result.fold(
      onSuccess: (areas) {
        setState(() {
          _areas = areas;
          _isLoadingAreas = false;
        });
      },
      onFailure: (_) {
        setState(() {
          _isLoadingAreas = false;
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

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty &&
        _versionController.text.trim().isNotEmpty &&
        _selectedSize != null &&
        !_isSaving;
  }

  Future<void> _handleCreate() async {
    if (!_canSave()) return;

    setState(() => _isSaving = true);

    final input = CreateMenuInput(
      name: _nameController.text.trim(),
      version: _versionController.text.trim(),
      status: Status.draft,
      sizeId: _selectedSize!.id,
      areaId: _selectedArea?.id,
    );

    final result = await ref.read(menuRepositoryProvider).create(input);

    if (!mounted) return;

    result.fold(
      onSuccess: (menu) {
        context.go('/admin/templates/${menu.id}');
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
                  _buildSizeDropdown(),
                  const SizedBox(height: 16),
                  _buildAreaDropdown(),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No page sizes available.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/admin/sizes'),
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

  Widget _buildAreaDropdown() {
    if (_isLoadingAreas) {
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
        ..._areas.map((area) {
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
