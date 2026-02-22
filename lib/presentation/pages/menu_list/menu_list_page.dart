import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/pages/home/home_helpers.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_list_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/menu_list_item.dart';
import 'package:oxo_menus/presentation/widgets/template_create_dialog.dart';

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

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMenus();
    });
  }

  void _loadMenus() {
    final isAdmin = ref.read(isAdminProvider);
    ref.read(menuListProvider.notifier).loadMenus(onlyPublished: !isAdmin);
  }

  Future<void> _handleRefresh() async {
    final isAdmin = ref.read(isAdminProvider);
    await ref.read(menuListProvider.notifier).refresh(onlyPublished: !isAdmin);
  }

  Future<void> _confirmDelete(Menu menu) async {
    final bool? confirmed;

    if (_isApple) {
      confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Delete Menu'),
          content: Text('Are you sure you want to delete "${menu.name}"?'),
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
          title: const Text('Delete Menu'),
          content: Text('Are you sure you want to delete "${menu.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    if (confirmed == true && mounted) {
      await ref.read(menuListProvider.notifier).deleteMenu(menu.id);
    }
  }

  void _handleMenuTap(Menu menu) {
    context.push('/menus/${menu.id}');
  }

  void _editTemplate(Menu menu) {
    context.push('/admin/templates/${menu.id}');
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
          );

          final createdMenu = await ref
              .read(menuListProvider.notifier)
              .createMenu(input);

          if (createdMenu != null && mounted) {
            context.push('/admin/templates/${createdMenu.id}');
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu duplicated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to duplicate menu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuListProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isApple = _isApple;

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
    final filters = ['all', 'draft', 'published', 'archived'];
    final labels = ['All', 'Draft', 'Published', 'Archived'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (i) {
            return Padding(
              padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
              child: ChoiceChip(
                label: Text(labels[i]),
                selected: _statusFilter == filters[i],
                onSelected: (_) {
                  setState(() {
                    _statusFilter = filters[i];
                  });
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBody(MenuListState state, bool isAdmin) {
    if (state.isLoading) {
      return Center(
        child: _isApple
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      );
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
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isApple
                      ? CupertinoIcons.exclamationmark_triangle
                      : Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('Error: $message'),
                const SizedBox(height: 16),
                if (_isApple)
                  CupertinoButton.filled(
                    onPressed: _loadMenus,
                    child: const Text('Retry'),
                  )
                else
                  FilledButton(
                    onPressed: _loadMenus,
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isApple ? CupertinoIcons.doc_text : Icons.restaurant_menu,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                const Text('No menus found'),
                const SizedBox(height: 8),
                Text(
                  'Browse available menus or check back later',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(List<Menu> menus, bool isAdmin) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = computeGridColumns(constraints.maxWidth);
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: menus.map((menu) {
                  return MenuListItem(
                    menu: menu,
                    isAdmin: isAdmin,
                    onTap: () => _handleMenuTap(menu),
                    onEdit: isAdmin ? () => _editTemplate(menu) : null,
                    onDuplicate: isAdmin ? () => _handleDuplicate(menu) : null,
                    onDelete: isAdmin ? () => _confirmDelete(menu) : null,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Result from the template create dialog
class TemplateCreateResult {
  final String name;
  final Status status;
  final String version;
  final int sizeId;

  const TemplateCreateResult({
    required this.name,
    required this.status,
    required this.version,
    required this.sizeId,
  });
}
