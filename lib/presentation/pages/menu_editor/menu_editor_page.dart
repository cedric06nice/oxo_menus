import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

/// Data class for drag operations - represents either a new widget type or an existing widget
class _WidgetDragData {
  /// Widget type for new widgets from palette (null if dragging existing widget)
  final String? newWidgetType;

  /// Existing widget being dragged for reordering (null if dragging from palette)
  final WidgetInstance? existingWidget;

  /// Source column ID when dragging an existing widget
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

/// Menu Editor Page
///
/// Allows users to create and edit menus by:
/// - Selecting a template
/// - Dragging widgets from palette into columns
/// - Editing widget content
/// - Reordering widgets
/// - Saving the menu
class MenuEditorPage extends ConsumerStatefulWidget {
  final int menuId;

  const MenuEditorPage({super.key, required this.menuId});

  @override
  ConsumerState<MenuEditorPage> createState() => _MenuEditorPageState();
}

class _MenuEditorPageState extends ConsumerState<MenuEditorPage> {
  Menu? _menu;
  List<entity.Page> _pages = [];
  final Map<int, List<entity.Container>> _containers = {};
  final Map<int, List<entity.Column>> _columns = {};
  final Map<int, List<WidgetInstance>> _widgets = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Track hover position for drag-and-drop: columnId -> hoverIndex (-1 = not hovering)
  final Map<int, int> _hoverIndex = {};

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

    _pages = List<entity.Page>.from(pagesResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));

    // Load containers for each page
    _containers.clear();
    _columns.clear();
    _widgets.clear();

    for (final page in _pages) {
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
  }

  Future<void> _showPdf() async {
    context.push('/menus/pdf/${widget.menuId}');
  }

  Future<void> _saveMenu() async {
    final result = await ref
        .read(menuRepositoryProvider)
        .update(
          UpdateMenuInput(
            id: widget.menuId,
            // Keep existing data for now
          ),
        );

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menu saved')));
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
          key: const Key('show_pdf_button'),
          onPressed: _showPdf,
          icon: const Icon(Icons.file_present),
          tooltip: 'Show PDF',
        ),
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
          SizedBox(width: 200, child: _buildWidgetPalette(registry)),

          // Divider
          const VerticalDivider(width: 1),

          // Right Panel: Canvas Preview
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
            Text(page.name, style: Theme.of(context).textTheme.titleLarge),
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
          // Build interleaved list of drop zones and widgets
          for (int i = 0; i <= widgets.length; i++) ...[
            // Drop zone at position i
            _buildDropZone(column.id, i, currentHoverIndex == i, registry),

            // Widget at position i (if exists)
            if (i < widgets.length)
              _buildWidgetItem(widgets[i], column.id, registry),
          ],

          // Empty state (only show when no widgets and not hovering)
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

  /// Check if dropping at this position would be a no-op (widget already at this position)
  bool _isNoOpDrop(_WidgetDragData dragData, int columnId, int index) {
    if (!dragData.isExistingWidget) return false;
    if (dragData.sourceColumnId != columnId) return false;

    final currentIndex = dragData.existingWidget!.index;
    // Dropping at current position or the position right after is a no-op
    return index == currentIndex || index == currentIndex + 1;
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
          // Always accept to show the indicator, but check for no-op in onAccept
          return true;
        }
        return false;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _hoverIndex[columnId] = -1;
        });
        final dragData = details.data;

        // Skip no-op drops (widget already at this position)
        if (_isNoOpDrop(dragData, columnId, index)) {
          return;
        }

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
        // Small delay to prevent flickering when moving between zones
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
        // Show a muted color for no-op positions
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

  Widget _buildWidgetItem(
    WidgetInstance widget,
    int columnId,
    WidgetRegistry registry,
  ) {
    final widgetContent = Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: WidgetRenderer(
        widgetInstance: widget,
        isEditable: true,
        onUpdate: (updatedProps) =>
            _handleWidgetUpdate(widget.id, updatedProps),
        onDelete: () => _handleWidgetDelete(widget.id),
      ),
    );

    return LongPressDraggable<_WidgetDragData>(
      key: Key('widget_${widget.id}'),
      data: _WidgetDragData.existing(widget, columnId),
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
            widget.type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: widgetContent),
      child: Dismissible(
        key: Key('dismissible_${widget.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation();
        },
        onDismissed: (direction) {
          _performWidgetDelete(widget.id);
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

  Future<void> _handleWidgetDropAtIndex(
    String widgetType,
    int columnId,
    int index,
  ) async {
    try {
      final registry = ref.read(widgetRegistryProvider);
      final definition = registry.getDefinition(widgetType);
      if (definition == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unknown widget type: $widgetType')),
          );
        }
        return;
      }

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
            ),
          );

      if (result.isSuccess) {
        await _loadMenu();
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
      await _loadMenu();
    }
  }

  Future<void> _handleWidgetMoveToIndex(
    WidgetInstance widget,
    int sourceColumnId,
    int targetColumnId,
    int targetIndex,
  ) async {
    try {
      if (sourceColumnId == targetColumnId) {
        // Reordering within the same column
        // Adjust index if moving down (since removing the widget shifts indices)
        final adjustedIndex = targetIndex > widget.index
            ? targetIndex - 1
            : targetIndex;

        final result = await ref
            .read(widgetRepositoryProvider)
            .reorder(widget.id, adjustedIndex);

        if (result.isSuccess) {
          await _loadMenu();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to reorder widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Moving to a different column
        final result = await ref
            .read(widgetRepositoryProvider)
            .moveTo(widget.id, targetColumnId, targetIndex);

        if (result.isSuccess) {
          await _loadMenu();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to move widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
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

  Future<void> _handleWidgetDelete(int widgetId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    await _performWidgetDelete(widgetId);
  }

  Future<void> _performWidgetDelete(int widgetId) async {
    final result = await ref.read(widgetRepositoryProvider).delete(widgetId);

    if (result.isSuccess) {
      await _loadMenu();
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
