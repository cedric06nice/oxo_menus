import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_provider.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_state.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/state/menu_collaboration_provider.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/state/menu_collaboration_state.dart';
import 'package:oxo_menus/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_error_state.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_loading_indicator.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/offline_error_page.dart';
import 'package:oxo_menus/presentation/widgets/common/presence_bar.dart';
import 'package:oxo_menus/presentation/widgets/editor/auto_scroll_listener.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:oxo_menus/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_column_card.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/pdf_display_options_dialog.dart';
import 'package:oxo_menus/presentation/theme/app_spacing.dart';

class MenuEditorPage extends ConsumerStatefulWidget {
  final int menuId;

  const MenuEditorPage({super.key, required this.menuId});

  @override
  ConsumerState<MenuEditorPage> createState() => _MenuEditorPageState();
}

class _MenuEditorPageState extends ConsumerState<MenuEditorPage> {
  static const narrowBreakpoint = AppBreakpoints.mobile;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editorTreeProvider(widget.menuId).notifier).loadTree();
      ref
          .read(menuCollaborationProvider(widget.menuId).notifier)
          .startTracking();
      _listenForDisplayOptions();
      _listenToConnectivityAndLifecycle();
    });
  }

  void _listenForDisplayOptions() {
    ref.listenManual(editorTreeProvider(widget.menuId), (prev, next) {
      if (next.menu != null && next.menu != prev?.menu) {
        ref
            .read(menuDisplayOptionsProvider.notifier)
            .set(next.menu?.displayOptions);
      }
    });
  }

  void _listenToConnectivityAndLifecycle() {
    ref.listenManual(connectivityProvider, (prev, next) {
      ref
          .read(menuCollaborationProvider(widget.menuId).notifier)
          .onConnectivityChanged(prev?.value, next.value);
    });

    ref.listenManual(isAppInForegroundProvider, (prev, next) {
      ref
          .read(menuCollaborationProvider(widget.menuId).notifier)
          .onLifecycleChanged(prev, next);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showPdf() async {
    final options = await showDialog<MenuDisplayOptions>(
      context: context,
      builder: (_) => const PdfDisplayOptionsDialog(),
    );
    if (options != null && mounted) {
      context.push('/menus/pdf/${widget.menuId}', extra: options);
    }
  }

  Future<void> _saveMenu() async {
    final result = await ref
        .read(menuSettingsProvider.notifier)
        .saveMenu(widget.menuId);

    if (result.isSuccess && mounted) {
      showThemedSnackBar(context, 'Menu saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final treeState = ref.watch(editorTreeProvider(widget.menuId));
    final collabState = ref.watch(menuCollaborationProvider(widget.menuId));

    if (treeState.isLoading) {
      return const AuthenticatedScaffold(
        title: 'Loading...',
        body: Center(child: AdaptiveLoadingIndicator()),
      );
    }

    final isOffline =
        ref.watch(connectivityProvider).value == ConnectivityStatus.offline;

    if (isOffline) {
      return AuthenticatedScaffold(
        title: treeState.menu?.name ?? 'Menu Editor',
        body: OfflineErrorPage(
          onRetry: () => ref.invalidate(connectivityProvider),
        ),
      );
    }

    if (treeState.errorMessage != null) {
      return AuthenticatedScaffold(
        title: 'Error',
        body: AdaptiveErrorState(
          message: treeState.errorMessage!,
          onRetry: () =>
              ref.read(editorTreeProvider(widget.menuId).notifier).loadTree(),
        ),
      );
    }

    final registry = ref.watch(widgetRegistryProvider);
    final theme = Theme.of(context);
    final menu = treeState.menu;
    final pages = treeState.pages
        .where((page) => page.type == entity.PageType.content)
        .toList();

    return AuthenticatedScaffold(
      title: menu?.name ?? 'Menu Editor',
      actions: [
        if (collabState.currentUserId != null)
          PresenceBar(
            presences: collabState.presences,
            currentUserId: collabState.currentUserId!,
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
      body: Column(
        children: [
          if (collabState.isReconnecting)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: theme.colorScheme.errorContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                final isNarrow = constraints.maxWidth < narrowBreakpoint;

                if (isNarrow) {
                  return Column(
                    children: [
                      WidgetPalette(
                        axis: Axis.horizontal,
                        registry: registry,
                        allowedWidgetTypes: menu?.allowedWidgetTypes,
                      ),
                      Expanded(
                        child: _buildCanvas(pages, treeState, collabState),
                      ),
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
                      child: WidgetPalette(
                        registry: registry,
                        allowedWidgetTypes: menu?.allowedWidgetTypes,
                      ),
                    ),
                    Expanded(
                      child: _buildCanvas(pages, treeState, collabState),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(
    List<entity.Page> pages,
    EditorTreeState treeState,
    MenuCollaborationState collabState,
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
                    .map((page) => _buildPageCard(page, treeState, collabState))
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
    EditorTreeState treeState,
    MenuCollaborationState collabState,
  ) {
    final containers = treeState.containers[page.id] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...containers.map(
              (container) =>
                  _buildContainerCard(container, treeState, collabState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard(
    entity.Container container,
    EditorTreeState treeState,
    MenuCollaborationState collabState,
  ) {
    final columns = treeState.columns[container.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (columns.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns
                .map(
                  (column) => Expanded(
                    flex: column.flex ?? 1,
                    child: _buildColumnCard(column, treeState, collabState),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildColumnCard(
    entity.Column column,
    EditorTreeState treeState,
    MenuCollaborationState collabState,
  ) {
    final widgets = treeState.widgets[column.id] ?? [];
    final registry = ref.watch(widgetRegistryProvider);
    final collabNotifier = ref.read(
      menuCollaborationProvider(widget.menuId).notifier,
    );

    return EditorColumnCard(
      column: column,
      widgets: widgets,
      registry: registry,
      onWidgetDrop: _handleWidgetDropAtIndex,
      onWidgetMove: _handleWidgetMoveToIndex,
      widgetItemBuilder: (widgetInstance, columnId) => DraggableWidgetItem(
        widgetInstance: widgetInstance,
        columnId: columnId,
        isEditable: !widgetInstance.isTemplate,
        isLocked: widgetInstance.isTemplate,
        currentUserId: ref.read(currentUserProvider)?.id,
        editingUserName: collabNotifier
            .findEditingPresence(widgetInstance)
            ?.userName,
        editingUserAvatar: collabNotifier
            .findEditingPresence(widgetInstance)
            ?.userAvatar,
        onUpdate: (props) => _handleWidgetUpdate(widgetInstance.id, props),
        onDelete: () => _handleWidgetDelete(widgetInstance.id),
        onEditStarted: () {
          final userId = ref.read(currentUserProvider)?.id;
          if (userId != null) {
            ref
                .read(editorTreeProvider(widget.menuId).notifier)
                .lockWidget(widgetInstance.id, userId);
          }
        },
        onEditEnded: () => ref
            .read(editorTreeProvider(widget.menuId).notifier)
            .unlockWidget(widgetInstance.id),
        onConfirmDismiss: () =>
            showDeleteConfirmation(context, itemType: 'widget'),
        onDismissed: (id) => _performWidgetDelete(id),
      ),
    );
  }

  Future<void> _handleWidgetDropAtIndex(
    String widgetType,
    int columnId,
    int index,
  ) async {
    final treeState = ref.read(editorTreeProvider(widget.menuId));
    final allowed = treeState.menu?.allowedWidgetTypes;
    if (allowed != null &&
        allowed.isNotEmpty &&
        !allowed.contains(widgetType)) {
      return;
    }
    final notifier = ref.read(editorTreeProvider(widget.menuId).notifier);
    final result = await notifier.createWidget(widgetType, columnId, index);
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
    final confirmed = await showDeleteConfirmation(context, itemType: 'widget');
    if (confirmed != true) return;

    await _performWidgetDelete(widgetId);
  }
}
