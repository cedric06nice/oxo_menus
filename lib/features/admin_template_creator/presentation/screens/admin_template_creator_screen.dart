import 'package:flutter/material.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/state/admin_template_creator_screen_state.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/view_models/admin_template_creator_view_model.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';

/// MVVM-stack admin template-creator screen.
///
/// Pure widget — owns no Riverpod providers and no navigation. Reads the form
/// snapshot from the injected [AdminTemplateCreatorViewModel] and forwards
/// user actions back to it. The free-text fields (name, version) are owned
/// here as `TextEditingController`s; their values are passed to the VM only
/// at submit time.
class AdminTemplateCreatorScreen extends StatefulWidget {
  const AdminTemplateCreatorScreen({super.key, required this.viewModel});

  final AdminTemplateCreatorViewModel viewModel;

  @override
  State<AdminTemplateCreatorScreen> createState() =>
      _AdminTemplateCreatorScreenState();
}

class _AdminTemplateCreatorScreenState
    extends State<AdminTemplateCreatorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _versionController;
  String? _lastSurfacedError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _versionController = TextEditingController(text: '1.0.0');
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    _nameController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) {
      return;
    }
    final next = widget.viewModel.state.errorMessage;
    if (next != null && next != _lastSurfacedError) {
      _lastSurfacedError = next;
      showThemedSnackBar(context, next, isError: true);
    } else if (next == null) {
      _lastSurfacedError = null;
    }
    setState(() {});
  }

  bool _canSave(AdminTemplateCreatorScreenState state) {
    return _nameController.text.trim().isNotEmpty &&
        _versionController.text.trim().isNotEmpty &&
        state.selectedSize != null &&
        !state.isSaving;
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    final version = _versionController.text.trim();
    if (name.isEmpty || version.isEmpty) {
      return;
    }
    await widget.viewModel.createTemplate(name: name, version: version);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Template'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: widget.viewModel.goBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
                  _buildSizeField(state),
                  const SizedBox(height: 16),
                  _buildAreaField(state),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: state.isSaving
                            ? null
                            : widget.viewModel.goBack,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _canSave(state) ? _handleCreate : null,
                        child: state.isSaving
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

  Widget _buildSizeField(AdminTemplateCreatorScreenState state) {
    if (state.isLoadingSizes && state.sizes.isEmpty) {
      return const Row(
        children: <Widget>[
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
    if (state.sizes.isEmpty) {
      final theme = Theme.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No page sizes available.',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.viewModel.openAdminSizes,
            child: const Text('Manage Page Sizes'),
          ),
        ],
      );
    }
    return DropdownButtonFormField<domain.Size>(
      initialValue: state.selectedSize,
      decoration: const InputDecoration(labelText: 'Page Size'),
      items: state.sizes.map((domain.Size size) {
        return DropdownMenuItem<domain.Size>(
          value: size,
          child: Text(
            '${size.name} (${size.width.toInt()}x${size.height.toInt()} mm)',
          ),
        );
      }).toList(),
      onChanged: state.isSaving
          ? null
          : (size) => widget.viewModel.setSelectedSize(size),
    );
  }

  Widget _buildAreaField(AdminTemplateCreatorScreenState state) {
    if (state.isLoadingAreas && state.areas.isEmpty) {
      return const Row(
        children: <Widget>[
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
      initialValue: state.selectedArea,
      decoration: const InputDecoration(labelText: 'Area'),
      items: <DropdownMenuItem<Area?>>[
        const DropdownMenuItem<Area?>(value: null, child: Text('None')),
        for (final area in state.areas)
          DropdownMenuItem<Area?>(value: area, child: Text(area.name)),
      ],
      onChanged: state.isSaving
          ? null
          : (area) => widget.viewModel.setSelectedArea(area),
    );
  }
}
