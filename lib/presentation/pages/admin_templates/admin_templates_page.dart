import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/widgets/template_card.dart';
import 'package:oxo_menus/presentation/pages/home/home_helpers.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/empty_state.dart';

class AdminTemplatesPage extends ConsumerStatefulWidget {
  const AdminTemplatesPage({super.key});

  @override
  ConsumerState<AdminTemplatesPage> createState() => _AdminTemplatesPageState();
}

class _AdminTemplatesPageState extends ConsumerState<AdminTemplatesPage> {
  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminTemplatesProvider.notifier).loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTemplatesProvider);
    final isApple = _isApple;

    return AuthenticatedScaffold(
      title: 'Templates',
      actions: [
        if (isApple)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: () => context.push('/admin/templates/create'),
            child: const Icon(CupertinoIcons.add),
          )
        else
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/templates/create'),
            tooltip: 'Create Template',
          ),
      ],
      body: Column(
        children: [
          _buildStatusFilters(),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final state = ref.watch(adminTemplatesProvider);
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
                selected: state.statusFilter == filters[i],
                onSelected: (_) => _filterByStatus(filters[i]),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _filterByStatus(String status) {
    ref
        .read(adminTemplatesProvider.notifier)
        .loadTemplates(statusFilter: status);
  }

  Widget _buildBody(dynamic state) {
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

    if (state.templates.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTemplatesGrid(state.templates);
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);

    return Center(
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
              onPressed: () {
                ref.read(adminTemplatesProvider.notifier).loadTemplates();
              },
              child: const Text('Retry'),
            )
          else
            FilledButton(
              onPressed: () {
                ref.read(adminTemplatesProvider.notifier).loadTemplates();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: _isApple ? CupertinoIcons.doc_text : Icons.restaurant_menu,
      title: 'No templates found',
      subtitle: 'Create your first template to get started',
      actionLabel: 'Create Template',
      onAction: () => context.push('/admin/templates/create'),
    );
  }

  Widget _buildTemplatesGrid(List<Menu> templates) {
    return SingleChildScrollView(
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
                children: templates.map((template) {
                  return TemplateCard(
                    template: template,
                    onTap: () =>
                        context.push('/admin/templates/${template.id}'),
                    onEdit: () =>
                        context.push('/admin/templates/${template.id}'),
                    onDelete: () => _confirmDelete(template),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Menu template) async {
    final bool? confirmed;

    if (_isApple) {
      confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Delete Template'),
          content: Text(
            'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
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
          title: const Text('Delete Template'),
          content: Text(
            'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
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
      await ref
          .read(adminTemplatesProvider.notifier)
          .deleteTemplate(template.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template "${template.name}" deleted')),
        );
      }
    }
  }
}
