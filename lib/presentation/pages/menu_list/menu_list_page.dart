import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
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
  @override
  void initState() {
    super.initState();
    // Load menus when page mounts
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu'),
        content: Text('Are you sure you want to delete "${menu.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuListProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return AuthenticatedScaffold(
      title: 'Menus',
      actions: isAdmin
          ? [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _handleCreateTemplate,
              ),
            ]
          : null,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(state, isAdmin),
      ),
    );
  }

  Widget _buildBody(MenuListState state, bool isAdmin) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(child: Text('Error: ${state.errorMessage}'));
    }

    if (state.menus.isEmpty) {
      return const Center(child: Text('No menus found'));
    }

    return ListView.builder(
      itemCount: state.menus.length,
      itemBuilder: (context, index) {
        final menu = state.menus[index];
        return MenuListItem(
          menu: menu,
          isAdmin: isAdmin,
          onTap: () => _handleMenuTap(menu),
          onEdit: isAdmin ? () => _editTemplate(menu) : null,
          onDelete: isAdmin ? () => _confirmDelete(menu) : null,
        );
      },
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
