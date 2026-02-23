import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/helpers/status_helpers.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/empty_state.dart';
import 'package:oxo_menus/presentation/widgets/common/status_badge.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/widgets/size_create_edit_dialog.dart';

/// Admin page for managing page sizes
class AdminSizesPage extends ConsumerStatefulWidget {
  const AdminSizesPage({super.key});

  @override
  ConsumerState<AdminSizesPage> createState() => _AdminSizesPageState();
}

class _AdminSizesPageState extends ConsumerState<AdminSizesPage> {
  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminSizesProvider.notifier).loadSizes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSizesProvider);

    return AuthenticatedScaffold(
      title: 'Page Sizes',
      actions: [
        IconButton(
          icon: Icon(_isApple ? CupertinoIcons.add : Icons.add),
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

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: state.statusFilter == 'all',
              onSelected: () => _filterByStatus('all'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Draft',
              isSelected: state.statusFilter == 'draft',
              onSelected: () => _filterByStatus('draft'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Published',
              isSelected: state.statusFilter == 'published',
              onSelected: () => _filterByStatus('published'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Archived',
              isSelected: state.statusFilter == 'archived',
              onSelected: () => _filterByStatus('archived'),
            ),
          ],
        ),
      ),
    );
  }

  void _filterByStatus(String status) {
    ref.read(adminSizesProvider.notifier).loadSizes(statusFilter: status);
  }

  Widget _buildSizesList(dynamic state) {
    if (state.isLoading) {
      return Center(
        child: _isApple
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isApple
                  ? CupertinoIcons.exclamationmark_circle
                  : Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            if (_isApple)
              CupertinoButton.filled(
                onPressed: () {
                  ref.read(adminSizesProvider.notifier).loadSizes();
                },
                child: const Text('Retry'),
              )
            else
              FilledButton(
                onPressed: () {
                  ref.read(adminSizesProvider.notifier).loadSizes();
                },
                child: const Text('Retry'),
              ),
          ],
        ),
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
    final dialog = SizeCreateEditDialog(
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
    );

    if (_isApple) {
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => dialog,
        ),
      );
    } else {
      showDialog(context: context, builder: (_) => dialog);
    }
  }

  void _showEditDialog(domain.Size size) {
    final dialog = SizeCreateEditDialog(
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
    );

    if (_isApple) {
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => dialog,
        ),
      );
    } else {
      showDialog(context: context, builder: (_) => dialog);
    }
  }

  Future<void> _confirmDelete(domain.Size size) async {
    final bool? confirmed;
    if (_isApple) {
      confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Delete Page Size'),
          content: Text(
            'Are you sure you want to delete "${size.name}"? This action cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete Page Size'),
          content: Text(
            'Are you sure you want to delete "${size.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    if (confirmed == true && mounted) {
      await ref.read(adminSizesProvider.notifier).deleteSize(size.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Page size "${size.name}" deleted')),
        );
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
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
    final isApple =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;
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
