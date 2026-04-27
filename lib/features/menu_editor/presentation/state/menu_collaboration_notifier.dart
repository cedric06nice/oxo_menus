import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/editor_tree/presentation/state/editor_tree_provider.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/menu_collaboration_state.dart';
import 'package:oxo_menus/shared/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

class MenuCollaborationNotifier extends Notifier<MenuCollaborationState> {
  MenuCollaborationNotifier(this.menuId);

  final int menuId;
  static const _maxWsErrors = 3;

  StreamSubscription<dynamic>? _changeSubscription;
  StreamSubscription<List<MenuPresence>>? _presenceSubscription;
  Timer? _debounceTimer;
  Timer? _heartbeatTimer;
  Timer? _pollingTimer;
  // Cached for cleanup — state is inaccessible during onDispose
  String? _cachedUserId;

  late MenuSubscriptionRepository _subRepo;
  late PresenceRepository _presenceRepo;

  @override
  MenuCollaborationState build() {
    _subRepo = ref.read(menuSubscriptionRepositoryProvider);
    _presenceRepo = ref.read(presenceRepositoryProvider);
    ref.onDispose(_cleanup);
    return const MenuCollaborationState();
  }

  Future<void> startTracking() async {
    _subscribeToChanges();
    await _startPresenceTracking();
  }

  void _subscribeToChanges() {
    final repo = _subRepo;
    final stream = repo.subscribeToMenuChanges(menuId);

    _changeSubscription = stream.listen(
      _onChangeEvent,
      onError: _onStreamError,
    );
  }

  Future<void> _startPresenceTracking() async {
    final presenceRepo = _presenceRepo;
    final currentUser = ref.read(currentUserProvider);
    final userId = currentUser?.id;

    _cachedUserId = userId;
    state = state.copyWith(currentUserId: userId);

    if (userId != null) {
      final nameParts = [?currentUser?.firstName, ?currentUser?.lastName];
      final displayName = nameParts.isEmpty ? null : nameParts.join(' ');
      await presenceRepo.joinMenu(
        menuId,
        userId,
        userName: displayName,
        userAvatar: currentUser?.avatar,
      );

      await _refreshPresences();

      _presenceSubscription = presenceRepo.watchActiveUsers(menuId).listen((
        presences,
      ) {
        state = state.copyWith(presences: presences);
      });

      _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        presenceRepo.heartbeat(menuId, userId);
      });
    }
  }

  Future<void> _refreshPresences() async {
    final presenceRepo = _presenceRepo;
    final result = await presenceRepo.getActiveUsers(menuId);
    if (result.isSuccess) {
      state = state.copyWith(presences: result.valueOrNull ?? []);
    }
  }

  void _onChangeEvent(MenuChangeEvent event) {
    if (state.isReconnecting) {
      state = state.copyWith(isReconnecting: false, wsErrorCount: 0);
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _reloadTree();
    });
  }

  void _onStreamError(Object error) {
    if (state.isPaused) return;
    final newCount = state.wsErrorCount + 1;

    state = state.copyWith(isReconnecting: true, wsErrorCount: newCount);

    if (newCount >= _maxWsErrors) {
      _startPollingFallback();
    }
  }

  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _reloadTree();
    });
  }

  void onConnectivityChanged(
    ConnectivityStatus? prev,
    ConnectivityStatus? next,
  ) {
    final isOffline = next == ConnectivityStatus.offline;
    final wasOffline = prev == ConnectivityStatus.offline;
    final isForeground = ref.read(isAppInForegroundProvider);

    if (isOffline && !state.isPaused) {
      _pauseSubscriptions();
    } else if (wasOffline && !isOffline && isForeground && state.isPaused) {
      _resumeSubscriptions();
    }
  }

  void onLifecycleChanged(bool? prev, bool next) {
    final connectivity = ref.read(connectivityProvider);
    final isOnline = connectivity.value != ConnectivityStatus.offline;

    if (!next && !state.isPaused) {
      _pauseSubscriptions();
    } else if (next && prev == false && isOnline && state.isPaused) {
      _resumeSubscriptions();
    }
  }

  void _pauseSubscriptions() {
    state = state.copyWith(isPaused: true);
    _debounceTimer?.cancel();
    _heartbeatTimer?.cancel();
    _pollingTimer?.cancel();
    _changeSubscription?.cancel();
    _changeSubscription = null;
    _presenceSubscription?.cancel();
    _presenceSubscription = null;
    _subRepo.unsubscribe(menuId);
    _presenceRepo.unsubscribePresence(menuId);
  }

  void _resumeSubscriptions() {
    state = state.copyWith(
      isPaused: false,
      isReconnecting: false,
      wsErrorCount: 0,
    );
    _subscribeToChanges();
    _startPresenceTracking();
    _reloadTree();
  }

  Future<void> _reloadTree() async {
    if (state.isLoadingMenu) return;
    state = state.copyWith(isLoadingMenu: true);
    try {
      await ref.read(editorTreeProvider(menuId).notifier).loadTree();
    } finally {
      state = state.copyWith(isLoadingMenu: false);
    }
  }

  MenuPresence? findEditingPresence(WidgetInstance widget) {
    final editingBy = widget.editingBy;
    if (editingBy == null) return null;
    return state.presences.where((p) => p.userId == editingBy).firstOrNull;
  }

  void _cleanup() {
    _debounceTimer?.cancel();
    _heartbeatTimer?.cancel();
    _pollingTimer?.cancel();
    _changeSubscription?.cancel();
    _presenceSubscription?.cancel();
    _subRepo.unsubscribe(menuId);
    _presenceRepo.unsubscribePresence(menuId);
    final userId = _cachedUserId;
    if (userId != null) {
      _presenceRepo.leaveMenu(menuId, userId);
    }
  }
}
