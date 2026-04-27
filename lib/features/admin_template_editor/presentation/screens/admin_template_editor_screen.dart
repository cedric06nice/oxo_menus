import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/admin_template_editor_screen_state.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/editor_selection.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/view_models/admin_template_editor_view_model.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/widgets/page_size_picker_dialog.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/widgets/side_panel_style_editor.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/auto_scroll_listener.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/editor_column_card.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/features/menu_editor/presentation/widgets/menu_display_options_dialog.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/allowed_widgets_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/authenticated_scaffold.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';

/// MVVM-stack admin template editor screen.
///
/// Pure widget — owns no Riverpod providers and no navigation. Reads its
/// snapshot from the injected [AdminTemplateEditorViewModel] and forwards user
/// actions back to it. Uses a small [Consumer] bridge to keep the legacy
/// `menuDisplayOptionsProvider` + `allowedWidgetsProvider` in sync so widget
/// rendering still picks up live edits while Phase 12 (menu editor migration)
/// retires the legacy `editor_tree` Riverpod stack.
class AdminTemplateEditorScreen extends StatefulWidget {
  const AdminTemplateEditorScreen({super.key, required this.viewModel});

  final AdminTemplateEditorViewModel viewModel;

  @override
  State<AdminTemplateEditorScreen> createState() =>
      _AdminTemplateEditorScreenState();
}

