import 'package:flutter/material.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/state/admin_sizes_screen_state.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/view_models/admin_sizes_view_model.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/widgets/size_create_edit_dialog.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/presentation/helpers/edit_dialog_helper.dart';
import 'package:oxo_menus/shared/presentation/helpers/status_helpers.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_error_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/status_badge.dart';
import 'package:oxo_menus/shared/presentation/widgets/status_filter_bar.dart';

/// MVVM-stack admin sizes screen.
///
/// Pure widget — owns no Riverpod providers and no navigation. Reads display
/// state from the injected [AdminSizesViewModel] and forwards user actions
/// back to it.
class AdminSizesScreen extends StatefulWidget {
  const AdminSizesScreen({super.key, required this.viewModel});

  final AdminSizesViewModel viewModel;

  @override
  State<AdminSizesScreen> createState() => _AdminSizesScreenState();
}

class _AdminSizesScreenState extends State<AdminSizesScreen> {
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Sizes'),
        actions: state.isAdmin
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Create Page Size',
                  onPressed: _showCreateDialog,
                ),
              ]
            : null,
      ),
      body: Column(
        children: <Widget>[
          if (state.isAdmin)
            StatusFilterBar(
              selectedFilter: state.statusFilter,
              onFilterChanged: widget.viewModel.setStatusFilter,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.viewModel.refresh,
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminSizesScreenState state) {
    if (state.isLoading && state.sizes.isEmpty) {
      return const Center(child: AdaptiveLoadingIndicator());
    }
    if (state.errorMessage != null && state.sizes.isEmpty) {
      return _wrapInScrollable(
        AdaptiveErrorState(
          message: state.errorMessage!,
          onRetry: widget.viewModel.refresh,
        ),
      );
    }
    if (state.sizes.isEmpty) {
      return _wrapInScrollable(
        EmptyState(
          icon: Icons.straighten,
          title: 'No page sizes found',
          subtitle: 'Create your first page size',
          actionLabel: 'Create Page Size',
          onAction: _showCreateDialog,
        ),
      );
    }
    return _buildList(state.sizes);
  }

  Widget _wrapInScrollable(Widget child) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[SliverFillRemaining(child: child)],
    );
  }

  Widget _buildList(List<domain.Size> sizes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sizes.length,
      itemBuilder: (context, index) {
        final size = sizes[index];
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
          widget.viewModel.createSize(
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
          widget.viewModel.updateSize(
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
          'Are you sure you want to delete "${size.name}"? This action '
          'cannot be undone.',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await widget.viewModel.deleteSize(size.id);
  }
}

class _SizeCard extends StatelessWidget {
  const _SizeCard({
    required this.size,
    required this.onEdit,
    required this.onDelete,
  });

  final domain.Size size;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = statusColor(size.status, colorScheme);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        StatusBadge(status: size.status),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatMm(size.width)} x '
                          '${_formatMm(size.height)} mm',
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
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      color: colorScheme.error,
                      onPressed: onDelete,
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

  String _formatMm(double value) {
    return value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}
