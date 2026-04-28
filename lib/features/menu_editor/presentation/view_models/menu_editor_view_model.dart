import 'dart:async';

import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/editor_tree_data.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/create_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/delete_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/load_menu_for_editor_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/lock_widget_for_editing_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/menu_presence_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/move_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/publish_exportable_bundles_for_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/save_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/unlock_widget_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/update_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/watch_menu_changes_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/menu_editor_screen_state.dart';

/// Outcome surfaced to the screen by the "Show PDF" action.
///
/// The screen uses this to display a single SnackBar summarising the
/// background bundle re-publish outcome before navigating to the PDF preview.
final class PublishBundlesOutcome {
  const PublishBundlesOutcome({
    required this.totalCount,
    required this.failureCount,
    this.firstFailureMessage,
  });

  final int totalCount;
  final int failureCount;
  final String? firstFailureMessage;

  bool get isEmpty => totalCount == 0;
  bool get hasFailures => failureCount > 0;
}

/// View model owning the migrated menu editor state.
///
/// Combines what the legacy `editor_tree_notifier`, `menu_collaboration_notifier`
/// and `menu_settings_notifier` (just `saveMenu`) covered into a single pure-
/// Dart object. Knows nothing about widgets, `BuildContext`, or Riverpod —
/// navigation is delegated to [MenuEditorRouter].
///
/// Lifecycle:
/// - On construction the VM stamps the auth-snapshot user id, kicks off the
///   tree load and starts WebSocket + presence tracking.
/// - The screen forwards lifecycle transitions (`onAppLifecycleChanged`) so
///   the VM can pause / resume the WS+presence subscriptions when the app
///   backgrounds. Connectivity transitions are handled internally via the
///   gateway's stream.
/// - On dispose every timer, subscription, and presence is cleaned up.
class MenuEditorViewModel extends ViewModel<MenuEditorScreenState> {
  MenuEditorViewModel({
    required int menuId,
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    required MenuEditorRouter router,
    required PresentableWidgetRegistry registry,
    required LoadMenuForEditorUseCase loadMenu,
    required CreateWidgetInMenuUseCase createWidget,
    required UpdateWidgetInMenuUseCase updateWidget,
    required DeleteWidgetInMenuUseCase deleteWidget,
    required MoveWidgetInMenuUseCase moveWidget,
    required LockWidgetForEditingUseCase lockWidget,
    required UnlockWidgetUseCase unlockWidget,
    required SaveMenuUseCase saveMenu,
    required PublishExportableBundlesForMenuUseCase publishBundles,
    required WatchMenuChangesUseCase watchChanges,
    required MenuPresenceUseCase presence,
    ImageGateway? imageGateway,
  }) : _menuId = menuId,
       _authGateway = authGateway,
       _connectivityGateway = connectivityGateway,
       _router = router,
       _registry = registry,
       _imageGateway = imageGateway,
       _loadMenu = loadMenu,
       _createWidget = createWidget,
       _updateWidget = updateWidget,
       _deleteWidget = deleteWidget,
       _moveWidget = moveWidget,
       _lockWidget = lockWidget,
       _unlockWidget = unlockWidget,
       _saveMenu = saveMenu,
       _publishBundles = publishBundles,
       _watchChanges = watchChanges,
       _presence = presence,
       _lastConnectivity = connectivityGateway.currentStatus,
       super(_initialState(authGateway, connectivityGateway)) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
    unawaited(_load());
    _startCollabTracking();
  }

  static const _maxWsErrors = 3;
  static const _heartbeatInterval = Duration(seconds: 30);
  static const _pollingInterval = Duration(seconds: 30);
  static const _changeDebounce = Duration(milliseconds: 500);

  final int _menuId;
  final AuthGateway _authGateway;
  final ConnectivityGateway _connectivityGateway;
  final MenuEditorRouter _router;
  final PresentableWidgetRegistry _registry;
  final ImageGateway? _imageGateway;

  /// Registry the screen passes to `WidgetRenderer`/`DraggableWidgetItem` so
  /// they can look up widget definitions without reaching into Riverpod.
  PresentableWidgetRegistry get registry => _registry;

  /// Gateway used by the `image` widget type for byte loading. Optional —
  /// tests that don't exercise image rendering omit it.
  ImageGateway? get imageGateway => _imageGateway;

  final LoadMenuForEditorUseCase _loadMenu;
  final CreateWidgetInMenuUseCase _createWidget;
  final UpdateWidgetInMenuUseCase _updateWidget;
  final DeleteWidgetInMenuUseCase _deleteWidget;
  final MoveWidgetInMenuUseCase _moveWidget;
  final LockWidgetForEditingUseCase _lockWidget;
  final UnlockWidgetUseCase _unlockWidget;
  final SaveMenuUseCase _saveMenu;
  final PublishExportableBundlesForMenuUseCase _publishBundles;
  final WatchMenuChangesUseCase _watchChanges;
  final MenuPresenceUseCase _presence;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _lastConnectivity;
  bool _isAppInForeground = true;

  StreamSubscription<MenuChangeEvent>? _changeSubscription;
  StreamSubscription<List<MenuPresence>>? _presenceSubscription;
  Timer? _changeDebounceTimer;
  Timer? _heartbeatTimer;
  Timer? _pollingTimer;

  static MenuEditorScreenState _initialState(
    AuthGateway gateway,
    ConnectivityGateway connectivityGateway,
  ) => MenuEditorScreenState(
    currentUserId: gateway.currentUser?.id,
    isOffline: connectivityGateway.currentStatus == ConnectivityStatus.offline,
  );

  /// Reload the menu tree. Used by the retry button and by the
  /// connectivity-restore listener.
  Future<void> reload() => _load();

  /// Re-probe connectivity through the gateway. Used by the offline error
  /// page's retry button to force a fresh probe rather than wait for the
  /// next ambient transition.
  Future<void> retryConnectivity() => _connectivityGateway.recheck();

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    emit(state.copyWith(errorMessage: null));
  }

  // ----------------------------------------------------------- Widget CRUD

  /// Drop a new widget into [columnId] at [index].
  ///
  /// Returns the result so the screen can surface a typed error message
  /// without poking at the state directly.
  Future<Result<WidgetInstance, DomainError>> createWidgetAt({
    required String type,
    required String version,
    required Map<String, dynamic> defaultProps,
    required int columnId,
    required int index,
  }) async {
    final result = await _createWidget.execute(
      CreateWidgetInput(
        columnId: columnId,
        type: type,
        version: version,
        index: index,
        props: defaultProps,
      ),
    );
    if (isDisposed) {
      return result;
    }
    if (result.isSuccess) {
      await _load(showSpinner: false);
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  Future<Result<WidgetInstance, DomainError>> updateWidgetProps(
    int widgetId,
    Map<String, dynamic> props,
  ) async {
    final result = await _updateWidget.execute(
      UpdateWidgetInput(id: widgetId, props: props),
    );
    if (isDisposed) {
      return result;
    }
    if (result.isSuccess) {
      await _load(showSpinner: false);
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  Future<Result<void, DomainError>> deleteWidget(int widgetId) async {
    final tree = state.tree;
    if (tree != null) {
      emit(state.copyWith(tree: _treeWithoutWidget(tree, widgetId)));
    }
    final result = await _deleteWidget.execute(widgetId);
    if (isDisposed) {
      return result;
    }
    await _load(showSpinner: false);
    if (result.isFailure) {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  Future<Result<void, DomainError>> moveWidget({
    required WidgetInstance widget,
    required int sourceColumnId,
    required int targetColumnId,
    required int targetIndex,
  }) async {
    final result = await _moveWidget.execute(
      MoveWidgetInput(
        widget: widget,
        sourceColumnId: sourceColumnId,
        targetColumnId: targetColumnId,
        targetIndex: targetIndex,
      ),
    );
    if (isDisposed) {
      return result;
    }
    if (result.isSuccess) {
      await _load(showSpinner: false);
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  /// Mark a widget as being edited by the current user — fire-and-forget; if
  /// the lock fails the next save round-trip surfaces the error.
  void startWidgetEdit(int widgetId) {
    final userId = _authGateway.currentUser?.id;
    if (userId == null) {
      return;
    }
    unawaited(
      _lockWidget.execute(
        LockWidgetForEditingInput(widgetId: widgetId, userId: userId),
      ),
    );
  }

  void endWidgetEdit(int widgetId) {
    unawaited(_unlockWidget.execute(widgetId));
  }

  // ----------------------------------------------------------- Save / PDF

  Future<void> saveMenu() async {
    emit(state.copyWith(savingState: MenuSavingState.saving));
    final result = await _saveMenu.execute(_menuId);
    if (isDisposed) {
      return;
    }
    if (result.isFailure) {
      emit(
        state.copyWith(
          savingState: MenuSavingState.idle,
          errorMessage: result.errorOrNull!.message,
        ),
      );
      return;
    }
    emit(state.copyWith(savingState: MenuSavingState.idle));
  }

  /// Re-publish every exportable-menu bundle that includes this menu in the
  /// background. Screen consumes the outcome to display a SnackBar — the call
  /// returns immediately after kicking off the work and exposes a future the
  /// caller can `await` for the full report.
  ///
  /// Navigation to the PDF preview happens immediately — the publish report
  /// arrives whenever it arrives.
  Future<PublishBundlesOutcome> publishBundlesAndPreviewPdf() {
    final outcome = _publishBundlesInBackground();
    _router.goToPdfPreview(_menuId);
    return outcome;
  }

  Future<PublishBundlesOutcome> _publishBundlesInBackground() async {
    emit(state.copyWith(savingState: MenuSavingState.publishingBundles));
    final results = await _publishBundles.execute(_menuId);
    if (isDisposed) {
      return PublishBundlesOutcome(
        totalCount: results.length,
        failureCount: results.where((r) => r.isFailure).length,
      );
    }
    emit(state.copyWith(savingState: MenuSavingState.idle));
    final failures = results.where((r) => r.isFailure).toList();
    return PublishBundlesOutcome(
      totalCount: results.length,
      failureCount: failures.length,
      firstFailureMessage: failures.isEmpty
          ? null
          : failures.first.errorOrNull?.message ?? 'Unknown error',
    );
  }

  // ----------------------------------------------------------- Lifecycle

  /// Forward the screen's lifecycle observation to the VM. The screen owns
  /// the `WidgetsBindingObserver`; the VM owns the pause/resume decision.
  void onAppLifecycleChanged(bool isInForeground) {
    if (isDisposed) {
      return;
    }
    final wasInForeground = _isAppInForeground;
    _isAppInForeground = isInForeground;
    final isOnline = _lastConnectivity != ConnectivityStatus.offline;
    if (!isInForeground && !state.isPaused) {
      _pauseSubscriptions();
      return;
    }
    if (isInForeground && !wasInForeground && isOnline && state.isPaused) {
      _resumeSubscriptions();
    }
  }

  // ----------------------------------------------------------- Navigation

  void goBack() => _router.goBack();

  // ----------------------------------------------------------- Internals

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    final result = await _loadMenu.execute(_menuId);
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (tree) {
        emit(state.copyWith(isLoading: false, tree: tree, errorMessage: null));
      },
      onFailure: (error) {
        emit(state.copyWith(isLoading: false, errorMessage: error.message));
      },
    );
  }

  void _startCollabTracking() {
    _subscribeToChanges();
    unawaited(_startPresenceTracking());
  }

  void _subscribeToChanges() {
    _changeSubscription?.cancel();
    _changeSubscription = _watchChanges
        .execute(_menuId)
        .listen(_onChangeEvent, onError: _onStreamError);
  }

  Future<void> _startPresenceTracking() async {
    final user = _authGateway.currentUser;
    final userId = user?.id;
    if (userId == null) {
      return;
    }
    final nameParts = <String>[];
    if (user?.firstName != null && user!.firstName!.isNotEmpty) {
      nameParts.add(user.firstName!);
    }
    if (user?.lastName != null && user!.lastName!.isNotEmpty) {
      nameParts.add(user.lastName!);
    }
    final displayName = nameParts.isEmpty ? null : nameParts.join(' ');
    await _presence.join(
      _menuId,
      userId,
      userName: displayName,
      userAvatar: user?.avatar,
    );
    if (isDisposed) {
      return;
    }
    await _refreshPresences();
    if (isDisposed) {
      return;
    }
    _presenceSubscription?.cancel();
    _presenceSubscription = _presence.watch(_menuId).listen((presences) {
      if (isDisposed) {
        return;
      }
      emit(state.copyWith(presences: presences));
    });
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      _presence.heartbeat(_menuId, userId);
    });
  }

  Future<void> _refreshPresences() async {
    final result = await _presence.getActive(_menuId);
    if (isDisposed) {
      return;
    }
    if (result.isSuccess) {
      emit(state.copyWith(presences: result.valueOrNull ?? const []));
    }
  }

  void _onChangeEvent(MenuChangeEvent event) {
    if (state.isReconnecting) {
      emit(state.copyWith(isReconnecting: false, wsErrorCount: 0));
    }
    _changeDebounceTimer?.cancel();
    _changeDebounceTimer = Timer(_changeDebounce, _reloadFromCollab);
  }

  void _onStreamError(Object error) {
    if (state.isPaused) {
      return;
    }
    final next = state.wsErrorCount + 1;
    emit(state.copyWith(isReconnecting: true, wsErrorCount: next));
    if (next >= _maxWsErrors) {
      _startPollingFallback();
    }
  }

  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      _pollingInterval,
      (_) => _reloadFromCollab(),
    );
  }

  Future<void> _reloadFromCollab() async {
    if (isDisposed || state.isReloadingMenu) {
      return;
    }
    emit(state.copyWith(isReloadingMenu: true));
    try {
      await _load(showSpinner: false);
    } finally {
      if (!isDisposed) {
        emit(state.copyWith(isReloadingMenu: false));
      }
    }
  }

  void _onConnectivityChanged(ConnectivityStatus next) {
    if (isDisposed) {
      return;
    }
    final wasOffline = _lastConnectivity == ConnectivityStatus.offline;
    _lastConnectivity = next;
    final isOffline = next == ConnectivityStatus.offline;
    if (state.isOffline != isOffline) {
      emit(state.copyWith(isOffline: isOffline));
    }
    if (isOffline && !state.isPaused) {
      _pauseSubscriptions();
      return;
    }
    if (wasOffline && !isOffline && _isAppInForeground && state.isPaused) {
      _resumeSubscriptions();
      unawaited(_load(showSpinner: false));
    }
  }

  void _pauseSubscriptions() {
    emit(state.copyWith(isPaused: true));
    _changeDebounceTimer?.cancel();
    _heartbeatTimer?.cancel();
    _pollingTimer?.cancel();
    _changeSubscription?.cancel();
    _changeSubscription = null;
    _presenceSubscription?.cancel();
    _presenceSubscription = null;
    unawaited(_watchChanges.cancel(_menuId));
    unawaited(_presence.cancel(_menuId));
  }

  void _resumeSubscriptions() {
    emit(
      state.copyWith(isPaused: false, isReconnecting: false, wsErrorCount: 0),
    );
    _subscribeToChanges();
    unawaited(_startPresenceTracking());
    unawaited(_reloadFromCollab());
  }

  /// Returns the [MenuPresence] for the user currently editing [widget], if
  /// any. The screen uses this to render the editing badge over locked
  /// widgets.
  MenuPresence? findEditingPresence(WidgetInstance widget) {
    final editingBy = widget.editingBy;
    if (editingBy == null) {
      return null;
    }
    for (final p in state.presences) {
      if (p.userId == editingBy) {
        return p;
      }
    }
    return null;
  }

  @override
  void onDispose() {
    _changeDebounceTimer?.cancel();
    _heartbeatTimer?.cancel();
    _pollingTimer?.cancel();
    _changeSubscription?.cancel();
    _presenceSubscription?.cancel();
    unawaited(_watchChanges.cancel(_menuId));
    unawaited(_presence.cancel(_menuId));
    final userId = _authGateway.currentUser?.id;
    if (userId != null) {
      unawaited(_presence.leave(_menuId, userId));
    }
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }

  // -------------------------- tree helpers (immutable updates) ----------

  static EditorTreeData _treeWithoutWidget(EditorTreeData tree, int widgetId) {
    final updated = <int, List<WidgetInstance>>{};
    for (final entry in tree.widgets.entries) {
      updated[entry.key] = entry.value.where((w) => w.id != widgetId).toList();
    }
    return EditorTreeData(
      menu: tree.menu,
      pages: tree.pages,
      headerPage: tree.headerPage,
      footerPage: tree.footerPage,
      containers: tree.containers,
      childContainers: tree.childContainers,
      columns: tree.columns,
      widgets: updated,
    );
  }
}