class _AdminTemplateEditorScreenState extends State<AdminTemplateEditorScreen> {
  static const _narrowBreakpoint = AppBreakpoints.mobile;
  bool _isNarrow = false;
  String? _lastSurfacedError;
  EditorSelection? _lastSelection;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) {
      return;
    }
    final state = widget.viewModel.state;
    final next = state.errorMessage;
    if (next != null && next != _lastSurfacedError) {
      _lastSurfacedError = next;
      showThemedSnackBar(context, next, isError: true);
    } else if (next == null) {
      _lastSurfacedError = null;
    }
    if (_isNarrow &&
        state.selection != null &&
        state.selection != _lastSelection) {
      _lastSelection = state.selection;
      _showStyleEditorBottomSheet();
    } else if (state.selection == null) {
      _lastSelection = null;
    }
    setState(() {});
  }

  // ----------------------------------------------------------- Selection UI

  void _selectMenu() => widget.viewModel.selectMenu();
  void _selectContainer(int id) => widget.viewModel.selectContainer(id);
  void _selectColumn(int id) => widget.viewModel.selectColumn(id);

  void _showStyleEditorBottomSheet() {
    showModalBottomSheet<void>(
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
      widget.viewModel.deselect();
    });
  }

  // ----------------------------------------------------------- Dialogs

  Future<void> _showAreaDialog() async {
    final result = await widget.viewModel.loadAreas();
    if (!mounted) return;
    final areas = result.fold(
      onSuccess: (a) => a,
      onFailure: (_) => const <Area>[],
    );
    if (result.isFailure) {
      showThemedSnackBar(context, 'Failed to load areas', isError: true);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Area'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.viewModel.updateArea(null);
            },
            child: const Text('None'),
          ),
          ...areas.map(
            (area) => SimpleDialogOption(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.viewModel.updateArea(area);
              },
              child: Text(area.name),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPageSizeDialog() async {
    final result = await widget.viewModel.loadSizes();
    if (!mounted) return;
    if (result.isFailure) {
      showThemedSnackBar(context, 'Failed to load sizes', isError: true);
      return;
    }
    final sizes = result.fold<List<domain.Size>>(
      onSuccess: (s) => s,
      onFailure: (_) => const <domain.Size>[],
    );
    final menu = widget.viewModel.state.tree?.menu;
    await showDialog<void>(
      context: context,
      builder: (ctx) => PageSizePickerDialog(
        sizes: sizes,
        currentPageSize: menu?.pageSize,
        onSelect: (size) {
          widget.viewModel.updatePageSize(
            size.id,
            PageSize(name: size.name, width: size.width, height: size.height),
          );
        },
      ),
    );
  }

  Future<void> _showDisplayOptionsDialog() async {
    final menu = widget.viewModel.state.tree?.menu;
    await showDialog<void>(
      context: context,
      builder: (ctx) => MenuDisplayOptionsDialog(
        displayOptions: menu?.displayOptions,
        onSave: widget.viewModel.updateDisplayOptions,
      ),
    );
  }

  // ----------------------------------------------------------- Actions

  Future<void> _confirmDeletePage(entity.Page page) async {
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;
    await widget.viewModel.deletePage(page.id);
  }

  Future<void> _confirmDeleteContainer(int containerId) async {
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;
    await widget.viewModel.deleteContainer(containerId);
  }

  Future<void> _confirmDeleteColumn(int columnId) async {
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;
    await widget.viewModel.deleteColumn(columnId);
  }

  Future<void> _confirmDeleteWidget(int widgetId) async {
    final confirmed = await showDeleteConfirmation(context);
    if (confirmed != true) return;
    await widget.viewModel.deleteWidget(widgetId);
  }

  Future<void> _saveTemplate() async {
    await widget.viewModel.saveTemplate();
    if (!mounted) return;
    showThemedSnackBar(context, 'Template saved');
  }

  Future<void> _publishTemplate() async {
    await widget.viewModel.publishTemplate();
    if (!mounted) return;
    showThemedSnackBar(context, 'Template published');
  }

  // ----------------------------------------------------------- Build

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    if (state.isLoading) {
      return const AuthenticatedScaffold(
        title: 'Loading...',
        body: Center(child: AdaptiveLoadingIndicator()),
      );
    }
    final tree = state.tree;
    if (tree == null) {
      return AuthenticatedScaffold(
        title: 'Error',
        body: Center(
          child: Text('Error: ${state.errorMessage ?? 'Unknown error'}'),
        ),
      );
    }
    final menu = tree.menu;
    final isSaving = state.savingState == TemplateSavingState.saving;
    final isPublishing = state.savingState == TemplateSavingState.publishing;
    return AuthenticatedScaffold(
      title: menu.name.isEmpty ? 'Template Editor' : menu.name,
      actions: <Widget>[
        IconButton(
          key: const Key('area_button'),
          onPressed: _showAreaDialog,
          icon: const Icon(Icons.location_on),
          tooltip: menu.area != null ? 'Area: ${menu.area!.name}' : 'Set Area',
        ),
        IconButton(
          key: const Key('page_size_button'),
          onPressed: widget.viewModel.goToAdminSizes,
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
          onPressed: widget.viewModel.goToPdfPreview,
          icon: const Icon(Icons.file_present),
          tooltip: 'Show PDF',
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: isSaving || isPublishing ? null : _saveTemplate,
          tooltip: 'Save',
        ),
        IconButton(
          icon: const Icon(Icons.publish),
          onPressed: isSaving || isPublishing ? null : _publishTemplate,
          tooltip: 'Publish',
        ),
      ],
      body: Consumer(
        builder: (context, ref, child) {
          // Bridge VM tree to legacy global providers so the existing
          // WidgetRenderer (still a ConsumerWidget during the migration) keeps
          // showing the live displayOptions / allowedWidgets values. Scheduled
          // post-frame because Riverpod forbids provider mutation during a
          // build phase.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            ref
                .read(menuDisplayOptionsProvider.notifier)
                .set(menu.displayOptions);
            ref.read(allowedWidgetsProvider.notifier).set(menu.allowedWidgets);
          });
          final registry = ref.watch(widgetRegistryProvider);
          return LayoutBuilder(
            builder: (context, constraints) {
              _isNarrow = constraints.maxWidth < _narrowBreakpoint;
              if (_isNarrow) {
                return Column(
                  children: <Widget>[
                    WidgetPalette(
                      axis: Axis.horizontal,
                      registry: registry,
                      allowedWidgets: menu.allowedWidgets,
                    ),
                    Expanded(child: _buildCanvas(state, registry)),
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Container(
                    width: 260,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: WidgetPalette(
                            registry: registry,
                            allowedWidgets: menu.allowedWidgets,
                            onAllowedWidgetsChanged:
                                widget.viewModel.updateAllowedWidgets,
                          ),
                        ),
                        if (state.selection != null) ...<Widget>[
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
                  Expanded(child: _buildCanvas(state, registry)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSidePanel() {
    final state = widget.viewModel.state;
    final selection = state.selection;
    if (selection == null) {
      return const SizedBox.shrink();
    }
    final tree = state.tree;
    bool? isDroppable;
    ValueChanged<bool>? onDroppableChanged;
    entity.LayoutConfig? layoutConfig;
    if (selection.type == EditorElementType.column && tree != null) {
      for (final list in tree.columns.values) {
        for (final col in list) {
          if (col.id == selection.id) {
            isDroppable = col.isDroppable;
            onDroppableChanged = (value) =>
                widget.viewModel.updateColumnDroppable(selection.id, value);
            break;
          }
        }
      }
    }
    if (selection.type == EditorElementType.container && tree != null) {
      layoutConfig = _resolveContainerLayout(tree, selection.id);
    }
    return SidePanelStyleEditor(
      type: selection.type,
      styleConfig: state.currentStyle,
      clipboardStyle: state.clipboardStyle,
      onCopy: widget.viewModel.copyStyle,
      onPaste: () {
        final pasted = widget.viewModel.pasteStyle();
        if (pasted != null) {
          widget.viewModel.updateSelectedStyle(pasted);
        }
      },
      onStyleChanged: widget.viewModel.updateSelectedStyle,
      isDroppable: isDroppable,
      onDroppableChanged: onDroppableChanged,
      pageSize: selection.type == EditorElementType.menu
          ? tree?.menu.pageSize
          : null,
      onPageSizePressed: selection.type == EditorElementType.menu
          ? _showPageSizeDialog
          : null,
      layoutConfig: layoutConfig,
      onLayoutChanged: selection.type == EditorElementType.container
          ? (layout) =>
                widget.viewModel.updateContainerLayout(selection.id, layout)
          : null,
    );
  }

  entity.LayoutConfig? _resolveContainerLayout(
    /* tree*/ dynamic tree,
    int containerId,
  ) {
    final state = widget.viewModel.state;
    final t = state.tree;
    if (t == null) return null;
    for (final list in t.containers.values) {
      for (final c in list) {
        if (c.id == containerId) return c.layout;
      }
    }
    for (final list in t.childContainers.values) {
      for (final c in list) {
        if (c.id == containerId) return c.layout;
      }
    }
    return null;
  }

  Widget _buildCanvas(AdminTemplateEditorScreenState state, dynamic registry) {
    final tree = state.tree!;
    return AutoScrollListener(
      scrollController: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    key: const Key('selectable_menu'),
                    onTap: _selectMenu,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: state.selection?.type == EditorElementType.menu
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.style, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Page Style',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (tree.headerPage == null)
                    ElevatedButton.icon(
                      key: const Key('add_header_button'),
                      onPressed: widget.viewModel.addHeader,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Header'),
                    )
                  else
                    _buildPageCard(tree.headerPage!, tree, registry, state),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    key: const Key('add_page_button'),
                    onPressed: widget.viewModel.addPage,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Page'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...tree.pages.map(
                    (p) => _buildPageCard(p, tree, registry, state),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (tree.footerPage == null)
                    ElevatedButton.icon(
                      key: const Key('add_footer_button'),
                      onPressed: widget.viewModel.addFooter,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Footer'),
                    )
                  else
                    _buildPageCard(tree.footerPage!, tree, registry, state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(
    entity.Page page,
    dynamic tree,
    dynamic registry,
    AdminTemplateEditorScreenState state,
  ) {
    final treeData = state.tree!;
    final containers = treeData.containers[page.id] ?? const [];
    final isHeader = page.type == entity.PageType.header;
    final isFooter = page.type == entity.PageType.footer;
    final isSpecial = isHeader || isFooter;
    final theme = Theme.of(context);
    final deleteKey = isHeader
        ? 'delete_header_button'
        : isFooter
        ? 'delete_footer_button'
        : 'delete_page_${page.id}';
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      color: isSpecial
          ? Color.alphaBlend(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: isSpecial
            ? BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (isSpecial) ...<Widget>[
                  Icon(
                    isHeader
                        ? Icons.vertical_align_top
                        : Icons.vertical_align_bottom,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
                  onPressed: () => _confirmDeletePage(page),
                  tooltip: 'Delete Page',
                ),
              ],
            ),
            ...containers.map(
              (c) =>
                  _buildContainerCard(c, registry, state, siblings: containers),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              key: Key('add_container_${page.id}'),
              onPressed: () => widget.viewModel.addContainer(page.id),
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
    dynamic registry,
    AdminTemplateEditorScreenState state, {
    List<entity.Container> siblings = const [],
  }) {
    final tree = state.tree!;
    final columns = tree.columns[container.id] ?? const [];
    final childContainers = tree.childContainers[container.id] ?? const [];
    final isGroup = childContainers.isNotEmpty;
    final theme = Theme.of(context);
    final selection = state.selection;
    final isSelected =
        selection?.type == EditorElementType.container &&
        selection?.id == container.id;
    final isFirst = siblings.isEmpty || siblings.first.id == container.id;
    final isLast = siblings.isEmpty || siblings.last.id == container.id;
    return GestureDetector(
      key: Key('selectable_container_${container.id}'),
      onTap: () => _selectContainer(container.id),
      child: Card(
        color: theme.colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    key: Key('container_move_up_${container.id}'),
                    icon: const Icon(Icons.arrow_upward, size: 20),
                    onPressed: isFirst
                        ? null
                        : () => widget.viewModel.reorderContainer(
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
                        : () => widget.viewModel.reorderContainer(
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
                        widget.viewModel.duplicateContainer(container.id),
                    tooltip: 'Duplicate',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  if (!isGroup) ...<Widget>[
                    IconButton(
                      key: Key('add_column_${container.id}'),
                      icon: const Icon(Icons.view_column, size: 20),
                      onPressed: () => widget.viewModel.addColumn(container.id),
                      tooltip: 'Add Column',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    const SizedBox(width: 4),
                  ],
                  IconButton(
                    key: Key('add_child_container_${container.id}'),
                    icon: const Icon(Icons.dashboard, size: 20),
                    onPressed: () =>
                        widget.viewModel.addChildContainer(container.id),
                    tooltip: 'Add Child Container',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: Key('delete_container_${container.id}'),
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _confirmDeleteContainer(container.id),
                    tooltip: 'Delete Container',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (isGroup)
                ...childContainers.map(
                  (child) => _buildContainerCard(
                    child,
                    registry,
                    state,
                    siblings: childContainers,
                  ),
                ),
              if (!isGroup && columns.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columns
                      .map(
                        (column) => Expanded(
                          flex: column.flex ?? 1,
                          child: _buildColumnCard(column, registry, state),
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

  Widget _buildColumnCard(
    entity.Column column,
    dynamic registry,
    AdminTemplateEditorScreenState state,
  ) {
    final tree = state.tree!;
    final widgets = tree.widgets[column.id] ?? const [];
    final selection = state.selection;
    final isSelected =
        selection?.type == EditorElementType.column &&
        selection?.id == column.id;
    final droppableColumn = column.isDroppable
        ? column
        : column.copyWith(isDroppable: true);
    return EditorColumnCard(
      key: Key('selectable_column_${column.id}'),
      column: droppableColumn,
      widgets: widgets,
      registry: registry,
      isSelected: isSelected,
      onTap: () => _selectColumn(column.id),
      header: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Flex: ${column.flex ?? 1}',
                style: const TextStyle(fontSize: 11),
              ),
              IconButton(
                key: Key('delete_column_${column.id}'),
                icon: const Icon(Icons.delete, size: 16),
                onPressed: () => _confirmDeleteColumn(column.id),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: 'Delete Column',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
      onWidgetDrop: (type, columnId, index) async {
        final reg = registry;
        final definition = reg.getDefinition(type);
        if (definition == null) {
          return;
        }
        final defaultProps =
            (definition.defaultProps as dynamic).toJson()
                as Map<String, dynamic>;
        await widget.viewModel.createWidget(
          type: type,
          version: definition.version,
          defaultProps: defaultProps,
          columnId: columnId,
          index: index,
        );
      },
      onWidgetMove:
          (widgetInstance, sourceColumnId, targetColumnId, targetIndex) =>
              widget.viewModel.moveWidget(
                widget: widgetInstance,
                sourceColumnId: sourceColumnId,
                targetColumnId: targetColumnId,
                targetIndex: targetIndex,
              ),
      widgetItemBuilder: (widgetInstance, columnId) => DraggableWidgetItem(
        widgetInstance: widgetInstance,
        columnId: columnId,
        isEditable: true,
        showLockToggle: true,
        isLockedForEdition: widgetInstance.lockedForEdition,
        onLockToggle: (locked) => widget.viewModel.updateWidgetLockForEdition(
          widgetInstance.id,
          locked,
        ),
        onUpdate: (props) =>
            widget.viewModel.updateWidgetProps(widgetInstance.id, props),
        onDelete: () => _confirmDeleteWidget(widgetInstance.id),
        onConfirmDismiss: () => showDeleteConfirmation(context),
        onDismissed: (id) => widget.viewModel.deleteWidget(id),
      ),
    );
  }
}
