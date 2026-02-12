import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/widgets/page_style_section.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/menu_display_options_dialog.dart';
import 'package:oxo_menus/presentation/widgets/widget_renderer.dart';

/// Data class for drag operations in the admin template editor
class _WidgetDragData {
  final String? newWidgetType;
  final WidgetInstance? existingWidget;
  final int? sourceColumnId;

  const _WidgetDragData.newWidget(String type)
    : newWidgetType = type,
      existingWidget = null,
      sourceColumnId = null;

  const _WidgetDragData.existing(WidgetInstance widget, int columnId)
    : newWidgetType = null,
      existingWidget = widget,
      sourceColumnId = columnId;

  bool get isNewWidget => newWidgetType != null;
  bool get isExistingWidget => existingWidget != null;
}

/// Admin Template Editor Page
///
/// Allows admin users to create and edit menu templates with pages, containers,
/// columns, and widgets.
class AdminTemplateEditorPage extends ConsumerStatefulWidget {
  final int menuId;

  const AdminTemplateEditorPage({super.key, required this.menuId});

  @override
  ConsumerState<AdminTemplateEditorPage> createState() =>
      _AdminTemplateEditorPageState();
}

class _AdminTemplateEditorPageState
    extends ConsumerState<AdminTemplateEditorPage> {
  Menu? _menu;
  entity.Page? _headerPage;
  entity.Page? _footerPage;
  List<entity.Page> _pages = [];
  final Map<int, List<entity.Container>> _containers = {};
  final Map<int, List<entity.Column>> _columns = {};
  final Map<int, List<WidgetInstance>> _widgets = {};
  bool _isLoading = true;
  String? _errorMessage;

  final Map<int, int> _hoverIndex = {};

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
    final menuResult = await ref
        .read(menuRepositoryProvider)
        .getById(widget.menuId);

    if (menuResult.isFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            menuResult.errorOrNull?.message ?? 'Failed to load menu';
      });
      return;
    }

    _menu = menuResult.valueOrNull!;

    // Load pages
    final pagesResult = await ref
        .read(pageRepositoryProvider)
        .getAllForMenu(widget.menuId);

    if (pagesResult.isFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            pagesResult.errorOrNull?.message ?? 'Failed to load pages';
      });
      return;
    }

    final allPages = List<entity.Page>.from(pagesResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));

    // Separate pages by type
    _headerPage = null;
    _footerPage = null;
    _pages = [];

    for (final page in allPages) {
      switch (page.type) {
        case entity.PageType.header:
          _headerPage = page;
          break;
        case entity.PageType.footer:
          _footerPage = page;
          break;
        case entity.PageType.content:
          _pages.add(page);
          break;
      }
    }

    // Load containers for each page
    _containers.clear();
    _columns.clear();
    _widgets.clear();

    for (final page in allPages) {
      final containersResult = await ref
          .read(containerRepositoryProvider)
          .getAllForPage(page.id);

      if (containersResult.isSuccess) {
        final containers = List<entity.Container>.from(
          containersResult.valueOrNull!,
        )..sort((a, b) => a.index.compareTo(b.index));
        _containers[page.id] = containers;

        // Load columns for each container
        for (final container in containers) {
          final columnsResult = await ref
              .read(columnRepositoryProvider)
              .getAllForContainer(container.id);

          if (columnsResult.isSuccess) {
            _columns[container.id] = List<entity.Column>.from(
              columnsResult.valueOrNull!,
            )..sort((a, b) => a.index.compareTo(b.index));

            // Load widgets for each column
            for (final column in _columns[container.id] ?? <entity.Column>[]) {
              final widgetsResult = await ref
                  .read(widgetRepositoryProvider)
                  .getAllForColumn(column.id);

              if (widgetsResult.isSuccess) {
                _widgets[column.id] = List<WidgetInstance>.from(
                  widgetsResult.valueOrNull!,
                )..sort((a, b) => a.index.compareTo(b.index));
              }
            }
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
    });

    // Set display options in provider
    ref.read(menuDisplayOptionsProvider.notifier).state = _menu?.displayOptions;
  }

  Future<void> _showDisplayOptionsDialog() async {
    showDialog(
      context: context,
      builder: (ctx) => MenuDisplayOptionsDialog(
        displayOptions: _menu?.displayOptions,
        onSave: (options) async {
          final result = await ref
              .read(menuRepositoryProvider)
              .update(
                UpdateMenuInput(id: widget.menuId, displayOptions: options),
              );
          if (result.isSuccess) {
            setState(() {
              _menu = _menu?.copyWith(displayOptions: options);
            });
            ref.read(menuDisplayOptionsProvider.notifier).state = options;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Display options saved')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _addPage() async {
    final result = await ref
        .read(pageRepositoryProvider)
        .create(
          CreatePageInput(
            menuId: widget.menuId,
            name: 'Page ${_pages.length + 1}',
            index: _pages.length,
          ),
        );

    if (result.isSuccess) {
      await _loadTemplate();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add page: ${result.errorOrNull?.message ?? 'Unknown error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePage(int pageId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    final result = await ref.read(pageRepositoryProvider).delete(pageId);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _addHeader() async {
    final result = await ref.read(pageRepositoryProvider).create(
          CreatePageInput(
            menuId: widget.menuId,
            name: 'Header',
            index: 0,
            type: entity.PageType.header,
          ),
        );

    if (result.isSuccess) {
      await _loadTemplate();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add header: ${result.errorOrNull?.message ?? 'Unknown error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteHeader() async {
    if (_headerPage == null) return;

    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    final result = await ref.read(pageRepositoryProvider).delete(_headerPage!.id);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _addFooter() async {
    final result = await ref.read(pageRepositoryProvider).create(
          CreatePageInput(
            menuId: widget.menuId,
            name: 'Footer',
            index: 0,
            type: entity.PageType.footer,
          ),
        );

    if (result.isSuccess) {
      await _loadTemplate();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add footer: ${result.errorOrNull?.message ?? 'Unknown error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFooter() async {
    if (_footerPage == null) return;

    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    final result = await ref.read(pageRepositoryProvider).delete(_footerPage!.id);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _addContainer(int pageId) async {
    final containers = _containers[pageId] ?? [];
    final result = await ref
        .read(containerRepositoryProvider)
        .create(
          CreateContainerInput(
            pageId: pageId,
            index: containers.length,
            direction: 'portrait',
          ),
        );

    if (result.isSuccess) {
      await _loadTemplate();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add container: ${result.errorOrNull?.message ?? 'Unknown error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteContainer(int containerId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    final result = await ref
        .read(containerRepositoryProvider)
        .delete(containerId);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _addColumn(int containerId) async {
    final columns = _columns[containerId] ?? [];
    final result = await ref
        .read(columnRepositoryProvider)
        .create(
          CreateColumnInput(
            containerId: containerId,
            index: columns.length,
            flex: 1,
          ),
        );

    if (result.isSuccess) {
      await _loadTemplate();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add column: ${result.errorOrNull?.message ?? 'Unknown error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteColumn(int columnId) async {
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

  void _onStyleChanged(StyleConfig newStyle) {
    setState(() {
      _menu = _menu?.copyWith(styleConfig: newStyle);
    });
  }

  Future<void> _onContainerStyleChanged(
    int containerId,
    StyleConfig newStyle,
  ) async {
    await ref
        .read(containerRepositoryProvider)
        .update(UpdateContainerInput(id: containerId, styleConfig: newStyle));
    // Update local state
    for (final entry in _containers.entries) {
      final idx = entry.value.indexWhere((c) => c.id == containerId);
      if (idx != -1) {
        setState(() {
          entry.value[idx] = entry.value[idx].copyWith(styleConfig: newStyle);
        });
        break;
      }
    }
  }

  Future<void> _onColumnStyleChanged(int columnId, StyleConfig newStyle) async {
    await ref
        .read(columnRepositoryProvider)
        .update(UpdateColumnInput(id: columnId, styleConfig: newStyle));
    // Update local state
    for (final entry in _columns.entries) {
      final idx = entry.value.indexWhere((c) => c.id == columnId);
      if (idx != -1) {
        setState(() {
          entry.value[idx] = entry.value[idx].copyWith(styleConfig: newStyle);
        });
        break;
      }
    }
  }

  Future<void> _saveTemplate() async {
    final result = await ref
        .read(menuRepositoryProvider)
        .update(
          UpdateMenuInput(id: widget.menuId, styleConfig: _menu?.styleConfig),
        );

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Template saved')));
    }
  }

  Future<void> _publishTemplate() async {
    final result = await ref
        .read(menuRepositoryProvider)
        .update(UpdateMenuInput(id: widget.menuId, status: Status.published));

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Template published')));
      await _loadTemplate();
    }
  }

  // ===== Widget CRUD =====

  Future<void> _handleWidgetDropAtIndex(
    String widgetType,
    int columnId,
    int index,
  ) async {
    try {
      final registry = ref.read(widgetRegistryProvider);
      final definition = registry.getDefinition(widgetType);
      if (definition == null) return;

      final propsJson =
          (definition.defaultProps as dynamic).toJson() as Map<String, dynamic>;

      final result = await ref
          .read(widgetRepositoryProvider)
          .create(
            CreateWidgetInput(
              columnId: columnId,
              type: widgetType,
              version: definition.version,
              index: index,
              props: propsJson,
              isTemplate: true,
            ),
          );

      if (result.isSuccess) {
        await _loadTemplate();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating widget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleWidgetUpdate(
    int widgetId,
    Map<String, dynamic> updatedProps,
  ) async {
    final result = await ref
        .read(widgetRepositoryProvider)
        .update(UpdateWidgetInput(id: widgetId, props: updatedProps));

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _handleWidgetDelete(int widgetId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    await _performWidgetDelete(widgetId);
  }

  Future<void> _performWidgetDelete(int widgetId) async {
    final result = await ref.read(widgetRepositoryProvider).delete(widgetId);

    if (result.isSuccess) {
      await _loadTemplate();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleWidgetMoveToIndex(
    WidgetInstance movedWidget,
    int sourceColumnId,
    int targetColumnId,
    int targetIndex,
  ) async {
    try {
      if (sourceColumnId == targetColumnId) {
        final adjustedIndex = targetIndex > movedWidget.index
            ? targetIndex - 1
            : targetIndex;

        final result = await ref
            .read(widgetRepositoryProvider)
            .reorder(movedWidget.id, adjustedIndex);

        if (result.isSuccess) {
          await _loadTemplate();
        }
      } else {
        final result = await ref
            .read(widgetRepositoryProvider)
            .moveTo(movedWidget.id, targetColumnId, targetIndex);

        if (result.isSuccess) {
          await _loadTemplate();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moving widget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isNoOpDrop(_WidgetDragData dragData, int columnId, int index) {
    if (!dragData.isExistingWidget) return false;
    if (dragData.sourceColumnId != columnId) return false;

    final currentIndex = dragData.existingWidget!.index;
    return index == currentIndex || index == currentIndex + 1;
  }

  // ===== Build Methods =====

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

    final registry = ref.watch(widgetRegistryProvider);

    return AuthenticatedScaffold(
      title: _menu?.name ?? 'Template Editor',
      actions: [
        IconButton(
          key: const Key('display_options_button'),
          onPressed: _showDisplayOptionsDialog,
          icon: const Icon(Icons.tune),
          tooltip: 'Display Options',
        ),
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
      body: Row(
        children: [
          // Left Panel: Widget Palette
          SizedBox(width: 200, child: _buildWidgetPalette(registry)),

          // Divider
          const VerticalDivider(width: 1),

          // Right Panel: Canvas
          Expanded(child: _buildCanvas()),
        ],
      ),
    );
  }

  Widget _buildWidgetPalette(WidgetRegistry registry) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Widget Palette',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView(
              children: registry.registeredTypes.map((type) {
                final definition = registry.getDefinition(type);
                return _buildPaletteItem(type, definition);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaletteItem(String type, WidgetDefinition? definition) {
    if (definition == null) return const SizedBox();

    return Draggable<_WidgetDragData>(
      data: _WidgetDragData.newWidget(type),
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _paletteItemContent(type),
      ),
      child: _paletteItemContent(type),
    );
  }

  Widget _paletteItemContent(String type) {
    return Container(
      key: Key('palette_item_$type'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(_getIconForType(type), size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'dish':
        return Icons.restaurant_menu;
      case 'image':
        return Icons.image;
      case 'section':
        return Icons.title;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.widgets;
    }
  }

  Widget _buildCanvas() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Style Section
            PageStyleSection(
              styleConfig: _menu?.styleConfig,
              onStyleChanged: _onStyleChanged,
            ),
            const SizedBox(height: 16),

            // Header Section
            if (_headerPage == null)
              ElevatedButton.icon(
                key: const Key('add_header_button'),
                onPressed: _addHeader,
                icon: const Icon(Icons.add),
                label: const Text('Add Header'),
              )
            else
              _buildPageCard(_headerPage!),
            const SizedBox(height: 16),

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

            // Footer Section
            const SizedBox(height: 16),
            if (_footerPage == null)
              ElevatedButton.icon(
                key: const Key('add_footer_button'),
                onPressed: _addFooter,
                icon: const Icon(Icons.add),
                label: const Text('Add Footer'),
              )
            else
              _buildPageCard(_footerPage!),
          ],
        ),
      ),
    );
  }

  Widget _buildPageCard(entity.Page page) {
    final containers = _containers[page.id] ?? [];
    final isHeader = page.type == entity.PageType.header;
    final isFooter = page.type == entity.PageType.footer;

    // Determine delete button key and action
    final String deleteKey;
    final VoidCallback deleteAction;

    if (isHeader) {
      deleteKey = 'delete_header_button';
      deleteAction = _deleteHeader;
    } else if (isFooter) {
      deleteKey = 'delete_footer_button';
      deleteAction = _deleteFooter;
    } else {
      deleteKey = 'delete_page_${page.id}';
      deleteAction = () => _deletePage(page.id);
    }

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
                  key: Key(deleteKey),
                  icon: const Icon(Icons.delete),
                  onPressed: deleteAction,
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

            // Container Style Section (collapsible)
            ExpansionTile(
              title: const Text('Container Style'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              children: [
                PageStyleSection(
                  title: 'Container Style',
                  styleConfig: container.styleConfig,
                  onStyleChanged: (newStyle) =>
                      _onContainerStyleChanged(container.id, newStyle),
                ),
              ],
            ),

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
                    .map(
                      (column) => Expanded(
                        flex: column.flex ?? 1,
                        child: _buildColumnCard(column),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnCard(entity.Column column) {
    final widgets = _widgets[column.id] ?? [];
    final registry = ref.watch(widgetRegistryProvider);
    final currentHoverIndex = _hoverIndex[column.id] ?? -1;

    return Container(
      key: Key('column_${column.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      constraints: const BoxConstraints(minHeight: 100),
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
          // Column Style Section (collapsible)
          ExpansionTile(
            title: const Text('Column Style'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            children: [
              PageStyleSection(
                title: 'Column Style',
                styleConfig: column.styleConfig,
                onStyleChanged: (newStyle) =>
                    _onColumnStyleChanged(column.id, newStyle),
              ),
            ],
          ),

          // Widget drop zones and widgets
          for (int i = 0; i <= widgets.length; i++) ...[
            _buildDropZone(column.id, i, currentHoverIndex == i, registry),
            if (i < widgets.length)
              _buildWidgetItem(widgets[i], column.id),
          ],

          // Empty state
          if (widgets.isEmpty && currentHoverIndex == -1)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Drop widgets here',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropZone(
    int columnId,
    int index,
    bool isHovering,
    WidgetRegistry registry,
  ) {
    return DragTarget<_WidgetDragData>(
      key: Key('drop_zone_${columnId}_$index'),
      onWillAcceptWithDetails: (details) {
        final dragData = details.data;
        if (dragData.isNewWidget) {
          return registry.getDefinition(dragData.newWidgetType!) != null;
        } else if (dragData.isExistingWidget) {
          return true;
        }
        return false;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _hoverIndex[columnId] = -1;
        });
        final dragData = details.data;

        if (_isNoOpDrop(dragData, columnId, index)) return;

        if (dragData.isNewWidget) {
          _handleWidgetDropAtIndex(dragData.newWidgetType!, columnId, index);
        } else if (dragData.isExistingWidget) {
          _handleWidgetMoveToIndex(
            dragData.existingWidget!,
            dragData.sourceColumnId!,
            columnId,
            index,
          );
        }
      },
      onMove: (details) {
        if (_hoverIndex[columnId] != index) {
          setState(() {
            _hoverIndex[columnId] = index;
          });
        }
      },
      onLeave: (data) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && _hoverIndex[columnId] == index) {
            setState(() {
              _hoverIndex[columnId] = -1;
            });
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        final showLine = isHovering && candidateData.isNotEmpty;
        final isNoOp =
            candidateData.isNotEmpty &&
            candidateData.first != null &&
            _isNoOpDrop(candidateData.first!, columnId, index);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: showLine ? 4 : 8,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: showLine
                ? (isNoOp ? Colors.grey[400] : Colors.blue)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildWidgetItem(WidgetInstance widgetInst, int columnId) {
    final widgetContent = Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: WidgetRenderer(
        widgetInstance: widgetInst,
        isEditable: true,
        onUpdate: (updatedProps) =>
            _handleWidgetUpdate(widgetInst.id, updatedProps),
        onDelete: () => _handleWidgetDelete(widgetInst.id),
      ),
    );

    return LongPressDraggable<_WidgetDragData>(
      key: Key('widget_${widgetInst.id}'),
      data: _WidgetDragData.existing(widgetInst, columnId),
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Text(
            widgetInst.type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: widgetContent),
      child: Dismissible(
        key: Key('dismissible_${widgetInst.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation();
        },
        onDismissed: (direction) {
          _performWidgetDelete(widgetInst.id);
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 8),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: widgetContent,
      ),
    );
  }
}
