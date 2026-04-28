import 'package:flutter/material.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu_list/presentation/state/menu_list_state.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';
import 'package:oxo_menus/features/menu_list/presentation/widgets/menu_list_item.dart';
import 'package:oxo_menus/features/menu_list/presentation/widgets/template_create_dialog.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_error_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/status_filter_bar.dart';

/// Function used by [MenuListScreen] to display the create-template dialog.
///
/// Tests inject a fake opener that returns a canned [CreateMenuInput] so the
/// screen can be exercised without spinning up the (Riverpod-bound) legacy
/// [TemplateCreateDialog]. Production code uses [defaultCreateTemplateOpener].
///
/// The [onOpenSizes] callback is forwarded to the dialog so the "Manage Sizes"
/// CTA can navigate without the dialog itself depending on the router.
typedef CreateTemplateOpener =
    Future<CreateMenuInput?> Function(
      BuildContext context, {
      VoidCallback? onOpenSizes,
    });

/// Default production implementation: shows the legacy [TemplateCreateDialog]
/// inside the existing Riverpod scope and adapts its `onSave` callback into
/// the [CreateMenuInput] this screen expects.
Future<CreateMenuInput?> defaultCreateTemplateOpener(
  BuildContext context, {
  VoidCallback? onOpenSizes,
}) {
  final completer = _CreateTemplateCompleter();
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => TemplateCreateDialog(
      onSave: (result) {
        completer.complete(
          CreateMenuInput(
            name: result.name,
            version: result.version,
            status: result.status,
            sizeId: result.sizeId,
            areaId: result.areaId,
          ),
        );
      },
      onOpenSizes: onOpenSizes,
    ),
  ).then((_) => completer.value);
}

class _CreateTemplateCompleter {
  CreateMenuInput? value;

  void complete(CreateMenuInput input) {
    value ??= input;
  }
}

/// MVVM-stack menu-list screen.
///
/// Pure widget — owns no Riverpod providers and no navigation. Reads display
/// state from the injected [MenuListViewModel] and forwards user actions
/// back to it. The [openCreateTemplateDialog] indirection lets widget tests
/// bypass the legacy template-create dialog (which still depends on
/// Riverpod).
class MenuListScreen extends StatefulWidget {
  const MenuListScreen({
    super.key,
    required this.viewModel,
    this.openCreateTemplateDialog = defaultCreateTemplateOpener,
  });

  final MenuListViewModel viewModel;
  final CreateTemplateOpener openCreateTemplateDialog;

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
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
        title: const Text('Menus'),
        actions: state.isAdmin
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Create Menu',
                  onPressed: _handleCreateTemplate,
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

  Widget _buildBody(MenuListState state) {
    if (state.isLoading && state.menus.isEmpty) {
      return const Center(child: AdaptiveLoadingIndicator());
    }
    if (state.errorMessage != null && state.menus.isEmpty) {
      return _wrapInScrollable(
        AdaptiveErrorState(
          message: state.errorMessage!,
          onRetry: widget.viewModel.refresh,
        ),
      );
    }
    final filtered = _applyStatusFilter(state);
    if (filtered.isEmpty) {
      return _wrapInScrollable(
        const EmptyState(
          icon: Icons.restaurant_menu,
          title: 'No menus found',
          subtitle: 'Browse available menus or check back later',
        ),
      );
    }
    return _buildMenuList(state, filtered);
  }

  List<Menu> _applyStatusFilter(MenuListState state) {
    if (state.statusFilter == 'all') {
      return state.menus;
    }
    final wanted = Status.values.firstWhere(
      (s) => s.name == state.statusFilter,
      orElse: () => Status.draft,
    );
    return state.menus.where((m) => m.status == wanted).toList();
  }

  Widget _wrapInScrollable(Widget child) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[SliverFillRemaining(child: child)],
    );
  }

  Widget _buildMenuList(MenuListState state, List<Menu> filtered) {
    final grouped = <String, List<Menu>>{};
    for (final menu in filtered) {
      final key = menu.area?.name ?? 'Unassigned';
      grouped.putIfAbsent(key, () => <Menu>[]).add(menu);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Unassigned') {
          return 1;
        }
        if (b == 'Unassigned') {
          return -1;
        }
        return a.compareTo(b);
      });

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final key in sortedKeys) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(
                key,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final menu in grouped[key]!) ...<Widget>[
              MenuListItem(
                menu: menu,
                isAdmin: state.isAdmin,
                onTap: () => widget.viewModel.openMenu(menu.id),
                onEdit: state.isAdmin
                    ? () => widget.viewModel.openTemplateEditor(menu.id)
                    : null,
                onDuplicate: state.isAdmin
                    ? () => widget.viewModel.duplicateMenu(menu.id)
                    : null,
                onDelete: state.isAdmin ? () => _confirmDelete(menu) : null,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Menu menu) async {
    final confirmed = await showDeleteConfirmation(
      context,
      title: 'Delete Menu',
      message: 'Are you sure you want to delete "${menu.name}"?',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await widget.viewModel.deleteMenu(menu.id);
  }

  Future<void> _handleCreateTemplate() async {
    final input = await widget.openCreateTemplateDialog(
      context,
      onOpenSizes: widget.viewModel.pushAdminSizes,
    );
    if (input == null || !mounted) {
      return;
    }
    final created = await widget.viewModel.createTemplate(input);
    if (created == null || !mounted) {
      return;
    }
    widget.viewModel.openTemplateEditor(created.id);
  }
}
