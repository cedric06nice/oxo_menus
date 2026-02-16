import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/widgets/side_panel_style_editor.dart';
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/editor/delete_confirmation_dialog.dart';
import 'package:oxo_menus/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_drop_zone.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/menu_display_options_dialog.dart';

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

  late EditorWidgetCrudHelper _crudHelper;
  late EditorSelectionNotifier _selectionNotifier;
  EditorSelection? _currentSelection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _crudHelper = EditorWidgetCrudHelper(
      widgetRepository: ref.read(widgetRepositoryProvider),
      widgetRegistry: ref.read(widgetRegistryProvider),
      onReload: _loadTemplate,
      isTemplate: true,
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
    _selectionNotifier = EditorSelectionNotifier(
      saveMenuStyle: _saveMenuStyle,
      saveContainerStyle: _onContainerStyleChanged,
      saveColumnStyle: _onColumnStyleChanged,
      resolveStyle: _resolveStyle,
    );
    _selectionNotifier.addListener((state) {
      if (mounted) {
        setState(() {
          _currentSelection = state.selection;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTemplate();
    });
  }

  @override
  void dispose() {
    _selectionNotifier.dispose();
    super.dispose();
  }

  StyleConfig? _resolveStyle(EditorSelection selection) {
    switch (selection.type) {
      case EditorElementType.menu:
        return _menu?.styleConfig;
      case EditorElementType.container:
        for (final entry in _containers.entries) {
          for (final c in entry.value) {
            if (c.id == selection.id) return c.styleConfig;
          }
        }
        return null;
      case EditorElementType.column:
        for (final entry in _columns.entries) {
          for (final c in entry.value) {
            if (c.id == selection.id) return c.styleConfig;
          }
        }
        return null;
    }
  }

  Future<void> _saveMenuStyle(StyleConfig style) async {
    setState(() {
      _menu = _menu?.copyWith(styleConfig: style);
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
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;

    final result = await ref.read(pageRepositoryProvider).delete(pageId);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _addHeader() async {
    final result = await ref
        .read(pageRepositoryProvider)
        .create(
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

    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;

    final result = await ref
        .read(pageRepositoryProvider)
        .delete(_headerPage!.id);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  Future<void> _addFooter() async {
    final result = await ref
        .read(pageRepositoryProvider)
        .create(
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

    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;

    final result = await ref
        .read(pageRepositoryProvider)
        .delete(_footerPage!.id);

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
    final confirmed = await showDeleteConfirmation(context);
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
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;

    final result = await ref.read(columnRepositoryProvider).delete(columnId);

    if (result.isSuccess) {
      await _loadTemplate();
    }
  }

  void _onStyleChanged(StyleConfig newStyle) {
    setState(() {
      _menu = _menu?.copyWith(styleConfig: newStyle);
    });
    _selectionNotifier.updateStyle(newStyle);
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

  Future<void> _onColumnDroppableChanged(int columnId, bool isDroppable) async {
    await ref
        .read(columnRepositoryProvider)
        .update(UpdateColumnInput(id: columnId, isDroppable: isDroppable));
    // Update local state
    for (final entry in _columns.entries) {
      final idx = entry.value.indexWhere((c) => c.id == columnId);
      if (idx != -1) {
        setState(() {
          entry.value[idx] = entry.value[idx].copyWith(
            isDroppable: isDroppable,
          );
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

  // ===== Selection =====

  void _selectElement(EditorSelection selection) {
    final style = _resolveStyle(selection);
    _selectionNotifier.select(selection, style);
  }

  void _deselectElement() {
    _selectionNotifier.deselect();
  }

  void _onSidePanelStyleChanged(StyleConfig newStyle) {
    final sel = _currentSelection;
    if (sel == null) return;

    switch (sel.type) {
      case EditorElementType.menu:
        _onStyleChanged(newStyle);
      case EditorElementType.container:
        _onContainerStyleChanged(sel.id, newStyle);
        _selectionNotifier.updateStyle(newStyle);
      case EditorElementType.column:
        _onColumnStyleChanged(sel.id, newStyle);
        _selectionNotifier.updateStyle(newStyle);
    }
  }

  // ===== Widget CRUD =====

  Future<void> _handleWidgetDropAtIndex(
    String widgetType,
    int columnId,
    int index,
  ) async {
    await _crudHelper.handleWidgetDropAtIndex(widgetType, columnId, index);
  }

  Future<void> _handleWidgetUpdate(
    int widgetId,
    Map<String, dynamic> updatedProps,
  ) async {
    await _crudHelper.handleWidgetUpdate(widgetId, updatedProps);
  }

  Future<void> _handleWidgetDelete(int widgetId) async {
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;

    await _performWidgetDelete(widgetId);
  }

  Future<void> _performWidgetDelete(int widgetId) async {
    await _crudHelper.performWidgetDelete(widgetId);
  }

  Future<void> _handleWidgetMoveToIndex(
    WidgetInstance movedWidget,
    int sourceColumnId,
    int targetColumnId,
    int targetIndex,
  ) async {
    await _crudHelper.handleWidgetMoveToIndex(
      movedWidget,
      sourceColumnId,
      targetColumnId,
      targetIndex,
    );
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
          key: const Key('show_pdf_button'),
          onPressed: _showPdf,
          icon: const Icon(Icons.file_present),
          tooltip: 'Show PDF',
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
      body: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            _deselectElement();
          }
        },
        child: Row(
          children: [
            // Left Panel: Widget Palette + Side Panel Style Editor
            SizedBox(
              width: 240,
              child: Column(
                children: [
                  Expanded(child: WidgetPalette(registry: registry)),
                  if (_currentSelection != null) ...[
                    const Divider(height: 1),
                    Expanded(child: SingleChildScrollView(child: _buildSidePanel())),
                  ],
                ],
              ),
            ),

            // Divider
            const VerticalDivider(width: 1),

            // Right Panel: Canvas
            Expanded(child: _buildCanvas()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    final sel = _currentSelection;
    if (sel == null) return const SizedBox.shrink();

    final style = _resolveStyle(sel);
    bool? isDroppable;
    ValueChanged<bool>? onDroppableChanged;

    if (sel.type == EditorElementType.column) {
      // Find the column
      for (final entry in _columns.entries) {
        for (final col in entry.value) {
          if (col.id == sel.id) {
            isDroppable = col.isDroppable;
            onDroppableChanged = (value) =>
                _onColumnDroppableChanged(sel.id, value);
            break;
          }
        }
      }
    }

    return SidePanelStyleEditor(
      type: sel.type,
      styleConfig: style,
      clipboardStyle: _selectionNotifier.clipboardStyle,
      onCopy: () => _selectionNotifier.copyStyle(),
      onPaste: () {
        final pasted = _selectionNotifier.pasteStyle();
        if (pasted != null) {
          _onSidePanelStyleChanged(pasted);
        }
      },
      onStyleChanged: _onSidePanelStyleChanged,
      isDroppable: isDroppable,
      onDroppableChanged: onDroppableChanged,
    );
  }

  Widget _buildCanvas() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu Style Selector
            GestureDetector(
              key: const Key('selectable_menu'),
              onTap: () => _selectElement(
                const EditorSelection(type: EditorElementType.menu, id: 0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _currentSelection?.type == EditorElementType.menu
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.style, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Page Style',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
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
    final isSelected = _currentSelection?.type == EditorElementType.container &&
        _currentSelection?.id == container.id;

    return GestureDetector(
      key: Key('selectable_container_${container.id}'),
      onTap: () => _selectElement(
        EditorSelection(type: EditorElementType.container, id: container.id),
      ),
      child: Card(
        color: Colors.grey[100],
        margin: const EdgeInsets.only(top: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
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
                label:
                    const Text('Add Column', style: TextStyle(fontSize: 12)),
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
      ),
    );
  }

  Widget _buildColumnCard(entity.Column column) {
    final widgets = _widgets[column.id] ?? [];
    final registry = ref.watch(widgetRegistryProvider);
    final currentHoverIndex = _hoverIndex[column.id] ?? -1;
    final isSelected = _currentSelection?.type == EditorElementType.column &&
        _currentSelection?.id == column.id;

    return GestureDetector(
      key: Key('selectable_column_${column.id}'),
      onTap: () => _selectElement(
        EditorSelection(type: EditorElementType.column, id: column.id),
      ),
      child: Container(
        key: Key('column_${column.id}'),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
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

            // Widget drop zones and widgets
            for (int i = 0; i <= widgets.length; i++) ...[
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
              if (i < widgets.length)
                DraggableWidgetItem(
                  widgetInstance: widgets[i],
                  columnId: column.id,
                  isEditable: true,
                  isLocked: false,
                  onUpdate: (props) =>
                      _handleWidgetUpdate(widgets[i].id, props),
                  onDelete: () => _handleWidgetDelete(widgets[i].id),
                  onConfirmDismiss: () => showDeleteConfirmation(context),
                  onDismissed: (id) => _performWidgetDelete(id),
                ),
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
      ),
    );
  }
}
