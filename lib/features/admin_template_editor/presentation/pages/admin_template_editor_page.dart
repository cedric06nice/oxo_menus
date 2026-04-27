import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/models/editor_selection.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/editor_selection_provider.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/template_editor_provider.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/widgets/side_panel_style_editor.dart';
import 'package:oxo_menus/features/editor_tree/presentation/state/editor_tree_provider.dart';
import 'package:oxo_menus/features/editor_tree/presentation/state/editor_tree_state.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/allowed_widgets_provider.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/authenticated_scaffold.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/area_dialog_helper.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/page_size_dialog_helper.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/auto_scroll_listener.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/draggable_widget_item.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/editor_column_card.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/widget_palette.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/display_options_dialog_helper.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';

class AdminTemplateEditorPage extends ConsumerStatefulWidget {
  final int menuId;

  const AdminTemplateEditorPage({super.key, required this.menuId});

  @override
  ConsumerState<AdminTemplateEditorPage> createState() =>
      _AdminTemplateEditorPageState();
}

class _AdminTemplateEditorPageState
    extends ConsumerState<AdminTemplateEditorPage> {
  static const narrowBreakpoint = AppBreakpoints.mobile;

  bool _isNarrow = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(editorTreeProvider(widget.menuId).notifier)
          .loadTree(separateHeaderFooter: true);
      _listenForConnectivityRestore();
      _listenForSelectionAutoSave();
      _listenForDisplayOptions();
    });
  }

  void _listenForDisplayOptions() {
    ref.listenManual(editorTreeProvider(widget.menuId), (prev, next) {
      if (next.menu != null && next.menu != prev?.menu) {
        ref
            .read(menuDisplayOptionsProvider.notifier)
            .set(next.menu?.displayOptions);
        ref
            .read(allowedWidgetsProvider.notifier)
            .set(next.menu?.allowedWidgets ?? const []);
      }
    });
  }

  void _listenForSelectionAutoSave() {
    ref.listenManual(editorSelectionProvider, (prev, next) {
      if (prev == null) return;
      if (prev.selection == next.selection) return;
      if (prev.selection == null) return;
      if (prev.currentStyle == prev.originalStyle) return;
      if (prev.currentStyle == null) return;

      final style = prev.currentStyle!;
      final notifier = ref.read(templateEditorProvider(widget.menuId).notifier);
      notifier.onSidePanelStyleChanged(style, prev.selection!);
      notifier.flushStyleDebounce();
    });
  }

  void _listenForConnectivityRestore() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOnline = next.value == ConnectivityStatus.online;
      final treeState = ref.read(editorTreeProvider(widget.menuId));
      if (wasOffline && isOnline && treeState.errorMessage != null) {
        ref
            .read(editorTreeProvider(widget.menuId).notifier)
            .loadTree(separateHeaderFooter: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showPdf() async {
    context.push(AppRoutes.menuPdf(widget.menuId));
  }

  void _showDisplayOptionsDialog() {
    final treeState = ref.read(editorTreeProvider(widget.menuId));
    showDisplayOptionsDialog(
      context: context,
      ref: ref,
      menuId: widget.menuId,
      menu: treeState.menu,
      onMenuUpdated: (updatedMenu) {
        if (updatedMenu != null) {
          ref
              .read(editorTreeProvider(widget.menuId).notifier)
              .updateMenuLocally(updatedMenu);
        }
      },
    );
  }

  Future<void> _showPageSizeDialog() {
    final treeState = ref.read(editorTreeProvider(widget.menuId));
    return showPageSizeDialog(
      context: context,
      ref: ref,
      menuId: widget.menuId,
      currentPageSize: treeState.menu?.pageSize,
      onPageSizeUpdated: (pageSize) {
        final menu = treeState.menu;
        if (menu != null) {
          ref
              .read(editorTreeProvider(widget.menuId).notifier)
              .updateMenuLocally(menu.copyWith(pageSize: pageSize));
        }
      },
    );
  }

  Future<void> _showAreaDialog() {
    final treeState = ref.read(editorTreeProvider(widget.menuId));
    return showAreaDialog(
      context: context,
      ref: ref,
      menuId: widget.menuId,
      onAreaUpdated: (area) {
        final menu = treeState.menu;
        if (menu != null) {
          ref
              .read(editorTreeProvider(widget.menuId).notifier)
              .updateMenuLocally(menu.copyWith(area: area));
        }
      },
    );
  }

  StyleConfig? _resolveStyle(EditorSelection selection) {
    final treeState = ref.read(editorTreeProvider(widget.menuId));
    switch (selection.type) {
      case EditorElementType.menu:
        return treeState.menu?.styleConfig;
      case EditorElementType.container:
        for (final entry in treeState.containers.entries) {
          for (final c in entry.value) {
            if (c.id == selection.id) return c.styleConfig;
          }
        }
        for (final entry in treeState.childContainers.entries) {
          for (final c in entry.value) {
            if (c.id == selection.id) return c.styleConfig;
          }
        }
        return null;
      case EditorElementType.column:
        for (final entry in treeState.columns.entries) {
          for (final c in entry.value) {
            if (c.id == selection.id) return c.styleConfig;
          }
        }
        return null;
    }
  }

  entity.LayoutConfig? _resolveContainerLayout(
    int containerId,
    EditorTreeState treeState,
  ) {
    for (final entry in treeState.containers.entries) {
      for (final c in entry.value) {
        if (c.id == containerId) return c.layout;
      }
    }
    for (final entry in treeState.childContainers.entries) {
      for (final c in entry.value) {
        if (c.id == containerId) return c.layout;
      }
    }
    return null;
  }

  // ===== Selection =====

  void _selectElement(EditorSelection selection) {
    ref
        .read(templateEditorProvider(widget.menuId).notifier)
        .flushStyleDebounce();
    final style = _resolveStyle(selection);
    ref.read(editorSelectionProvider.notifier).select(selection, style);

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
    ref
        .read(templateEditorProvider(widget.menuId).notifier)
        .flushStyleDebounce();
    ref.read(editorSelectionProvider.notifier).deselect();
  }

  void _onSidePanelStyleChanged(StyleConfig newStyle) {
    final sel = ref.read(editorSelectionProvider).selection;
    if (sel == null) return;

    ref
        .read(templateEditorProvider(widget.menuId).notifier)
        .onSidePanelStyleChanged(newStyle, sel);
    ref.read(editorSelectionProvider.notifier).updateStyle(newStyle);
  }

  // ===== Template Actions =====

  Future<void> _saveTemplate() async {
    await ref
        .read(templateEditorProvider(widget.menuId).notifier)
        .saveTemplate();
    if (mounted) {
      showThemedSnackBar(context, 'Template saved');
    }
  }

  Future<void> _publishTemplate() async {
    await ref
        .read(templateEditorProvider(widget.menuId).notifier)
        .publishTemplate();
    if (mounted) {
      showThemedSnackBar(context, 'Template published');
    }
  }

  // ===== Widget CRUD =====

  Future<void> _handleWidgetDropAtIndex(
    String widgetType,
    int columnId,
    int index,
  ) async {
    final notifier = ref.read(editorTreeProvider(widget.menuId).notifier);
    final result = await notifier.createWidget(
      widgetType,
      columnId,
      index,
      isTemplate: true,
    );
    if (result != null && result.isFailure && mounted) {
      showThemedSnackBar(
        context,
        'Failed to create widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  Future<void> _handleWidgetUpdate(
    int widgetId,
    Map<String, dynamic> props,
  ) async {
    final notifier = ref.read(editorTreeProvider(widget.menuId).notifier);
    await notifier.updateWidgetProps(widgetId, props);
  }

  Future<void> _performWidgetDelete(int widgetId) async {
    final notifier = ref.read(editorTreeProvider(widget.menuId).notifier);
    final result = await notifier.deleteWidget(widgetId);
    if (result.isFailure && mounted) {
      showThemedSnackBar(
        context,
        'Failed to delete widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  Future<void> _handleWidgetMoveToIndex(
    WidgetInstance widgetInstance,
    int sourceColumnId,
    int targetColumnId,
    int targetIndex,
  ) async {
    final notifier = ref.read(editorTreeProvider(widget.menuId).notifier);
    final result = await notifier.moveWidget(
      widgetInstance,
      sourceColumnId,
      targetColumnId,
      targetIndex,
    );
    if (result.isFailure && mounted) {
      showThemedSnackBar(
        context,
        'Failed to move widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  Future<void> _handleWidgetDelete(int widgetId) async {
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;

    await _performWidgetDelete(widgetId);
  }

  // ===== Build Methods =====

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final treeState = ref.watch(editorTreeProvider(widget.menuId));
    final selectionState = ref.watch(editorSelectionProvider);
    final currentSelection = selectionState.selection;

    if (treeState.isLoading) {
      return const AuthenticatedScaffold(
        title: 'Loading...',
        body: Center(child: AdaptiveLoadingIndicator()),
      );
    }

    if (treeState.errorMessage != null) {
      return AuthenticatedScaffold(
        title: 'Error',
        body: Center(child: Text('Error: ${treeState.errorMessage}')),
      );
    }

    final registry = ref.watch(widgetRegistryProvider);
    final menu = treeState.menu;
    final templateNotifier = ref.read(
      templateEditorProvider(widget.menuId).notifier,
    );

    return AuthenticatedScaffold(
      title: menu?.name ?? 'Template Editor',
      actions: [
        IconButton(
          key: const Key('area_button'),
          onPressed: _showAreaDialog,
          icon: const Icon(Icons.location_on),
          tooltip: menu?.area != null
              ? 'Area: ${menu!.area!.name}'
              : 'Set Area',
        ),
        IconButton(
          key: const Key('page_size_button'),
          onPressed: () => context.push(AppRoutes.adminSizes),
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
                    allowedWidgets: menu?.allowedWidgets,
                  ),
                  Expanded(child: _buildCanvas(treeState)),
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
                          allowedWidgets: menu?.allowedWidgets,
                          onAllowedWidgetsChanged: (configs) =>
                              templateNotifier.updateAllowedWidgets(configs),
                        ),
                      ),
                      if (currentSelection != null) ...[
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
                Expanded(child: _buildCanvas(treeState)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    final selState = ref.watch(editorSelectionProvider);
    final sel = selState.selection;
    if (sel == null) return const SizedBox.shrink();

    final treeState = ref.read(editorTreeProvider(widget.menuId));
    final style = _resolveStyle(sel);
    bool? isDroppable;
    ValueChanged<bool>? onDroppableChanged;
    entity.LayoutConfig? layoutConfig;

    if (sel.type == EditorElementType.column) {
      for (final entry in treeState.columns.entries) {
        for (final col in entry.value) {
          if (col.id == sel.id) {
            isDroppable = col.isDroppable;
            onDroppableChanged = (value) => ref
                .read(templateEditorProvider(widget.menuId).notifier)
                .updateColumnDroppable(sel.id, value);
            break;
          }
        }
      }
    }

    if (sel.type == EditorElementType.container) {
      layoutConfig = _resolveContainerLayout(sel.id, treeState);
    }

    final selectionNotifier = ref.read(editorSelectionProvider.notifier);

    return SidePanelStyleEditor(
      type: sel.type,
      styleConfig: style,
      clipboardStyle: selState.clipboardStyle,
      onCopy: () => selectionNotifier.copyStyle(),
      onPaste: () {
        final pasted = selectionNotifier.pasteStyle();
        if (pasted != null) {
          _onSidePanelStyleChanged(pasted);
        }
      },
      onStyleChanged: _onSidePanelStyleChanged,
      isDroppable: isDroppable,
      onDroppableChanged: onDroppableChanged,
      pageSize: sel.type == EditorElementType.menu
          ? treeState.menu?.pageSize
          : null,
      onPageSizePressed: sel.type == EditorElementType.menu
          ? _showPageSizeDialog
          : null,
      layoutConfig: layoutConfig,
      onLayoutChanged: sel.type == EditorElementType.container
          ? (layout) => ref
                .read(templateEditorProvider(widget.menuId).notifier)
                .updateContainerLayout(sel.id, layout)
          : null,
    );
  }

  Widget _buildCanvas(EditorTreeState treeState) {
    final theme = Theme.of(context);
    final pages = treeState.pages;
    final headerPage = treeState.headerPage;
    final footerPage = treeState.footerPage;
    final templateNotifier = ref.read(
      templateEditorProvider(widget.menuId).notifier,
    );

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
                              ref
                                      .watch(editorSelectionProvider)
                                      .selection
                                      ?.type ==
                                  EditorElementType.menu
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
                  if (headerPage == null)
                    ElevatedButton.icon(
                      key: const Key('add_header_button'),
                      onPressed: () => templateNotifier.addHeader(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Header'),
                    )
                  else
                    _buildPageCard(headerPage, treeState),
                  const SizedBox(height: 16),

                  // Add Page Button
                  ElevatedButton.icon(
                    key: const Key('add_page_button'),
                    onPressed: () => templateNotifier.addPage(pages.length),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Page'),
                  ),
                  const SizedBox(height: 16),

                  // Pages List
                  ...pages.map((page) => _buildPageCard(page, treeState)),

                  // Footer Section
                  const SizedBox(height: 16),
                  if (footerPage == null)
                    ElevatedButton.icon(
                      key: const Key('add_footer_button'),
                      onPressed: () => templateNotifier.addFooter(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Footer'),
                    )
                  else
                    _buildPageCard(footerPage, treeState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(entity.Page page, EditorTreeState treeState) {
    final containers = treeState.containers[page.id] ?? [];
    final isHeader = page.type == entity.PageType.header;
    final isFooter = page.type == entity.PageType.footer;
    final isSpecial = isHeader || isFooter;
    final theme = Theme.of(context);
    final templateNotifier = ref.read(
      templateEditorProvider(widget.menuId).notifier,
    );

    final String deleteKey;
    final VoidCallback deleteAction;

    if (isHeader) {
      deleteKey = 'delete_header_button';
      deleteAction = () async {
        final confirmed = await showDeleteConfirmation(context);
        if (confirmed == true) {
          await templateNotifier.deleteHeader(page.id);
        }
      };
    } else if (isFooter) {
      deleteKey = 'delete_footer_button';
      deleteAction = () async {
        final confirmed = await showDeleteConfirmation(context);
        if (confirmed == true) {
          await templateNotifier.deleteFooter(page.id);
        }
      };
    } else {
      deleteKey = 'delete_page_${page.id}';
      deleteAction = () async {
        final confirmed = await showDeleteConfirmation(context);
        if (confirmed == true) {
          await templateNotifier.deletePage(page.id);
        }
      };
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
            ...containers.map(
              (container) => _buildContainerCard(
                container,
                treeState,
                siblings: containers,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              key: Key('add_container_${page.id}'),
              onPressed: () => templateNotifier.addContainer(
                page.id,
                (treeState.containers[page.id] ?? []).length,
              ),
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

  Widget _buildContainerCard(
    entity.Container container,
    EditorTreeState treeState, {
    List<entity.Container> siblings = const [],
  }) {
    final columns = treeState.columns[container.id] ?? [];
    final childContainers = treeState.childContainers[container.id] ?? [];
    final isGroup = childContainers.isNotEmpty;
    final theme = Theme.of(context);
    final currentSel = ref.watch(editorSelectionProvider).selection;
    final isSelected =
        currentSel?.type == EditorElementType.container &&
        currentSel?.id == container.id;
    final templateNotifier = ref.read(
      templateEditorProvider(widget.menuId).notifier,
    );
    final treeNotifier = ref.read(editorTreeProvider(widget.menuId).notifier);
    final isFirst = siblings.isEmpty || siblings.first.id == container.id;
    final isLast = siblings.isEmpty || siblings.last.id == container.id;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    key: Key('container_move_up_${container.id}'),
                    icon: const Icon(Icons.arrow_upward, size: 20),
                    onPressed: isFirst
                        ? null
                        : () => treeNotifier.reorderContainer(
                            container.id,
                            ReorderDirection.up,
                          ),
                    tooltip: 'Move up',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: Key('container_move_down_${container.id}'),
                    icon: const Icon(Icons.arrow_downward, size: 20),
                    onPressed: isLast
                        ? null
                        : () => treeNotifier.reorderContainer(
                            container.id,
                            ReorderDirection.down,
                          ),
                    tooltip: 'Move down',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: Key('container_duplicate_${container.id}'),
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () =>
                        treeNotifier.duplicateContainer(container.id),
                    tooltip: 'Duplicate',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  if (!isGroup) ...[
                    IconButton(
                      key: Key('add_column_${container.id}'),
                      icon: const Icon(Icons.view_column, size: 20),
                      onPressed: () => templateNotifier.addColumn(
                        container.id,
                        (treeState.columns[container.id] ?? []).length,
                      ),
                      tooltip: 'Add Column',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    const SizedBox(width: 4),
                  ],
                  IconButton(
                    key: Key('add_child_container_${container.id}'),
                    icon: const Icon(Icons.dashboard, size: 20),
                    onPressed: () => templateNotifier.addChildContainer(
                      container.id,
                      childContainers.length,
                    ),
                    tooltip: 'Add Child Container',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: Key('delete_container_${container.id}'),
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () async {
                      final confirmed = await showDeleteConfirmation(context);
                      if (confirmed == true) {
                        await templateNotifier.deleteContainer(container.id);
                      }
                    },
                    tooltip: 'Delete Container',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Group container: show child containers
              if (isGroup)
                ...childContainers.map(
                  (child) => _buildContainerCard(
                    child,
                    treeState,
                    siblings: childContainers,
                  ),
                ),
              // Leaf container: show columns
              if (!isGroup && columns.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columns
                      .map(
                        (column) => Expanded(
                          flex: column.flex ?? 1,
                          child: _buildColumnCard(column, treeState),
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

  Widget _buildColumnCard(entity.Column column, EditorTreeState treeState) {
    final widgets = treeState.widgets[column.id] ?? [];
    final registry = ref.watch(widgetRegistryProvider);
    final currentSel = ref.watch(editorSelectionProvider).selection;
    final isSelected =
        currentSel?.type == EditorElementType.column &&
        currentSel?.id == column.id;
    final templateNotifier = ref.read(
      templateEditorProvider(widget.menuId).notifier,
    );

    final droppableColumn = column.isDroppable
        ? column
        : column.copyWith(isDroppable: true);

    return EditorColumnCard(
      key: Key('selectable_column_${column.id}'),
      column: droppableColumn,
      widgets: widgets,
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
                onPressed: () async {
                  final confirmed = await showDeleteConfirmation(context);
                  if (confirmed == true) {
                    await templateNotifier.deleteColumn(column.id);
                  }
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: 'Delete Column',
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
      onWidgetDrop: _handleWidgetDropAtIndex,
      onWidgetMove: _handleWidgetMoveToIndex,
      widgetItemBuilder: (widgetInstance, columnId) => DraggableWidgetItem(
        widgetInstance: widgetInstance,
        columnId: columnId,
        isEditable: true,
        isLocked: false,
        showLockToggle: true,
        isLockedForEdition: widgetInstance.lockedForEdition,
        onLockToggle: (locked) => ref
            .read(editorTreeProvider(widget.menuId).notifier)
            .updateWidgetLockForEdition(widgetInstance.id, locked),
        onUpdate: (props) => _handleWidgetUpdate(widgetInstance.id, props),
        onDelete: () => _handleWidgetDelete(widgetInstance.id),
        onConfirmDismiss: () => showDeleteConfirmation(context),
        onDismissed: (id) => _performWidgetDelete(id),
      ),
    );
  }
}
