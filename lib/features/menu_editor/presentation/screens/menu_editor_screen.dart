import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_error_page.dart';
import 'package:oxo_menus/features/collaboration/presentation/widgets/presence_bar.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/auto_scroll_listener.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/editor_column_card.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/menu_editor_screen_state.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/menu_editor_view_model.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/allowed_widgets_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_error_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/authenticated_scaffold.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';

/// MVVM-stack consumer-facing menu editor screen.
///
/// Pure widget — owns no Riverpod providers other than the bridge that keeps
/// `menuDisplayOptionsProvider` + `allowedWidgetsProvider` in sync with the VM
/// state so the legacy widget renderer (still a ConsumerWidget) keeps showing
/// live edits. Uses [WidgetsBindingObserver] to forward app lifecycle changes
/// into the VM so collaboration subscriptions can pause/resume.
class MenuEditorScreen extends StatefulWidget {
  const MenuEditorScreen({super.key, required this.viewModel});

  final MenuEditorViewModel viewModel;

  @override
  State<MenuEditorScreen> createState() => _MenuEditorScreenState();
}

class _MenuEditorScreenState extends State<MenuEditorScreen>
    with WidgetsBindingObserver {
  static const _narrowBreakpoint = AppBreakpoints.mobile;

  final ScrollController _scrollController = ScrollController();
  String? _lastSurfacedError;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.viewModel.removeListener(_onChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.viewModel.onAppLifecycleChanged(state == AppLifecycleState.resumed);
  }

  void _onChanged() {
    if (!mounted) {
      return;
    }
    final next = widget.viewModel.state.errorMessage;
    if (next != null && next != _lastSurfacedError) {
      _lastSurfacedError = next;
      showThemedSnackBar(context, next, isError: true);
    } else if (next == null) {
      _lastSurfacedError = null;
    }
    setState(() {});
  }

  // ----------------------------------------------------------- Actions

  Future<void> _onShowPdfPressed() async {
    final outcome = await widget.viewModel.publishBundlesAndPreviewPdf();
    if (!mounted || outcome.isEmpty) {
      return;
    }
    if (outcome.hasFailures) {
      showThemedSnackBar(
        context,
        'Failed to publish ${outcome.failureCount} exportable menu PDF'
        '${outcome.failureCount == 1 ? '' : 's'}: '
        '${outcome.firstFailureMessage ?? 'Unknown error'}',
        isError: true,
      );
    } else {
      showThemedSnackBar(
        context,
        'Published ${outcome.totalCount} exportable menu PDF'
        '${outcome.totalCount == 1 ? '' : 's'}',
      );
    }
  }

  Future<void> _onSavePressed() async {
    await widget.viewModel.saveMenu();
    if (!mounted) {
      return;
    }
    if (widget.viewModel.state.errorMessage == null) {
      showThemedSnackBar(context, 'Menu saved');
    }
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
    final menu = tree?.menu;
    final title = menu?.name ?? 'Menu Editor';
    return Consumer(
      builder: (context, ref, _) {
        final isOffline =
            ref.watch(connectivityProvider).value == ConnectivityStatus.offline;
        if (isOffline) {
          return AuthenticatedScaffold(
            title: title,
            body: OfflineErrorPage(
              onRetry: () => ref.invalidate(connectivityProvider),
            ),
          );
        }
        if (state.errorMessage != null && tree == null) {
          return AuthenticatedScaffold(
            title: 'Error',
            body: AdaptiveErrorState(
              message: state.errorMessage!,
              onRetry: widget.viewModel.reload,
            ),
          );
        }
        if (tree == null) {
          return AuthenticatedScaffold(
            title: title,
            body: const Center(child: AdaptiveLoadingIndicator()),
          );
        }
        // Bridge VM tree to legacy global providers so the existing
        // WidgetRenderer (still a ConsumerWidget) keeps showing live values.
        // Scheduled post-frame because Riverpod forbids provider mutation
        // during a build phase.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ref
              .read(menuDisplayOptionsProvider.notifier)
              .set(menu?.displayOptions);
          ref
              .read(allowedWidgetsProvider.notifier)
              .set(menu?.allowedWidgets ?? const []);
        });
        final registry = ref.watch(widgetRegistryProvider);
        return AuthenticatedScaffold(
          title: title,
          actions: <Widget>[
            if (state.currentUserId != null)
              PresenceBar(
                presences: state.presences,
                currentUserId: state.currentUserId!,
              ),
            IconButton(
              key: const Key('show_pdf_button'),
              onPressed: state.savingState == MenuSavingState.publishingBundles
                  ? null
                  : _onShowPdfPressed,
              icon: const Icon(Icons.file_present),
              tooltip: 'Show PDF',
            ),
            IconButton(
              key: const Key('save_menu_button'),
              icon: const Icon(Icons.save),
              onPressed: state.savingState == MenuSavingState.saving
                  ? null
                  : _onSavePressed,
              tooltip: 'Save',
            ),
          ],
          body: _buildBody(state, tree, menu, registry),
        );
      },
    );
  }

  Widget _buildBody(
    MenuEditorScreenState state,
    dynamic tree,
    dynamic menu,
    dynamic registry,
  ) {
    final theme = Theme.of(context);
    final pages = (tree.pages as List<entity.Page>)
        .where((page) => page.type == entity.PageType.content)
        .toList();
    return Column(
      children: <Widget>[
        if (state.isReconnecting)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: theme.colorScheme.errorContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Reconnecting...',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < _narrowBreakpoint;
              if (isNarrow) {
                return Column(
                  children: <Widget>[
                    WidgetPalette(
                      axis: Axis.horizontal,
                      registry: registry,
                      allowedWidgets: menu?.allowedWidgets,
                    ),
                    Expanded(child: _buildCanvas(pages, state, registry)),
                  ],
                );
              }
              return Row(
                children: <Widget>[
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
                    child: WidgetPalette(
                      registry: registry,
                      allowedWidgets: menu?.allowedWidgets,
                    ),
                  ),
                  Expanded(child: _buildCanvas(pages, state, registry)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCanvas(
    List<entity.Page> pages,
    MenuEditorScreenState state,
    dynamic registry,
  ) {
    return AutoScrollListener(
      scrollController: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: pages
                    .map((page) => _buildPageCard(page, state, registry))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(
    entity.Page page,
    MenuEditorScreenState state,
    dynamic registry,
  ) {
    final tree = state.tree!;
    final containers = tree.containers[page.id] ?? <entity.Container>[];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: containers
              .map(
                (container) => _buildContainerCard(container, state, registry),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildContainerCard(
    entity.Container container,
    MenuEditorScreenState state,
    dynamic registry,
  ) {
    final tree = state.tree!;
    final columns = tree.columns[container.id] ?? <entity.Column>[];
    final childContainers =
        tree.childContainers[container.id] ?? <entity.Container>[];

    if (childContainers.isNotEmpty) {
      final direction = container.layout?.direction;
      final childWidgets = childContainers
          .map((child) => _buildContainerCard(child, state, registry))
          .toList();

      if (direction == 'row') {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: childWidgets.map((w) => Expanded(child: w)).toList(),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: childWidgets,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (columns.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns
                .map(
                  (column) => Expanded(
                    flex: column.flex ?? 1,
                    child: _buildColumnCard(column, state, registry),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildColumnCard(
    entity.Column column,
    MenuEditorScreenState state,
    dynamic registry,
  ) {
    final tree = state.tree!;
    final widgets = tree.widgets[column.id] ?? const [];
    final menu = tree.menu;
    final allowed = menu.allowedWidgetTypes;
    return EditorColumnCard(
      column: column,
      widgets: widgets,
      registry: registry,
      onWidgetDrop: (type, columnId, index) async {
        if (allowed.isNotEmpty && !allowed.contains(type)) {
          return;
        }
        final definition = registry.getDefinition(type);
        if (definition == null) {
          return;
        }
        final defaultProps =
            (definition.defaultProps as dynamic).toJson()
                as Map<String, dynamic>;
        await widget.viewModel.createWidgetAt(
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
        isEditable: !widgetInstance.lockedForEdition,
        isLocked: widgetInstance.lockedForEdition,
        currentUserId: state.currentUserId,
        editingUserName: widget.viewModel
            .findEditingPresence(widgetInstance)
            ?.userName,
        editingUserAvatar: widget.viewModel
            .findEditingPresence(widgetInstance)
            ?.userAvatar,
        onUpdate: (props) =>
            widget.viewModel.updateWidgetProps(widgetInstance.id, props),
        onDelete: () => _confirmDeleteWidget(widgetInstance.id),
        onEditStarted: () =>
            widget.viewModel.startWidgetEdit(widgetInstance.id),
        onEditEnded: () => widget.viewModel.endWidgetEdit(widgetInstance.id),
        onConfirmDismiss: () =>
            showDeleteConfirmation(context, itemType: 'widget'),
        onDismissed: (id) => widget.viewModel.deleteWidget(id),
      ),
    );
  }

  Future<void> _confirmDeleteWidget(int widgetId) async {
    final confirmed = await showDeleteConfirmation(context, itemType: 'widget');
    if (confirmed != true) return;
    await widget.viewModel.deleteWidget(widgetId);
  }
}
