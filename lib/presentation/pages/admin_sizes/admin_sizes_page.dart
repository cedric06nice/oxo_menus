import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/helpers/status_helpers.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_error_state.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_loading_indicator.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/empty_state.dart';
import 'package:oxo_menus/presentation/widgets/common/status_filter_bar.dart';
import 'package:oxo_menus/presentation/widgets/common/status_badge.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/widgets/size_create_edit_dialog.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

/// Admin page for managing page sizes
class AdminSizesPage extends ConsumerStatefulWidget {
  const AdminSizesPage({super.key});

  @override
  ConsumerState<AdminSizesPage> createState() => _AdminSizesPageState();
}

class _AdminSizesPageState extends ConsumerState<AdminSizesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminSizesProvider.notifier).loadSizes();
      _listenForConnectivityRestore();
    });
  }

  void _listenForConnectivityRestore() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOnline = next.value == ConnectivityStatus.online;
      if (wasOffline && isOnline) {
        ref.read(adminSizesProvider.notifier).loadSizes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSizesProvider);

    return AuthenticatedScaffold(
      title: 'Page Sizes',
      actions: [
        IconButton(
          icon: Icon(isApplePlatform(context) ? CupertinoIcons.add : Icons.add),
          onPressed: _showCreateDialog,
          tooltip: 'Create Page Size',
        ),
      ],
      body: Column(
        children: [
          _buildStatusFilters(),
          Expanded(child: _buildSizesList(state)),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final state = ref.watch(adminSizesProvider);
    return StatusFilterBar(
      selectedFilter: state.statusFilter,
      onFilterChanged: (status) =>
          ref.read(adminSizesProvider.notifier).loadSizes(statusFilter: status),
    );
  }

  Widget _buildSizesList(dynamic state) {
    if (state.isLoading) {
      return const Center(child: AdaptiveLoadingIndicator());
    }

    if (state.errorMessage != null) {
      return AdaptiveErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(adminSizesProvider.notifier).loadSizes(),
      );
    }

    if (state.sizes.isEmpty) {
      return EmptyState(
        icon: Icons.straighten,
        title: 'No page sizes found',
        subtitle: 'Create your first page size',
        actionLabel: 'Create Page Size',
        onAction: _showCreateDialog,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: state.sizes.length,
      itemBuilder: (context, index) {
        final size = state.sizes[index] as domain.Size;
        return _SizeCard(
          size: size,
          onEdit: () => _showEditDialog(size),
          onDelete: () => _confirmDelete(size),
        );
      },
    );
  }

  void _showCreateDialog() {
    showEditDialog(
      context,
      SizeCreateEditDialog(
        onSave: (result) {
          ref
              .read(adminSizesProvider.notifier)
              .createSize(
                CreateSizeInput(
                  name: result.name,
                  width: result.width,
                  height: result.height,
                  status: result.status,
                  direction: result.direction,
                ),
              );
        },
      ),
    );
  }

  void _showEditDialog(domain.Size size) {
    showEditDialog(
      context,
      SizeCreateEditDialog(
        existingSize: size,
        onSave: (result) {
          ref
              .read(adminSizesProvider.notifier)
              .updateSize(
                UpdateSizeInput(
                  id: size.id,
                  name: result.name,
                  width: result.width,
                  height: result.height,
                  status: result.status,
                  direction: result.direction,
                ),
              );
        },
      ),
    );
  }

  Future<void> _confirmDelete(domain.Size size) async {
    final confirmed = await showDeleteConfirmation(
      context,
      title: 'Delete Page Size',
      message:
          'Are you sure you want to delete "${size.name}"? This action cannot be undone.',
    );

    if (confirmed == true && mounted) {
      await ref.read(adminSizesProvider.notifier).deleteSize(size.id);

      if (mounted) {
        showThemedSnackBar(context, 'Page size "${size.name}" deleted');
      }
    }
  }
}

class _SizeCard extends StatelessWidget {
  final domain.Size size;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SizeCard({
    required this.size,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isApple = isApplePlatform(context);
    final accentColor = statusColor(size.status, colorScheme);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accentColor),
            Expanded(
              child: ListTile(
                title: Text(
                  size.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusBadge(status: size.status),
                        const SizedBox(width: 8),
                        Text(
                          '${size.width.toStringAsFixed(size.width.truncateToDouble() == size.width ? 0 : 1)} x '
                          '${size.height.toStringAsFixed(size.height.truncateToDouble() == size.height ? 0 : 1)} mm',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      size.direction == 'portrait' ? 'Portrait' : 'Landscape',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
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
                      icon: Icon(
                        isApple ? CupertinoIcons.delete : Icons.delete,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                      color: colorScheme.error,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
