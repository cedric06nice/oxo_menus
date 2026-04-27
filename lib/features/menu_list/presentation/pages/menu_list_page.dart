import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/features/menu_list/presentation/providers/menu_list_provider.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_error_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/authenticated_scaffold.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/status_filter_bar.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:oxo_menus/features/menu_list/presentation/widgets/menu_list_item.dart';
import 'package:oxo_menus/features/menu_list/presentation/widgets/template_create_dialog.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Menu list page
///
/// Displays a list of menus with filtering based on user role.
/// Admin users can see all menus and create/delete menus.
/// Regular users can only see published menus.
class MenuListPage extends ConsumerStatefulWidget {
  const MenuListPage({super.key});

  @override
  ConsumerState<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends ConsumerState<MenuListPage> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tryLoadMenus()) {
        // User not available yet — listen for auth changes
        ref.listenManual(currentUserProvider, (_, user) {
          if (user != null) {
            _tryLoadMenus();
          }
        });
      }
      _listenForConnectivityRestore();
    });
  }

  void _listenForConnectivityRestore() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOnline = next.value == ConnectivityStatus.online;
      if (wasOffline && isOnline) {
        _tryLoadMenus();
      }
    });
  }

  List<int>? _getAreaIdsForCurrentUser() {
    final isAdmin = ref.read(isAdminProvider);
    if (isAdmin) return null;
    final user = ref.read(currentUserProvider);
    if (user == null) return null;
    return user.areas.map((a) => a.id).toList();
  }

  /// Attempts to load menus. Returns false if user is not yet available.
  bool _tryLoadMenus() {
    final isAdmin = ref.read(isAdminProvider);
    final areaIds = _getAreaIdsForCurrentUser();
    if (!isAdmin && areaIds == null) return false;
    ref
        .read(menuListProvider.notifier)
        .loadMenus(onlyPublished: !isAdmin, areaIds: areaIds);
    return true;
  }

  Future<void> _handleRefresh() async {
    final isAdmin = ref.read(isAdminProvider);
    await ref
        .read(menuListProvider.notifier)
        .refresh(onlyPublished: !isAdmin, areaIds: _getAreaIdsForCurrentUser());
  }

  Future<void> _confirmDelete(Menu menu) async {
    final confirmed = await showDeleteConfirmation(
      context,
      title: 'Delete Menu',
      message: 'Are you sure you want to delete "${menu.name}"?',
    );

    if (confirmed == true && mounted) {
      await ref.read(menuListProvider.notifier).deleteMenu(menu.id);
    }
  }

  void _handleMenuTap(Menu menu) {
    // Phase 12 retired the legacy /menus/:id route — the menu editor lives on
    // the MVVM stack at /app/menus/{id}/edit.
    context.go('/app/menus/${menu.id}/edit');
  }

  void _editTemplate(Menu menu) {
    context.push(AppRoutes.adminTemplateEditor(menu.id));
  }

  void _handleCreateTemplate() {
    showDialog<TemplateCreateResult>(
      context: context,
      builder: (dialogContext) => TemplateCreateDialog(
        onSave: (result) async {
          final input = CreateMenuInput(
            name: result.name,
            version: result.version,
            status: result.status,
            sizeId: result.sizeId,
            areaId: result.areaId,
          );

          final createdMenu = await ref
              .read(menuListProvider.notifier)
              .createMenu(input);

          if (createdMenu != null && mounted) {
            context.push(AppRoutes.adminTemplateEditor(createdMenu.id));
          }
        },
      ),
    );
  }

  Future<void> _handleDuplicate(Menu menu) async {
    final duplicatedMenu = await ref
        .read(menuListProvider.notifier)
        .duplicateMenu(menu.id);

    if (mounted) {
      if (duplicatedMenu != null) {
        showThemedSnackBar(context, 'Menu duplicated successfully');
      } else {
        showThemedSnackBar(context, 'Failed to duplicate menu', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuListProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isApple = isApplePlatform(context);

    return AuthenticatedScaffold(
      title: 'Menus',
      actions: isAdmin
          ? [
              if (isApple)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onPressed: _handleCreateTemplate,
                  child: const Icon(CupertinoIcons.add),
                )
              else
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _handleCreateTemplate,
                  tooltip: 'Create Menu',
                ),
            ]
          : null,
      body: Column(
        children: [
          if (isAdmin) _buildStatusFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _buildBody(state, isAdmin),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    return StatusFilterBar(
      selectedFilter: _statusFilter,
      onFilterChanged: (filter) => setState(() => _statusFilter = filter),
    );
  }

  Widget _buildBody(MenuListState state, bool isAdmin) {
    if (state.isLoading) {
      return const Center(child: AdaptiveLoadingIndicator());
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    final filteredMenus = _applyStatusFilter(state.menus);

    if (filteredMenus.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMenuGrid(filteredMenus, isAdmin);
  }

  List<Menu> _applyStatusFilter(List<Menu> menus) {
    if (_statusFilter == 'all') return menus;
    return menus.where((menu) {
      return menu.status ==
          Status.values.firstWhere(
            (s) => s.name == _statusFilter,
            orElse: () => Status.draft,
          );
    }).toList();
  }

  Widget _buildErrorState(String message) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: AdaptiveErrorState(
            message: message,
            onRetry: () => _tryLoadMenus(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: EmptyState(
            icon: isApplePlatform(context)
                ? CupertinoIcons.doc_text
                : Icons.restaurant_menu,
            title: 'No menus found',
            subtitle: 'Browse available menus or check back later',
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(List<Menu> menus, bool isAdmin) {
    // Group menus by area
    final grouped = <String, List<Menu>>{};
    for (final menu in menus) {
      final key = menu.area?.name ?? 'Unassigned';
      grouped.putIfAbsent(key, () => []).add(menu);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Unassigned') return 1;
        if (b == 'Unassigned') return -1;
        return a.compareTo(b);
      });

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final key in sortedKeys) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(
                key,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final menu in grouped[key]!) ...[
              MenuListItem(
                menu: menu,
                isAdmin: isAdmin,
                onTap: () => _handleMenuTap(menu),
                onEdit: isAdmin ? () => _editTemplate(menu) : null,
                onDuplicate: isAdmin ? () => _handleDuplicate(menu) : null,
                onDelete: isAdmin ? () => _confirmDelete(menu) : null,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}
