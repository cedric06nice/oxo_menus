import 'dart:async';

import 'package:flutter/cupertino.dart';
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
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/editor_selection_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/widgets/side_panel_style_editor.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/editor/auto_scroll_listener.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:oxo_menus/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_column_card.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_mixin.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/menu_display_options_dialog.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/widgets/page_size_picker_dialog.dart';

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
  Timer? _styleDebounceTimer;

  @override
  late EditorWidgetCrudHelper crudHelper;
  late EditorSelectionNotifier _selectionNotifier;
  EditorSelection? _currentSelection;

  final ScrollController _scrollController = ScrollController();

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    crudHelper = EditorWidgetCrudHelper(
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
    _styleDebounceTimer?.cancel();
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

  Future<void> _showPageSizeDialog() async {
    final result = await ref.read(sizeRepositoryProvider).getAll();
    if (result.isFailure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load sizes: ${result.errorOrNull?.message ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => PageSizePickerDialog(
        sizes: result.valueOrNull!,
        currentPageSize: _menu?.pageSize,
        onSelect: (size) async {
          final pageSize = PageSize(
            name: size.name,
            width: size.width,
            height: size.height,
          );
          final updateResult = await ref
              .read(menuRepositoryProvider)
              .update(UpdateMenuInput(id: widget.menuId, sizeId: size.id));
          if (updateResult.isSuccess) {
            setState(() {
              _menu = _menu?.copyWith(pageSize: pageSize);
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Page size updated')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _showAreaDialog() async {
    final result = await ref.read(areaRepositoryProvider).getAll();
    if (result.isFailure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load areas: ${result.errorOrNull?.message ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    final areas = result.valueOrNull!;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Area'),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final updateResult = await ref
                  .read(menuRepositoryProvider)
                  .update(UpdateMenuInput(id: widget.menuId, areaId: null));
              if (updateResult.isSuccess) {
                setState(() {
                  _menu = _menu?.copyWith(area: null);
                });
              }
            },
            child: const Text('None'),
          ),
          ...areas.map(
            (area) => SimpleDialogOption(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final updateResult = await ref
                    .read(menuRepositoryProvider)
                    .update(
                      UpdateMenuInput(id: widget.menuId, areaId: area.id),
                    );
                if (updateResult.isSuccess) {
                  setState(() {
                    _menu = _menu?.copyWith(area: area);
                  });
                }
              },
              child: Text(area.name),
            ),
          ),
        ],
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

  void _updateContainerStyleLocally(int containerId, StyleConfig newStyle) {
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

  Future<void> _saveContainerStyleToApi(
    int containerId,
    StyleConfig newStyle,
  ) async {
    await ref
        .read(containerRepositoryProvider)
        .update(UpdateContainerInput(id: containerId, styleConfig: newStyle));
  }

  Future<void> _onContainerStyleChanged(
    int containerId,
    StyleConfig newStyle,
  ) async {
    await _saveContainerStyleToApi(containerId, newStyle);
    _updateContainerStyleLocally(containerId, newStyle);
  }

  void _updateColumnStyleLocally(int columnId, StyleConfig newStyle) {
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

  Future<void> _saveColumnStyleToApi(int columnId, StyleConfig newStyle) async {
    await ref
        .read(columnRepositoryProvider)
        .update(UpdateColumnInput(id: columnId, styleConfig: newStyle));
  }

  Future<void> _onColumnStyleChanged(int columnId, StyleConfig newStyle) async {
    await _saveColumnStyleToApi(columnId, newStyle);
    _updateColumnStyleLocally(columnId, newStyle);
  }

  void _debounceStyleSave(Future<void> Function() apiCall) {
    _styleDebounceTimer?.cancel();
    _styleDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        apiCall();
      }
    });
  }

  void _flushStyleDebounce() {
    _styleDebounceTimer?.cancel();
    _styleDebounceTimer = null;
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
    _flushStyleDebounce();
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
    _flushStyleDebounce();
    _selectionNotifier.deselect();
  }

  void _onSidePanelStyleChanged(StyleConfig newStyle) {
    final sel = _currentSelection;
    if (sel == null) return;

    switch (sel.type) {
      case EditorElementType.menu:
        _onStyleChanged(newStyle);
      case EditorElementType.container:
        _updateContainerStyleLocally(sel.id, newStyle);
        _selectionNotifier.updateStyle(newStyle);
        _debounceStyleSave(() => _saveContainerStyleToApi(sel.id, newStyle));
      case EditorElementType.column:
        _updateColumnStyleLocally(sel.id, newStyle);
        _selectionNotifier.updateStyle(newStyle);
        _debounceStyleSave(() => _saveColumnStyleToApi(sel.id, newStyle));
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
