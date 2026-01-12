import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';

/// Admin Template Editor Page
///
/// Allows admin users to create and edit menu templates with pages, containers, and columns.
class AdminTemplateEditorPage extends ConsumerStatefulWidget {
  final String menuId;

  const AdminTemplateEditorPage({
    super.key,
    required this.menuId,
  });

  @override
  ConsumerState<AdminTemplateEditorPage> createState() =>
      _AdminTemplateEditorPageState();
}

class _AdminTemplateEditorPageState
    extends ConsumerState<AdminTemplateEditorPage> {
  Menu? _menu;
  List<entity.Page> _pages = [];
  final Map<String, List<entity.Container>> _containers = {};
  final Map<String, List<entity.Column>> _columns = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTemplate();
    });
  }

  Future<void> _loadTemplate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Load menu
    final menuResult =
        await ref.read(menuRepositoryProvider).getById(widget.menuId);

    if (menuResult.isFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage = menuResult.errorOrNull?.message ?? 'Failed to load menu';
      });
      return;
    }

    _menu = menuResult.valueOrNull!;

    // Load pages
    final pagesResult =
        await ref.read(pageRepositoryProvider).getAllForMenu(widget.menuId);

    if (pagesResult.isFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            pagesResult.errorOrNull?.message ?? 'Failed to load pages';
      });
      return;
    }

    _pages = List<entity.Page>.from(pagesResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));

    // Load containers for each page
    _containers.clear();
    _columns.clear();

    for (final page in _pages) {
      final containersResult =
          await ref.read(containerRepositoryProvider).getAllForPage(page.id);

      if (containersResult.isSuccess) {
        final containers = List<entity.Container>.from(containersResult.valueOrNull!)
          ..sort((a, b) => a.index.compareTo(b.index));
        _containers[page.id] = containers;

        // Load columns for each container
        for (final container in containers) {
          final columnsResult = await ref
              .read(columnRepositoryProvider)
              .getAllForContainer(container.id);

          if (columnsResult.isSuccess) {
            _columns[container.id] = List<entity.Column>.from(columnsResult.valueOrNull!)
              ..sort((a, b) => a.index.compareTo(b.index));
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addPage() async {
    final result = await ref.read(pageRepositoryProvider).create(
          CreatePageInput(
            menuId: widget.menuId,
            name: 'Page ${_pages.length + 1}',
            index: _pages.length,
          ),
        );

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _deletePage(String pageId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    final result = await ref.read(pageRepositoryProvider).delete(pageId);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _addContainer(String pageId) async {
    final containers = _containers[pageId] ?? [];
    final result = await ref.read(containerRepositoryProvider).create(
          CreateContainerInput(
            pageId: pageId,
            index: containers.length,
          ),
        );

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _deleteContainer(String containerId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    final result =
        await ref.read(containerRepositoryProvider).delete(containerId);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _addColumn(String containerId) async {
    final columns = _columns[containerId] ?? [];
    final result = await ref.read(columnRepositoryProvider).create(
          CreateColumnInput(
            containerId: containerId,
            index: columns.length,
            flex: 1,
          ),
        );

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _deleteColumn(String columnId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    final result = await ref.read(columnRepositoryProvider).delete(columnId);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
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
  }

  Future<void> _saveTemplate() async {
    final result = await ref.read(menuRepositoryProvider).update(
          UpdateMenuInput(
            id: widget.menuId,
            // Keep existing data for now
          ),
        );

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template saved')),
      );
    }
  }

  Future<void> _publishTemplate() async {
    final result = await ref.read(menuRepositoryProvider).update(
          UpdateMenuInput(
            id: widget.menuId,
            status: MenuStatus.published,
          ),
        );

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template published')),
      );
      await _loadTemplate();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AuthenticatedScaffold(
        title: 'Loading...',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return AuthenticatedScaffold(
        title: 'Error',
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    return AuthenticatedScaffold(
      title: _menu?.name ?? 'Template Editor',
      actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _saveTemplate,
          tooltip: 'Save',
        ),
        IconButton(
          icon: const Icon(Icons.publish),
          onPressed: _publishTemplate,
          tooltip: 'Publish',
        ),
      ],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Page Button
              ElevatedButton.icon(
                key: const Key('add_page_button'),
                onPressed: _addPage,
                icon: const Icon(Icons.add),
                label: const Text('Add Page'),
              ),
              const SizedBox(height: 16),

              // Pages List
              ..._pages.map((page) => _buildPageCard(page)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(entity.Page page) {
    final containers = _containers[page.id] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    page.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  key: Key('delete_page_${page.id}'),
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePage(page.id),
                  tooltip: 'Delete Page',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Add Container Button
            ElevatedButton.icon(
              key: Key('add_container_${page.id}'),
              onPressed: () => _addContainer(page.id),
              icon: const Icon(Icons.add),
              label: const Text('Add Container'),
            ),
            const SizedBox(height: 8),

            // Containers
            ...containers.map((container) => _buildContainerCard(container)),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard(entity.Container container) {
    final columns = _columns[container.id] ?? [];

    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    container.name ?? 'Container',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: Key('delete_container_${container.id}'),
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteContainer(container.id),
                  tooltip: 'Delete Container',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Add Column Button
            ElevatedButton.icon(
              key: Key('add_column_${container.id}'),
              onPressed: () => _addColumn(container.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Column', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 8),

            // Columns
            if (columns.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns
                    .map((column) => Expanded(
                          flex: column.flex ?? 1,
                          child: _buildColumnCard(column),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnCard(entity.Column column) {
    return Container(
      key: Key('column_${column.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flex: ${column.flex ?? 1}',
                style: const TextStyle(fontSize: 11),
              ),
              IconButton(
                key: Key('delete_column_${column.id}'),
                icon: const Icon(Icons.delete, size: 16),
                onPressed: () => _deleteColumn(column.id),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: 'Delete Column',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 80,
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'Column Content',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
