import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';

/// Admin templates page for managing menu templates
///
/// Features:
/// - List all templates with name, status, version
/// - Filter by status (all, draft, published, archived)
/// - Create new template button
/// - Edit/delete template actions
/// - Admin-only access (enforced by router)
class AdminTemplatesPage extends ConsumerStatefulWidget {
  const AdminTemplatesPage({super.key});

  @override
  ConsumerState<AdminTemplatesPage> createState() =>
      _AdminTemplatesPageState();
}

class _AdminTemplatesPageState extends ConsumerState<AdminTemplatesPage> {
  @override
  void initState() {
    super.initState();
    // Load templates on mount
    Future.microtask(() {
      ref.read(adminTemplatesProvider.notifier).loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTemplatesProvider);

    return AuthenticatedScaffold(
      title: 'Templates',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => context.push('/admin/templates/create'),
          tooltip: 'Create Template',
        ),
      ],
      body: Column(
        children: [
          // Status filter buttons
          _buildStatusFilters(),

          // Templates list
          Expanded(
            child: _buildTemplatesList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final state = ref.watch(adminTemplatesProvider);

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
    ref.read(adminTemplatesProvider.notifier).loadTemplates(
          statusFilter: status,
        );
  }

  Widget _buildTemplatesList(dynamic state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(adminTemplatesProvider.notifier).loadTemplates();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No templates found'),
            const SizedBox(height: 8),
            Text(
              'Create your first template to get started',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/admin/templates/create'),
              child: const Text('Create Template'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: state.templates.length,
      itemBuilder: (context, index) {
        final template = state.templates[index];
        return _TemplateCard(
          template: template,
          onEdit: () => context.push('/admin/templates/${template.id}'),
          onDelete: () => _confirmDelete(template),
        );
      },
    );
  }

  Future<void> _confirmDelete(Menu template) async {
    final confirmed = await showDialog<bool>(
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
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(adminTemplatesProvider.notifier)
          .deleteTemplate(template.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "${template.name}" deleted'),
          ),
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

class _TemplateCard extends StatelessWidget {
  final Menu template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TemplateCard({
    required this.template,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _StatusBadge(status: template.status),
                const SizedBox(width: 8),
                Text('v${template.version}'),
              ],
            ),
            if (template.dateUpdated != null) ...[
              const SizedBox(height: 4),
              Text(
                'Updated: ${_formatDate(template.dateUpdated!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final Status status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case Status.draft:
        color = Colors.orange;
        icon = Icons.edit;
        break;
      case Status.published:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case Status.archived:
        color = Colors.grey;
        icon = Icons.archive;
        break;
    }

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      avatar: Icon(icon, size: 16, color: color),
      backgroundColor: color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
    );
  }
}
