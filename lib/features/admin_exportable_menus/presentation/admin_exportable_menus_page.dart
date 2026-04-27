import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/shared/presentation/helpers/edit_dialog_helper.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/admin_exportable_menus_provider.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/admin_exportable_menus_state.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/widgets/menu_bundle_create_edit_dialog.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_error_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/authenticated_scaffold.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';

/// Admin page for managing "Exportable menu bundles" — named bundles that
/// compose several existing menus into one watermarked public PDF.
class AdminExportableMenusPage extends ConsumerStatefulWidget {
  const AdminExportableMenusPage({super.key});

  @override
  ConsumerState<AdminExportableMenusPage> createState() =>
      _AdminExportableMenusPageState();
}

class _AdminExportableMenusPageState
    extends ConsumerState<AdminExportableMenusPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminExportableMenusProvider.notifier).load();
      _listenForConnectivityRestore();
    });
  }

  void _listenForConnectivityRestore() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOnline = next.value == ConnectivityStatus.online;
      if (wasOffline && isOnline) {
        ref.read(adminExportableMenusProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminExportableMenusProvider);

    return AuthenticatedScaffold(
      title: 'Exportable Menus',
      actions: [
        IconButton(
          icon: Icon(isApplePlatform(context) ? CupertinoIcons.add : Icons.add),
          onPressed: _showCreateDialog,
          tooltip: 'Create Bundle',
        ),
      ],
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AdminExportableMenusState state) {
    if (state.isLoading) {
      return const Center(child: AdaptiveLoadingIndicator());
    }
    if (state.errorMessage != null) {
      return AdaptiveErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(adminExportableMenusProvider.notifier).load(),
      );
    }
    if (state.bundles.isEmpty) {
      return EmptyState(
        icon: Icons.picture_as_pdf,
        title: 'No exportable menus',
        subtitle: 'Create a bundle to publish a combined PDF.',
        actionLabel: 'Create Bundle',
        onAction: _showCreateDialog,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: state.bundles.length,
      itemBuilder: (context, index) {
        final bundle = state.bundles[index];
        return _BundleCard(
          bundle: bundle,
          menuCount: bundle.menuIds.length,
          publicUrl: _publicUrlFor(bundle),
          onEdit: () => _showEditDialog(bundle),
          onDelete: () => _confirmDelete(bundle),
        );
      },
    );
  }

  String? _publicUrlFor(MenuBundle bundle) {
    if (bundle.pdfFileId == null) return null;
    final baseUrl = ref.read(directusBaseUrlProvider);
    return '$baseUrl/assets/${bundle.pdfFileId}';
  }

  void _showCreateDialog() {
    final availableMenus = ref
        .read(adminExportableMenusProvider)
        .availableMenus;
    showEditDialog(
      context,
      MenuBundleCreateEditDialog(
        availableMenus: availableMenus,
        onSave: (result) async {
          final created = await ref
              .read(adminExportableMenusProvider.notifier)
              .create(
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
    final availableMenus = ref
        .read(adminExportableMenusProvider)
        .availableMenus;
    showEditDialog(
      context,
      MenuBundleCreateEditDialog(
        existingBundle: bundle,
        availableMenus: availableMenus,
        onSave: (result) async {
          final updated = await ref
              .read(adminExportableMenusProvider.notifier)
              .update(
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

  /// Regenerate the bundle PDF after a save. Runs in background so the admin
  /// isn't blocked; outcome is surfaced via SnackBar.
  void _publishInBackground(int bundleId) {
    if (!mounted) return;
    showThemedSnackBar(context, 'Publishing bundle PDF...');
    unawaited(
      ref.read(adminExportableMenusProvider.notifier).publish(bundleId).then((
        result,
      ) {
        if (!mounted) return;
        result.fold(
          onSuccess: (_) => showThemedSnackBar(context, 'Bundle PDF published'),
          onFailure: (error) => showThemedSnackBar(
            context,
            'Failed to publish bundle PDF: ${error.message}',
            isError: true,
          ),
        );
      }),
    );
  }

  Future<void> _confirmDelete(MenuBundle bundle) async {
    final confirmed = await showDeleteConfirmation(
      context,
      title: 'Delete Bundle',
      message:
          'Delete "${bundle.name}"? The published PDF will remain in Directus.',
    );
    if (confirmed == true && mounted) {
      await ref.read(adminExportableMenusProvider.notifier).delete(bundle.id);
      if (mounted) {
        showThemedSnackBar(context, 'Bundle "${bundle.name}" deleted');
      }
    }
  }
}

class _BundleCard extends StatelessWidget {
  final MenuBundle bundle;
  final int menuCount;
  final String? publicUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BundleCard({
    required this.bundle,
    required this.menuCount,
    required this.publicUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple = isApplePlatform(context);

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
          children: [
            const SizedBox(height: 4),
            Text('$menuCount menu${menuCount == 1 ? '' : 's'} included'),
            if (publicUrl != null) ...[
              const SizedBox(height: 2),
              SelectableText(
                publicUrl!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ] else ...[
              const SizedBox(height: 2),
              Text(
                'Not yet published — open an included menu and press the PDF preview button.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
