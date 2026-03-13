import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/offline_error_page.dart';
import 'package:oxo_menus/presentation/widgets/common/presence_bar.dart';
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

  List<MenuPresence> _presences = [];

  StreamSubscription<dynamic>? _changeSubscription;
  StreamSubscription<List<MenuPresence>>? _presenceSubscription;
  Timer? _debounceTimer;
  Timer? _heartbeatTimer;
  Timer? _pollingTimer;
  MenuSubscriptionRepository? _menuSubscriptionRepository;
  PresenceRepository? _presenceRepository;
  String? _currentUserId;
  bool _isReconnecting = false;
  int _wsErrorCount = 0;
  static const _maxWsErrors = 3;
  bool _isPaused = false;
  bool _isLoadingMenu = false;

  late EditorWidgetCrudHelper _crudHelper;

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  /// Look up the presence entry for the user currently editing a widget.
  MenuPresence? _findEditingPresence(WidgetInstance widget) {
    final editingBy = widget.editingBy;
    if (editingBy == null) return null;
    return _presences.where((p) => p.userId == editingBy).firstOrNull;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _crudHelper = EditorWidgetCrudHelper(
      widgetRepository: ref.read(widgetRepositoryProvider),
      widgetRegistry: ref.read(widgetRegistryProvider),
      onReload: _loadMenu,
      isTemplate: false,
      currentUserId: ref.read(currentUserProvider)?.id,
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
      _listenToConnectivityAndLifecycle();
    });
  }

  void _listenToConnectivityAndLifecycle() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOffline = next.value == ConnectivityStatus.offline;
      final isForeground = ref.read(isAppInForegroundProvider);

      if (isOffline && !_isPaused) {
        _pauseSubscriptions();
      } else if (wasOffline && !isOffline && isForeground && _isPaused) {
        _resumeSubscriptions();
      }
    });

    ref.listenManual(isAppInForegroundProvider, (prev, next) {
      final connectivity = ref.read(connectivityProvider);
      final isOnline = connectivity.value != ConnectivityStatus.offline;

      if (!next && !_isPaused) {
        _pauseSubscriptions();
      } else if (next && prev == false && isOnline && _isPaused) {
        _resumeSubscriptions();
      }
    });
  }

  void _pauseSubscriptions() {
    _isPaused = true;
    _debounceTimer?.cancel();
    _heartbeatTimer?.cancel();
    _pollingTimer?.cancel();
    _changeSubscription?.cancel();
    _changeSubscription = null;
    _presenceSubscription?.cancel();
    _presenceSubscription = null;
    _menuSubscriptionRepository?.unsubscribe(widget.menuId);
    _presenceRepository?.unsubscribePresence(widget.menuId);
  }

  void _resumeSubscriptions() {
    _isPaused = false;
    _wsErrorCount = 0;
    if (mounted) {
      setState(() => _isReconnecting = false);
      _subscribeToChanges();
      _startPresenceTracking();
      _loadMenu();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _heartbeatTimer?.cancel();
    _pollingTimer?.cancel();
    _changeSubscription?.cancel();
    _presenceSubscription?.cancel();
    _menuSubscriptionRepository?.unsubscribe(widget.menuId);
    _presenceRepository?.unsubscribePresence(widget.menuId);
    if (_currentUserId != null) {
      _presenceRepository?.leaveMenu(widget.menuId, _currentUserId!);
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu({bool isInitialLoad = false}) async {
    if (_isLoadingMenu && !isInitialLoad) return;
    _isLoadingMenu = true;
    try {
      await _loadMenuImpl(isInitialLoad: isInitialLoad);
    } finally {
      _isLoadingMenu = false;
    }
  }

  Future<void> _loadMenuImpl({bool isInitialLoad = false}) async {
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
    if (!mounted) return;

    if (result.isFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorOrNull?.message ?? 'Failed to load menu';
      });
      return;
    }

    final tree = result.valueOrNull!;
    _menu = tree.menu;
    _pages = tree.pages
        .where((page) => page.type == entity.PageType.content)
        .toList();
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

    // Start WebSocket subscription and presence after first successful load
    if (isInitialLoad) {
      _subscribeToChanges();
      _startPresenceTracking();
    }
  }

  void _subscribeToChanges() {
    _menuSubscriptionRepository = ref.read(menuSubscriptionRepositoryProvider);
    final stream = _menuSubscriptionRepository!.subscribeToMenuChanges(
      widget.menuId,
    );

    _changeSubscription = stream.listen(
      _onChangeEvent,
      onError: _onStreamError,
    );
  }

  Future<void> _startPresenceTracking() async {
    _presenceRepository = ref.read(presenceRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    _currentUserId = currentUser?.id;

    if (_currentUserId != null) {
      final nameParts = [?currentUser?.firstName, ?currentUser?.lastName];
      final displayName = nameParts.isEmpty ? null : nameParts.join(' ');
      await _presenceRepository!.joinMenu(
        widget.menuId,
        _currentUserId!,
        userName: displayName,
        userAvatar: currentUser?.avatar,
      );
      if (!mounted) return;
      _refreshPresences();

      _presenceSubscription = _presenceRepository!
          .watchActiveUsers(widget.menuId)
          .listen((presences) {
            if (mounted) {
              setState(() {
                _presences = presences;
              });
            }
          });

      _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _presenceRepository?.heartbeat(widget.menuId, _currentUserId!);
      });
    }
  }

  Future<void> _refreshPresences() async {
    final result = await _presenceRepository?.getActiveUsers(widget.menuId);
    if (result != null && result.isSuccess && mounted) {
      setState(() {
        _presences = result.valueOrNull ?? [];
      });
    }
  }

  void _onChangeEvent(MenuChangeEvent event) {
    // Clear reconnecting state on successful event
    if (_isReconnecting) {
      setState(() {
        _isReconnecting = false;
        _wsErrorCount = 0;
      });
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadMenu();
      }
    });
  }

  void _onStreamError(Object error) {
    if (!mounted || _isPaused) return;
    _wsErrorCount++;

    setState(() {
      _isReconnecting = true;
    });

    if (_wsErrorCount >= _maxWsErrors) {
      _startPollingFallback();
    }
  }

  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadMenu();
    });
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

    final isOffline =
        ref.watch(connectivityProvider).value == ConnectivityStatus.offline;

    if (isOffline && !_isLoading) {
      return AuthenticatedScaffold(
        title: _menu?.name ?? 'Menu Editor',
        body: OfflineErrorPage(
          onRetry: () => ref.invalidate(connectivityProvider),
        ),
      );
    }

    if (_errorMessage != null) {
      return AuthenticatedScaffold(
        title: 'Error',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isApple
                    ? CupertinoIcons.exclamationmark_triangle
                    : Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $_errorMessage'.substring(
                  0,
                  'Error: $_errorMessage'.length.clamp(0, 200),
                ),
              ),
              const SizedBox(height: 16),
              if (_isApple)
                CupertinoButton.filled(
                  onPressed: () => _loadMenu(isInitialLoad: true),
                  child: const Text('Retry'),
                )
              else
                FilledButton(
                  onPressed: () => _loadMenu(isInitialLoad: true),
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      );
    }

    final registry = ref.watch(widgetRegistryProvider);
    final theme = Theme.of(context);

    return AuthenticatedScaffold(
      title: _menu?.name ?? 'Menu Editor',
      actions: [
        if (_currentUserId != null)
          PresenceBar(presences: _presences, currentUserId: _currentUserId!),
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
      body: Column(
        children: [
          if (_isReconnecting)
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
                          right: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
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
          ),
        ],
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
                  currentUserId: ref.read(currentUserProvider)?.id,
                  editingUserName: _findEditingPresence(widgets[i])?.userName,
                  editingUserAvatar: _findEditingPresence(
                    widgets[i],
                  )?.userAvatar,
                  onUpdate: (props) =>
                      _handleWidgetUpdate(widgets[i].id, props),
                  onDelete: () => _handleWidgetDelete(widgets[i].id),
                  onEditStarted: () => _crudHelper.lockWidget(widgets[i].id),
                  onEditEnded: () => _crudHelper.unlockWidget(widgets[i].id),
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
                currentUserId: ref.read(currentUserProvider)?.id,
                editingUserName: _findEditingPresence(widget)?.userName,
                editingUserAvatar: _findEditingPresence(widget)?.userAvatar,
                onUpdate: (props) => _handleWidgetUpdate(widget.id, props),
                onDelete: () => _handleWidgetDelete(widget.id),
                onEditStarted: () => _crudHelper.lockWidget(widget.id),
                onEditEnded: () => _crudHelper.unlockWidget(widget.id),
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
