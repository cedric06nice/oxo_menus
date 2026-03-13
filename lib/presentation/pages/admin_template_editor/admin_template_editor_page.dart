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
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/widgets/side_panel_style_editor.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_loading_indicator.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/editor/area_dialog_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/page_size_dialog_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/auto_scroll_listener.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:oxo_menus/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_column_card.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_structure_crud_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_style_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_mixin.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/editor/display_options_dialog_helper.dart';

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
    extends ConsumerState<AdminTemplateEditorPage>
    with EditorWidgetCrudMixin {
  static const narrowBreakpoint = 600.0;

  Menu? _menu;
  entity.Page? _headerPage;
  entity.Page? _footerPage;
  List<entity.Page> _pages = [];
  final Map<int, List<entity.Container>> _containers = {};
  final Map<int, List<entity.Column>> _columns = {};
  final Map<int, List<WidgetInstance>> _widgets = {};
  bool _isLoading = true;
  bool _isNarrow = false;
  String? _errorMessage;

  final Map<int, int> _hoverIndex = {};

  @override
  late EditorWidgetCrudHelper crudHelper;
  late EditorStructureCrudHelper _structureHelper;
  late EditorStyleHelper _styleHelper;
  late EditorSelectionNotifier _selectionNotifier;
  EditorSelection? _currentSelection;

  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    void showMessage(String message, {bool isError = false}) {
      if (mounted) {
        showThemedSnackBar(context, message, isError: isError);
      }
    }

    crudHelper = EditorWidgetCrudHelper(
      widgetRepository: ref.read(widgetRepositoryProvider),
      widgetRegistry: ref.read(widgetRegistryProvider),
      onReload: _loadTemplate,
      isTemplate: true,
      onMessage: showMessage,
    );
    _structureHelper = EditorStructureCrudHelper(
      pageRepository: ref.read(pageRepositoryProvider),
      containerRepository: ref.read(containerRepositoryProvider),
      columnRepository: ref.read(columnRepositoryProvider),
      onReload: _loadTemplate,
      onMessage: showMessage,
      showDeleteConfirmation: () async =>
          await showDeleteConfirmation(context) == true,
    );
    _styleHelper = EditorStyleHelper(
      containerRepository: ref.read(containerRepositoryProvider),
      columnRepository: ref.read(columnRepositoryProvider),
      containers: _containers,
      columns: _columns,
      onLocalStateChanged: () => setState(() {}),
      isMounted: () => mounted,
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
      _loadTemplate(isInitialLoad: true);
      _listenForConnectivityRestore();
    });
  }

  void _listenForConnectivityRestore() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOnline = next.value == ConnectivityStatus.online;
      if (wasOffline && isOnline && _errorMessage != null) {
        _loadTemplate(isInitialLoad: true);
      }
    });
  }

  @override
  void dispose() {
    _styleHelper.dispose();
    _scrollController.dispose();
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

  Future<void> _loadTemplate({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final loader = EditorTreeLoader(
      menuRepository: ref.read(menuRepositoryProvider),
      pageRepository: ref.read(pageRepositoryProvider),
      containerRepository: ref.read(containerRepositoryProvider),
      columnRepository: ref.read(columnRepositoryProvider),
      widgetRepository: ref.read(widgetRepositoryProvider),
    );

    final result = await loader.loadTree(widget.menuId);

    if (result.isFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.errorOrNull?.message ?? 'Failed to load template';
      });
      return;
    }

    final tree = result.valueOrNull!;
    _menu = tree.menu;

    // Separate pages by type
    _headerPage = null;
    _footerPage = null;
    _pages = [];

    for (final page in tree.pages) {
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

    _containers
      ..clear()
      ..addAll(tree.containers);
    _columns
      ..clear()
      ..addAll(tree.columns);
    _widgets
      ..clear()
      ..addAll(tree.widgets);

    setState(() {
      _isLoading = false;
    });

    // Set display options in provider
    ref.read(menuDisplayOptionsProvider.notifier).state = _menu?.displayOptions;
  }

  Future<void> _showPdf() async {
    context.push('/menus/pdf/${widget.menuId}');
  }

  void _showDisplayOptionsDialog() {
    showDisplayOptionsDialog(
      context: context,
      ref: ref,
      menuId: widget.menuId,
      menu: _menu,
      onMenuUpdated: (updatedMenu) {
        setState(() {
          _menu = updatedMenu;
        });
      },
    );
  }

  Future<void> _showPageSizeDialog() => showPageSizeDialog(
    context: context,
    ref: ref,
    menuId: widget.menuId,
    currentPageSize: _menu?.pageSize,
    onPageSizeUpdated: (pageSize) {
      setState(() {
        _menu = _menu?.copyWith(pageSize: pageSize);
      });
    },
  );

  Future<void> _showAreaDialog() => showAreaDialog(
    context: context,
    ref: ref,
    menuId: widget.menuId,
    onAreaUpdated: (area) {
      setState(() {
        _menu = _menu?.copyWith(area: area);
      });
    },
  );

  Future<void> _addPage() =>
      _structureHelper.addPage(menuId: widget.menuId, pageCount: _pages.length);

  Future<void> _deletePage(int pageId) => _structureHelper.deletePage(pageId);

  Future<void> _addHeader() => _structureHelper.addHeader(widget.menuId);

  Future<void> _deleteHeader() async {
    if (_headerPage == null) return;
    await _structureHelper.deleteHeader(_headerPage!.id);
  }

  Future<void> _addFooter() => _structureHelper.addFooter(widget.menuId);

  Future<void> _deleteFooter() async {
    if (_footerPage == null) return;
    await _structureHelper.deleteFooter(_footerPage!.id);
  }

  Future<void> _addContainer(int pageId) => _structureHelper.addContainer(
    pageId: pageId,
    containerCount: (_containers[pageId] ?? []).length,
  );

  Future<void> _deleteContainer(int containerId) =>
      _structureHelper.deleteContainer(containerId);

  Future<void> _addColumn(int containerId) => _structureHelper.addColumn(
    containerId: containerId,
    columnCount: (_columns[containerId] ?? []).length,
  );

  Future<void> _deleteColumn(int columnId) =>
      _structureHelper.deleteColumn(columnId);

  void _onStyleChanged(StyleConfig newStyle) {
    setState(() {
      _menu = _menu?.copyWith(styleConfig: newStyle);
    });
    _selectionNotifier.updateStyle(newStyle);
  }

  Future<void> _onContainerStyleChanged(
    int containerId,
    StyleConfig newStyle,
  ) => _styleHelper.onContainerStyleChanged(containerId, newStyle);

  Future<void> _onColumnStyleChanged(int columnId, StyleConfig newStyle) =>
      _styleHelper.onColumnStyleChanged(columnId, newStyle);

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

  Future<void> _onAllowedWidgetTypesChanged(List<String> newTypes) async {
    final result = await ref
        .read(menuRepositoryProvider)
        .update(
          UpdateMenuInput(id: widget.menuId, allowedWidgetTypes: newTypes),
        );
    if (result.isSuccess) {
      setState(() {
        _menu = _menu?.copyWith(allowedWidgetTypes: newTypes);
      });
    }
  }

  Future<void> _saveTemplate() async {
    final result = await ref
        .read(menuRepositoryProvider)
        .update(
          UpdateMenuInput(id: widget.menuId, styleConfig: _menu?.styleConfig),
        );

    if (result.isSuccess && mounted) {
      showThemedSnackBar(context, 'Template saved');
    }
  }

  Future<void> _publishTemplate() async {
    final result = await ref
        .read(menuRepositoryProvider)
        .update(UpdateMenuInput(id: widget.menuId, status: Status.published));

    if (result.isSuccess && mounted) {
      showThemedSnackBar(context, 'Template published');
      await _loadTemplate();
    }
  }

  // ===== Selection =====

  void _selectElement(EditorSelection selection) {
    _styleHelper.flushStyleDebounce();
    final style = _resolveStyle(selection);
    _selectionNotifier.select(selection, style);

    if (_isNarrow) {
      _showStyleEditorBottomSheet();
    }
  }

  void _showStyleEditorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: _buildSidePanel(),
        ),
      ),
    ).whenComplete(() {
      _deselectElement();
    });
  }

  void _deselectElement() {
    _styleHelper.flushStyleDebounce();
    _selectionNotifier.deselect();
  }

  void _onSidePanelStyleChanged(StyleConfig newStyle) {
    final sel = _currentSelection;
    if (sel == null) return;

    switch (sel.type) {
      case EditorElementType.menu:
        _onStyleChanged(newStyle);
      case EditorElementType.container:
        _styleHelper.updateContainerStyleLocally(sel.id, newStyle);
        _selectionNotifier.updateStyle(newStyle);
        _styleHelper.debounceStyleSave(
          () => _styleHelper.saveContainerStyleToApi(sel.id, newStyle),
        );
      case EditorElementType.column:
        _styleHelper.updateColumnStyleLocally(sel.id, newStyle);
        _selectionNotifier.updateStyle(newStyle);
        _styleHelper.debounceStyleSave(
          () => _styleHelper.saveColumnStyleToApi(sel.id, newStyle),
        );
    }
  }

  // ===== Widget CRUD =====

  Future<void> _handleWidgetDropAtIndex(
    String widgetType,
    int columnId,
    int index,
  ) async {
    await crudHelper.handleWidgetDropAtIndex(widgetType, columnId, index);
  }

  Future<void> _handleWidgetDelete(int widgetId) async {
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;

    await performWidgetDelete(widgetId);
  }

  // ===== Build Methods =====

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const AuthenticatedScaffold(
        title: 'Loading...',
        body: Center(child: AdaptiveLoadingIndicator()),
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
          key: const Key('area_button'),
          onPressed: _showAreaDialog,
          icon: const Icon(Icons.location_on),
          tooltip: _menu?.area != null
              ? 'Area: ${_menu!.area!.name}'
              : 'Set Area',
        ),
        IconButton(
          key: const Key('page_size_button'),
          onPressed: () => context.push('/admin/sizes'),
          icon: const Icon(Icons.straighten),
          tooltip: 'Manage Page Sizes',
        ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            _isNarrow = constraints.maxWidth < narrowBreakpoint;

            if (_isNarrow) {
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
                // Left Panel: Widget Palette + Side Panel Style Editor
                Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: WidgetPalette(
                          registry: registry,
                          allowedWidgetTypes: _menu?.allowedWidgetTypes,
                          onAllowedTypesChanged: _onAllowedWidgetTypesChanged,
                        ),
                      ),
                      if (_currentSelection != null) ...[
                        const Divider(height: 1),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildSidePanel(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Right Panel: Canvas
                Expanded(child: _buildCanvas()),
              ],
            );
          },
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
      pageSize: sel.type == EditorElementType.menu ? _menu?.pageSize : null,
      onPageSizePressed: sel.type == EditorElementType.menu
          ? _showPageSizeDialog
          : null,
    );
  }

  Widget _buildCanvas() {
    final theme = Theme.of(context);
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
                children: [
                  // Menu Style Selector
                  GestureDetector(
                    key: const Key('selectable_menu'),
                    onTap: () => _selectElement(
                      const EditorSelection(
                        type: EditorElementType.menu,
                        id: 0,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              _currentSelection?.type == EditorElementType.menu
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.style, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Page Style',
                            style: theme.textTheme.titleMedium,
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
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(entity.Page page) {
    final containers = _containers[page.id] ?? [];
    final isHeader = page.type == entity.PageType.header;
    final isFooter = page.type == entity.PageType.footer;
    final isSpecial = isHeader || isFooter;
    final theme = Theme.of(context);

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
      color: isSpecial
          ? Color.alphaBlend(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            )
          : null,
      shape: isSpecial
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            )
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              children: [
                if (isSpecial) ...[
                  Icon(
                    isHeader
                        ? Icons.vertical_align_top
                        : Icons.vertical_align_bottom,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHeader ? 'Header' : 'Footer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                IconButton(
                  key: Key(deleteKey),
                  icon: const Icon(Icons.delete),
                  onPressed: deleteAction,
                  tooltip: 'Delete Page',
                ),
              ],
            ),

            // Containers
            ...containers.map((container) => _buildContainerCard(container)),

            // Add Container Button (after containers)
            const SizedBox(height: 8),
            TextButton.icon(
              key: Key('add_container_${page.id}'),
              onPressed: () => _addContainer(page.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Add Container',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard(entity.Container container) {
    final columns = _columns[container.id] ?? [];
    final theme = Theme.of(context);
    final isSelected =
        _currentSelection?.type == EditorElementType.container &&
        _currentSelection?.id == container.id;

    return GestureDetector(
      key: Key('selectable_container_${container.id}'),
      onTap: () => _selectElement(
        EditorSelection(type: EditorElementType.container, id: container.id),
      ),
      child: Card(
        color: theme.colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.only(top: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container Header — no name, just action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    key: Key('add_column_${container.id}'),
                    icon: const Icon(Icons.view_column, size: 20),
                    onPressed: () => _addColumn(container.id),
                    tooltip: 'Add Column',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: Key('delete_container_${container.id}'),
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _deleteContainer(container.id),
                    tooltip: 'Delete Container',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
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
    final isSelected =
        _currentSelection?.type == EditorElementType.column &&
        _currentSelection?.id == column.id;

    // Admin template editor always allows dropping (overrides isDroppable)
    final droppableColumn = column.isDroppable
        ? column
        : column.copyWith(isDroppable: true);

    return EditorColumnCard(
      key: Key('selectable_column_${column.id}'),
      column: droppableColumn,
      widgets: widgets,
      hoverIndex: _hoverIndex[column.id] ?? -1,
      registry: registry,
      isSelected: isSelected,
      onTap: () => _selectElement(
        EditorSelection(type: EditorElementType.column, id: column.id),
      ),
      header: Column(
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
        ],
      ),
      onHoverIndexChanged: (index) {
        setState(() {
          _hoverIndex[column.id] = index;
        });
      },
      onWidgetDrop: _handleWidgetDropAtIndex,
      onWidgetMove: handleWidgetMoveToIndex,
      widgetItemBuilder: (widgetInstance, columnId) => DraggableWidgetItem(
        widgetInstance: widgetInstance,
        columnId: columnId,
        isEditable: true,
        isLocked: false,
        onUpdate: (props) => handleWidgetUpdate(widgetInstance.id, props),
        onDelete: () => _handleWidgetDelete(widgetInstance.id),
        onConfirmDismiss: () => showDeleteConfirmation(context),
        onDismissed: (id) => performWidgetDelete(id),
      ),
    );
  }
}
