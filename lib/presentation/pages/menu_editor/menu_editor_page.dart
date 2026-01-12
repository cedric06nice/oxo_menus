import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/widget_renderer.dart';

/// Menu Editor Page
///
/// Allows users to create and edit menus by:
/// - Selecting a template
/// - Dragging widgets from palette into columns
/// - Editing widget content
/// - Reordering widgets
/// - Saving the menu
class MenuEditorPage extends ConsumerStatefulWidget {
  final String menuId;

  const MenuEditorPage({
    super.key,
    required this.menuId,
  });

  @override
  ConsumerState<MenuEditorPage> createState() => _MenuEditorPageState();
}

class _MenuEditorPageState extends ConsumerState<MenuEditorPage> {
  Menu? _menu;
  List<entity.Page> _pages = [];
  final Map<String, List<entity.Container>> _containers = {};
  final Map<String, List<entity.Column>> _columns = {};
  final Map<String, List<WidgetInstance>> _widgets = {};
  bool _isLoading = true;
  String? _errorMessage;
  String? _draggedWidgetType; // For drag and drop from palette

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMenu();
    });
  }

  Future<void> _loadMenu() async {
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
    _widgets.clear();

    for (final page in _pages) {
      final containersResult =
          await ref.read(containerRepositoryProvider).getAllForPage(page.id);

      if (containersResult.isSuccess) {
        final containers =
            List<entity.Container>.from(containersResult.valueOrNull!)
              ..sort((a, b) => a.index.compareTo(b.index));
        _containers[page.id] = containers;

        // Load columns for each container
        for (final container in containers) {
          final columnsResult = await ref
              .read(columnRepositoryProvider)
              .getAllForContainer(container.id);

          if (columnsResult.isSuccess) {
            _columns[container.id] =
                List<entity.Column>.from(columnsResult.valueOrNull!)
                  ..sort((a, b) => a.index.compareTo(b.index));

            // Load widgets for each column
            for (final column
                in _columns[container.id] ?? <entity.Column>[]) {
              final widgetsResult = await ref
                  .read(widgetRepositoryProvider)
                  .getAllForColumn(column.id);

              if (widgetsResult.isSuccess) {
                _widgets[column.id] =
                    List<WidgetInstance>.from(widgetsResult.valueOrNull!)
                      ..sort((a, b) => a.index.compareTo(b.index));
              }
            }
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveMenu() async {
    final result = await ref.read(menuRepositoryProvider).update(
          UpdateMenuInput(
            id: widget.menuId,
            // Keep existing data for now
          ),
        );

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu saved')),
      );
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

    final registry = ref.watch(widgetRegistryProvider);

    return AuthenticatedScaffold(
      title: _menu?.name ?? 'Menu Editor',
      actions: [
        IconButton(
          key: const Key('save_menu_button'),
          icon: const Icon(Icons.save),
          onPressed: _saveMenu,
          tooltip: 'Save',
        ),
      ],
      body: Row(
        children: [
          // Left Panel: Widget Palette
          SizedBox(
            width: 200,
            child: _buildWidgetPalette(registry),
          ),

          // Divider
          const VerticalDivider(width: 1),

          // Right Panel: Canvas Preview
          Expanded(
            child: _buildCanvas(),
          ),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Widget Palette',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Widget list
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

    return Draggable<String>(
      data: type,
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
      onDragStarted: () {
        setState(() {
          _draggedWidgetType = type;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _draggedWidgetType = null;
        });
      },
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
          Icon(
            _getIconForType(type),
            size: 20,
            color: Colors.grey[700],
          ),
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
          children: _pages.map((page) => _buildPageCard(page)).toList(),
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
            Text(
              page.name,
              style: Theme.of(context).textTheme.titleLarge,
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
      color: Colors.grey[50],
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container Header
            if (container.name != null)
              Text(
                container.name!,
                style: Theme.of(context).textTheme.titleMedium,
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
    final widgets = _widgets[column.id] ?? [];
    final registry = ref.watch(widgetRegistryProvider);

    return DragTarget<String>(
      key: Key('drop_zone_${column.id}'),
      onWillAcceptWithDetails: (details) => _draggedWidgetType != null,
      onAcceptWithDetails: (details) {
        _handleWidgetDrop(details.data, column.id);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovering ? Colors.blue : Colors.grey[300]!,
              width: isHovering ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
            color: isHovering ? Colors.blue[50] : Colors.white,
          ),
          constraints: const BoxConstraints(minHeight: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column widgets
              ...widgets.map((widget) => _buildWidgetItem(widget, registry)),

              // Empty state
              if (widgets.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Drop widgets here',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWidgetItem(WidgetInstance widget, WidgetRegistry registry) {
    return Container(
      key: Key('widget_${widget.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: WidgetRenderer(
        widgetInstance: widget,
        isEditable: true,
        onUpdate: (updatedProps) => _handleWidgetUpdate(widget.id, updatedProps),
        onDelete: () => _handleWidgetDelete(widget.id),
      ),
    );
  }

  Future<void> _handleWidgetDrop(String widgetType, String columnId) async {
    final registry = ref.read(widgetRegistryProvider);
    final definition = registry.getDefinition(widgetType);
    if (definition == null) return;

    final widgets = _widgets[columnId] ?? [];
    final result = await ref.read(widgetRepositoryProvider).create(
          CreateWidgetInput(
            columnId: columnId,
            type: widgetType,
            version: definition.version,
            index: widgets.length,
            props: (definition.defaultProps as dynamic).toJson(),
          ),
        );

    if (result.isSuccess) {
      await _loadMenu();
    }
  }

  Future<void> _handleWidgetUpdate(
      String widgetId, Map<String, dynamic> updatedProps) async {
    final result = await ref.read(widgetRepositoryProvider).update(
          UpdateWidgetInput(
            id: widgetId,
            props: updatedProps,
          ),
        );

    if (result.isSuccess) {
      await _loadMenu();
    }
  }

  Future<void> _handleWidgetDelete(String widgetId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    final result = await ref.read(widgetRepositoryProvider).delete(widgetId);

    if (result.isSuccess) {
      await _loadMenu();
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this widget?'),
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
}
