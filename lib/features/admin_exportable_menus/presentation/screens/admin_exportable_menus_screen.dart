import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/state/admin_exportable_menus_screen_state.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/view_models/admin_exportable_menus_view_model.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/widgets/menu_bundle_create_edit_dialog.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/shared/presentation/helpers/edit_dialog_helper.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_error_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';

/// MVVM-stack admin exportable-menus screen.
///
/// Pure widget — owns no Riverpod providers and no navigation. Reads its
/// snapshot from the injected [AdminExportableMenusViewModel] and forwards
/// user actions back to it. The Directus base URL used to compute the public
/// PDF link is passed in by the route page via [directusBaseUrl] so this
/// widget remains framework-agnostic.
class AdminExportableMenusScreen extends StatefulWidget {
  const AdminExportableMenusScreen({
    super.key,
    required this.viewModel,
    required this.directusBaseUrl,
  });

  final AdminExportableMenusViewModel viewModel;
  final String directusBaseUrl;

  @override
  State<AdminExportableMenusScreen> createState() =>
      _AdminExportableMenusScreenState();
}

class _AdminExportableMenusScreenState
    extends State<AdminExportableMenusScreen> {
  String? _lastSurfacedError;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
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

  String? _publicUrlFor(MenuBundle bundle) {
    if (bundle.pdfFileId == null) {
      return null;
    }
    return '${widget.directusBaseUrl}/assets/${bundle.pdfFileId}';
  }

  void _showCreateDialog() {
    final state = widget.viewModel.state;
    showEditDialog(
      context,
      MenuBundleCreateEditDialog(
        availableMenus: state.availableMenus,
        onSave: (result) async {
          final created = await widget.viewModel.createBundle(
            CreateMenuBundleInput(
              name: result.name,
              menuIds: result.menuIds,
            ),
          );
          if (created != null) {
            _publishInBackground(created.id);
          }
        },
      ),
    );
  }

  void _showEditDialog(MenuBundle bundle) {
    final state = widget.viewModel.state;
    showEditDialog(
      context,
      MenuBundleCreateEditDialog(
        existingBundle: bundle,
        availableMenus: state.availableMenus,
        onSave: (result) async {
          final updated = await widget.viewModel.updateBundle(
            UpdateMenuBundleInput(
              id: bundle.id,
              name: result.name,
              menuIds: result.menuIds,
            ),
          );
          if (updated != null) {
            _publishInBackground(updated.id);
          }
        },
      ),
    );
  }

  void _publishInBackground(int bundleId) {
    if (!mounted) {
      return;
    }
    showThemedSnackBar(context, 'Publishing bundle PDF...');
    widget.viewModel.publishBundle(bundleId).then((result) {
      if (!mounted) {
        return;
      }
      result.fold(
        onSuccess: (_) => showThemedSnackBar(context, 'Bundle PDF published'),
        onFailure: (_) {
          // The VM already surfaces errorMessage which the listener turns into
          // a SnackBar; nothing else to do here.
        },
      );
    });
  }

  Future<void> _confirmDelete(MenuBundle bundle) async {
    final confirmed = await showDeleteConfirmation(
      context,
      title: 'Delete Bundle',
      message:
          'Delete "${bundle.name}"? The published PDF will remain in Directus.',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await widget.viewModel.deleteBundle(bundle.id);
    if (!mounted) {
      return;
    }
    showThemedSnackBar(context, 'Bundle "${bundle.name}" deleted');
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    final isApple = isApplePlatform(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: widget.viewModel.goBack,
        ),
        title: const Text('Exportable Menus'),
        actions: <Widget>[
          IconButton(
            icon: Icon(isApple ? CupertinoIcons.add : Icons.add),
            onPressed: state.isAdmin ? _showCreateDialog : null,
            tooltip: 'Create Bundle',
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AdminExportableMenusScreenState state) {
    if (state.isLoading) {
      return const Center(child: AdaptiveLoadingIndicator());
    }
    if (state.errorMessage != null && state.bundles.isEmpty) {
      return AdaptiveErrorState(
        message: state.errorMessage!,
        onRetry: widget.viewModel.reload,
      );
    }
    if (state.bundles.isEmpty) {
      return EmptyState(
        icon: Icons.picture_as_pdf,
        title: 'No exportable menus',
        subtitle: 'Create a bundle to publish a combined PDF.',
        actionLabel: 'Create Bundle',
        onAction: state.isAdmin ? _showCreateDialog : null,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: state.bundles.length,
      itemBuilder: (context, index) {
        final bundle = state.bundles[index];
        return _BundleCard(
          bundle: bundle,
          publicUrl: _publicUrlFor(bundle),
          isPublishing: state.publishingBundleIds.contains(bundle.id),
          onEdit: () => _showEditDialog(bundle),
          onDelete: () => _confirmDelete(bundle),
        );
      },
    );
  }
}

class _BundleCard extends StatelessWidget {
  const _BundleCard({
    required this.bundle,
    required this.publicUrl,
    required this.isPublishing,
    required this.onEdit,
    required this.onDelete,
  });

  final MenuBundle bundle;
  final String? publicUrl;
  final bool isPublishing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple = isApplePlatform(context);
    final menuCount = bundle.menuIds.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(
          bundle.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Text('$menuCount menu${menuCount == 1 ? '' : 's'} included'),
            if (publicUrl != null) ...<Widget>[
              const SizedBox(height: 2),
              SelectableText(
                publicUrl!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ] else ...<Widget>[
              const SizedBox(height: 2),
              Text(
                'Not yet published — open an included menu and press the PDF '
                'preview button.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (isPublishing) ...<Widget>[
              const SizedBox(height: 6),
              Row(
                children: const <Widget>[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Publishing...'),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(isApple ? CupertinoIcons.pencil : Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(isApple ? CupertinoIcons.delete : Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete',
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
