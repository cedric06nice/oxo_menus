import 'package:flutter/cupertino.dart';
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
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/editor/auto_scroll_listener.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:oxo_menus/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_drop_zone.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/menu_display_options_dialog.dart';

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
  static const narrowBreakpoint = 600.0;

  Menu? _menu;
  List<entity.Page> _pages = [];
  final Map<int, List<entity.Container>> _containers = {};
  final Map<int, List<entity.Column>> _columns = {};
  final Map<int, List<WidgetInstance>> _widgets = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Track hover position for drag-and-drop: columnId -> hoverIndex (-1 = not hovering)
  final Map<int, int> _hoverIndex = {};

  final ScrollController _scrollController = ScrollController();

  late EditorWidgetCrudHelper _crudHelper;

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _crudHelper = EditorWidgetCrudHelper(
      widgetRepository: ref.read(widgetRepositoryProvider),
      widgetRegistry: ref.read(widgetRegistryProvider),
      onReload: _loadMenu,
      isTemplate: false,
      onMessage: (message, {bool isError = false}) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.red : null,
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMenu(isInitialLoad: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

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
      ..sort((a, b) => a.index.compareTo(b.index))
      ..removeWhere((page) => page.type != entity.PageType.content);

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

    // Set display options in provider
    ref.read(menuDisplayOptionsProvider.notifier).state = _menu?.displayOptions;
  }

  Future<void> _showPdf() async {
    context.push('/menus/pdf/${widget.menuId}');
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
      return AuthenticatedScaffold(
        title: 'Loading...',
        body: Center(
          child: _isApple
              ? const CupertinoActivityIndicator()
              : const CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return AuthenticatedScaffold(
        title: 'Error',
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    final registry = ref.watch(widgetRegistryProvider);
    final theme = Theme.of(context);

    return AuthenticatedScaffold(
      title: _menu?.name ?? 'Menu Editor',
      actions: [
        IconButton(
          key: const Key('display_options_button'),
          onPressed: _showDisplayOptionsDialog,
          icon: const Icon(Icons.tune),
          tooltip: 'Display Options',
        ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < narrowBreakpoint;

          if (isNarrow) {
            return Column(
              children: [
                WidgetPalette(
                  axis: Axis.horizontal,
                  registry: registry,
                  allowedWidgetTypes: _menu?.allowedWidgetTypes,
                ),
                Expanded(child: _buildCanvas()),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 260,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  border: Border(
                    right: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: WidgetPalette(
                  registry: registry,
                  allowedWidgetTypes: _menu?.allowedWidgetTypes,
                ),
              ),
              Expanded(child: _buildCanvas()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCanvas() {
    return AutoScrollListener(
      scrollController: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _pages.map((page) => _buildPageCard(page)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(entity.Page page) {
    final containers = _containers[page.id] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Containers
            ...containers.map((container) => _buildContainerCard(container)),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard(entity.Container container) {
    final columns = _columns[container.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildColumnCard(entity.Column column) {
    final widgets = _widgets[column.id] ?? [];
    final registry = ref.watch(widgetRegistryProvider);
    final currentHoverIndex = _hoverIndex[column.id] ?? -1;
    final theme = Theme.of(context);

    return Container(
      key: Key('column_${column.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
      constraints: const BoxConstraints(minHeight: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (column.isDroppable) ...[
            // Build interleaved list of drop zones and widgets
            for (int i = 0; i <= widgets.length; i++) ...[
              // Drop zone at position i
              EditorDropZone(
                columnId: column.id,
                index: i,
                isHovering: currentHoverIndex == i,
                registry: registry,
                onHoverIndexChanged: (index) {
                  setState(() {
                    _hoverIndex[column.id] = index;
                  });
                },
                onAccept: (dragData) {
                  if (dragData.isNewWidget) {
                    _handleWidgetDropAtIndex(
                      dragData.newWidgetType!,
                      column.id,
                      i,
                    );
                  } else if (dragData.isExistingWidget) {
                    _handleWidgetMoveToIndex(
                      dragData.existingWidget!,
                      dragData.sourceColumnId!,
                      column.id,
                      i,
                    );
                  }
                },
              ),

              // Widget at position i (if exists)
              if (i < widgets.length)
                DraggableWidgetItem(
                  widgetInstance: widgets[i],
                  columnId: column.id,
                  isEditable: !widgets[i].isTemplate,
                  isLocked: widgets[i].isTemplate,
                  onUpdate: (props) =>
                      _handleWidgetUpdate(widgets[i].id, props),
                  onDelete: () => _handleWidgetDelete(widgets[i].id),
                  onConfirmDismiss: () =>
                      showDeleteConfirmation(context, itemType: 'widget'),
                  onDismissed: (id) => _performWidgetDelete(id),
                ),
            ],

            // Empty state (only show when no widgets and not hovering)
            if (widgets.isEmpty && currentHoverIndex == -1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Drop widgets here',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ] else ...[
            // Non-droppable column: widgets only, no drop zones
            for (final widget in widgets)
              DraggableWidgetItem(
                widgetInstance: widget,
                columnId: column.id,
                isEditable: !widget.isTemplate,
                isLocked: widget.isTemplate,
                onUpdate: (props) => _handleWidgetUpdate(widget.id, props),
                onDelete: () => _handleWidgetDelete(widget.id),
                onConfirmDismiss: () =>
                    showDeleteConfirmation(context, itemType: 'widget'),
                onDismissed: (id) => _performWidgetDelete(id),
              ),

            // Empty state for locked column
            if (widgets.isEmpty)
              Center(
                child: Icon(
                  Icons.lock,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleWidgetDropAtIndex(
    String widgetType,
    int columnId,
    int index,
  ) async {
    final allowed = _menu?.allowedWidgetTypes;
    if (allowed != null &&
        allowed.isNotEmpty &&
        !allowed.contains(widgetType)) {
      return;
    }
    await _crudHelper.handleWidgetDropAtIndex(widgetType, columnId, index);
  }

  Future<void> _handleWidgetUpdate(
    int widgetId,
    Map<String, dynamic> updatedProps,
  ) async {
    await _crudHelper.handleWidgetUpdate(widgetId, updatedProps);
  }

  Future<void> _handleWidgetMoveToIndex(
    WidgetInstance widget,
    int sourceColumnId,
    int targetColumnId,
    int targetIndex,
  ) async {
    await _crudHelper.handleWidgetMoveToIndex(
      widget,
      sourceColumnId,
      targetColumnId,
      targetIndex,
    );
  }

  Future<void> _handleWidgetDelete(int widgetId) async {
    final confirmed = await showDeleteConfirmation(context, itemType: 'widget');
    if (confirmed != true) return;

    await _performWidgetDelete(widgetId);
  }

  Future<void> _performWidgetDelete(int widgetId) async {
    await _crudHelper.performWidgetDelete(widgetId);
  }
}
