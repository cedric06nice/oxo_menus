import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/menu_collaboration_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/editor_tree_loader.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/editor_tree_loader_provider.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_menu_subscription_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_presence_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';

// ---------------------------------------------------------------------------
// Inline fake: EditorTreeLoader that never delegates to real repositories
// ---------------------------------------------------------------------------

/// Overrides [loadTree] so that [MenuCollaborationNotifier._reloadTree] does
/// not need real repositories wired up.  The constructor still receives typed
/// stubs so it satisfies the parent's required parameters.
class _FakeEditorTreeLoader extends EditorTreeLoader {
  _FakeEditorTreeLoader({
    required FakeMenuRepository menuRepo,
    required FakePageRepository pageRepo,
    required FakeContainerRepository containerRepo,
    required FakeColumnRepository columnRepo,
    required FakeWidgetRepository widgetRepo,
  }) : super(
         menuRepository: menuRepo,
         pageRepository: pageRepo,
         containerRepository: containerRepo,
         columnRepository: columnRepo,
         widgetRepository: widgetRepo,
       );

  int loadTreeCallCount = 0;
  Result<EditorTree, DomainError>? _stub;

  void stubLoadTree(Result<EditorTree, DomainError> result) {
    _stub = result;
  }

  @override
  Future<Result<EditorTree, DomainError>> loadTree(int menuId) async {
    loadTreeCallCount++;
    if (_stub != null) return _stub!;
    // Default: return a minimal tree so _reloadTree completes without error.
    return const Success(
      EditorTree(
        menu: Menu(
          id: 1,
          name: 'Test Menu',
          status: Status.draft,
          version: '1',
        ),
        pages: [],
        containers: {},
        columns: {},
        widgets: {},
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared test constants
// ---------------------------------------------------------------------------

const _menuId = 1;
const _testUser = User(id: 'user-1', email: 'test@example.com');

final _testPresence = MenuPresence(
  id: 1,
  userId: 'user-1',
  menuId: _menuId,
  lastSeen: DateTime(2024, 1, 1),
  userName: 'Test User',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeMenuSubscriptionRepository fakeSubRepo;
  late FakePresenceRepository fakePresenceRepo;
  late _FakeEditorTreeLoader fakeLoader;

  void setupDefaultPresenceStubs() {
    fakePresenceRepo.whenJoinMenu(const Success(null));
    fakePresenceRepo.whenGetActiveUsers(_menuId, const Success([]));
    fakePresenceRepo.whenLeaveMenu(const Success(null));
  }

  setUp(() {
    fakeSubRepo = FakeMenuSubscriptionRepository();
    fakePresenceRepo = FakePresenceRepository();
    fakeLoader = _FakeEditorTreeLoader(
      menuRepo: FakeMenuRepository(),
      pageRepo: FakePageRepository(),
      containerRepo: FakeContainerRepository(),
      columnRepo: FakeColumnRepository(),
      widgetRepo: FakeWidgetRepository(),
    );
    setupDefaultPresenceStubs();
  });

  tearDown(() {
    fakeSubRepo.dispose();
    fakePresenceRepo.dispose();
  });

  ProviderContainer createContainer({
    User? currentUser = _testUser,
    bool isForeground = true,
    AsyncValue<ConnectivityStatus>? connectivity,
  }) {
    return ProviderContainer(
      overrides: [
        menuSubscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
        presenceRepositoryProvider.overrideWithValue(fakePresenceRepo),
        currentUserProvider.overrideWithValue(currentUser),
        isAppInForegroundProvider.overrideWithValue(isForeground),
        editorTreeLoaderProvider.overrideWithValue(fakeLoader),
        if (connectivity != null)
          connectivityProvider.overrideWithValue(connectivity),
      ],
    );
  }

  /// Creates a container, calls [startTracking], and returns it ready for
  /// further assertions.
  Future<ProviderContainer> startAndTrack({
    User? currentUser = _testUser,
    bool isForeground = true,
    AsyncValue<ConnectivityStatus>? connectivity,
  }) async {
    final container = createContainer(
      currentUser: currentUser,
      isForeground: isForeground,
      connectivity: connectivity,
    );
    await container
        .read(menuCollaborationProvider(_menuId).notifier)
        .startTracking();
    return container;
  }

  group('MenuCollaborationNotifier', () {
    // -----------------------------------------------------------------------
    group('initial state', () {
      test('should have empty presences list', () {
        final container = createContainer();
        addTearDown(container.dispose);

        expect(
          container.read(menuCollaborationProvider(_menuId)).presences,
          isEmpty,
        );
      });

      test('should have isReconnecting false', () {
        final container = createContainer();
        addTearDown(container.dispose);

        expect(
          container.read(menuCollaborationProvider(_menuId)).isReconnecting,
          isFalse,
        );
      });

      test('should have isPaused false', () {
        final container = createContainer();
        addTearDown(container.dispose);

        expect(
          container.read(menuCollaborationProvider(_menuId)).isPaused,
          isFalse,
        );
      });

      test('should have null currentUserId', () {
        final container = createContainer();
        addTearDown(container.dispose);

        expect(
          container.read(menuCollaborationProvider(_menuId)).currentUserId,
          isNull,
        );
      });

      test('should have wsErrorCount of zero', () {
        final container = createContainer();
        addTearDown(container.dispose);

        expect(
          container.read(menuCollaborationProvider(_menuId)).wsErrorCount,
          0,
        );
      });

      test('should have isLoadingMenu false', () {
        final container = createContainer();
        addTearDown(container.dispose);

        expect(
          container.read(menuCollaborationProvider(_menuId)).isLoadingMenu,
          isFalse,
        );
      });
    });

    // -----------------------------------------------------------------------
    group('startTracking', () {
      test('should set currentUserId to the logged-in user id', () async {
        final container = await startAndTrack();
        addTearDown(container.dispose);

        expect(
          container.read(menuCollaborationProvider(_menuId)).currentUserId,
          'user-1',
        );
      });

      test('should call joinMenu with the correct menuId and userId', () async {
        final container = await startAndTrack();
        addTearDown(container.dispose);

        expect(fakePresenceRepo.joinMenuCalls, hasLength(1));
        expect(fakePresenceRepo.joinMenuCalls.first.menuId, _menuId);
        expect(fakePresenceRepo.joinMenuCalls.first.userId, 'user-1');
      });

      test('should call subscribeToMenuChanges with the menuId', () async {
        final container = await startAndTrack();
        addTearDown(container.dispose);

        expect(fakeSubRepo.subscribeCalls, hasLength(1));
        expect(fakeSubRepo.subscribeCalls.first.menuId, _menuId);
      });

      test('should populate presences from getActiveUsers on start', () async {
        fakePresenceRepo.whenGetActiveUsers(_menuId, Success([_testPresence]));

        final container = await startAndTrack();
        addTearDown(container.dispose);

        expect(fakePresenceRepo.getActiveUsersCalls, hasLength(1));
        expect(container.read(menuCollaborationProvider(_menuId)).presences, [
          _testPresence,
        ]);
      });

      test('should not call joinMenu when currentUser is null', () async {
        final container = await startAndTrack(currentUser: null);
        addTearDown(container.dispose);

        expect(fakePresenceRepo.joinMenuCalls, isEmpty);
      });

      test(
        'should have null currentUserId when no user is logged in',
        () async {
          final container = await startAndTrack(currentUser: null);
          addTearDown(container.dispose);

          expect(
            container.read(menuCollaborationProvider(_menuId)).currentUserId,
            isNull,
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    group('stream error handling', () {
      test('should increment wsErrorCount on the first stream error', () async {
        final container = await startAndTrack();
        addTearDown(container.dispose);

        fakeSubRepo.addError(_menuId, 'WS error 1');
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(menuCollaborationProvider(_menuId)).wsErrorCount,
          1,
        );
      });

      test(
        'should increment wsErrorCount again on a second stream error',
        () async {
          final container = await startAndTrack();
          addTearDown(container.dispose);

          fakeSubRepo.addError(_menuId, 'WS error 1');
          await Future<void>.delayed(Duration.zero);

          fakeSubRepo.addError(_menuId, 'WS error 2');
          await Future<void>.delayed(Duration.zero);

          expect(
            container.read(menuCollaborationProvider(_menuId)).wsErrorCount,
            2,
          );
        },
      );

      test(
        'should set isReconnecting true on the first stream error',
        () async {
          final container = await startAndTrack();
          addTearDown(container.dispose);

          fakeSubRepo.addError(_menuId, 'WebSocket error');
          await Future<void>.delayed(Duration.zero);

          expect(
            container.read(menuCollaborationProvider(_menuId)).isReconnecting,
            isTrue,
          );
        },
      );

      test(
        'should clear isReconnecting on the next successful change event',
        () async {
          final container = await startAndTrack();
          addTearDown(container.dispose);

          fakeSubRepo.addError(_menuId, 'error');
          await Future<void>.delayed(Duration.zero);

          fakeSubRepo.emitChange(
            _menuId,
            const WidgetChangedEvent(eventType: 'update', data: {}, ids: null),
          );
          await Future<void>.delayed(Duration.zero);

          expect(
            container.read(menuCollaborationProvider(_menuId)).isReconnecting,
            isFalse,
          );
        },
      );

      test(
        'should reset wsErrorCount to zero on the next successful change event',
        () async {
          final container = await startAndTrack();
          addTearDown(container.dispose);

          fakeSubRepo.addError(_menuId, 'error');
          await Future<void>.delayed(Duration.zero);

          fakeSubRepo.emitChange(
            _menuId,
            const WidgetChangedEvent(eventType: 'update', data: {}, ids: null),
          );
          await Future<void>.delayed(Duration.zero);

          expect(
            container.read(menuCollaborationProvider(_menuId)).wsErrorCount,
            0,
          );
        },
      );

      test('should not increment wsErrorCount when paused', () async {
        final container = await startAndTrack();
        addTearDown(container.dispose);

        // Pause by going offline
        container
            .read(menuCollaborationProvider(_menuId).notifier)
            .onConnectivityChanged(
              ConnectivityStatus.online,
              ConnectivityStatus.offline,
            );

        fakeSubRepo.addError(_menuId, 'error while paused');
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(menuCollaborationProvider(_menuId)).wsErrorCount,
          0,
        );
      });
    });

    // -----------------------------------------------------------------------
    group('presence list updates', () {
      test(
        'should update presences when watchActiveUsers stream emits',
        () async {
          final container = await startAndTrack();
          addTearDown(container.dispose);

          fakePresenceRepo.emitPresence(_menuId, [_testPresence]);
          await Future<void>.delayed(Duration.zero);

          expect(container.read(menuCollaborationProvider(_menuId)).presences, [
            _testPresence,
          ]);
        },
      );

      test(
        'should clear presences when watchActiveUsers emits empty list',
        () async {
          fakePresenceRepo.whenGetActiveUsers(
            _menuId,
            Success([_testPresence]),
          );

          final container = await startAndTrack();
          addTearDown(container.dispose);

          fakePresenceRepo.emitPresence(_menuId, []);
          await Future<void>.delayed(Duration.zero);

          expect(
            container.read(menuCollaborationProvider(_menuId)).presences,
            isEmpty,
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    group('onConnectivityChanged', () {
      test('should set isPaused true when transitioning to offline', () async {
        final container = await startAndTrack();
        addTearDown(container.dispose);

        container
            .read(menuCollaborationProvider(_menuId).notifier)
            .onConnectivityChanged(
              ConnectivityStatus.online,
              ConnectivityStatus.offline,
            );

        expect(
          container.read(menuCollaborationProvider(_menuId)).isPaused,
          isTrue,
        );
      });

      test('should call unsubscribe when transitioning to offline', () async {
        final container = await startAndTrack();
        addTearDown(container.dispose);

        container
            .read(menuCollaborationProvider(_menuId).notifier)
            .onConnectivityChanged(
              ConnectivityStatus.online,
              ConnectivityStatus.offline,
            );

        expect(
          fakeSubRepo.unsubscribeCalls.where((c) => c.menuId == _menuId),
          isNotEmpty,
        );
      });

      test(
        'should set isPaused false when coming back online and was paused',
        () async {
          final container = await startAndTrack(isForeground: true);
          addTearDown(container.dispose);

          // Go offline
          container
              .read(menuCollaborationProvider(_menuId).notifier)
              .onConnectivityChanged(
                ConnectivityStatus.online,
                ConnectivityStatus.offline,
              );
          expect(
            container.read(menuCollaborationProvider(_menuId)).isPaused,
            isTrue,
          );

          // Come back online — _resumeSubscriptions calls _startPresenceTracking
          // which is async (fire-and-forget). Yield the microtask queue so the
          // async work completes while the container is still alive.
          container
              .read(menuCollaborationProvider(_menuId).notifier)
              .onConnectivityChanged(
                ConnectivityStatus.offline,
                ConnectivityStatus.online,
              );
          await Future<void>.delayed(Duration.zero);

          expect(
            container.read(menuCollaborationProvider(_menuId)).isPaused,
            isFalse,
          );
        },
      );

      test(
        'should not call extra unsubscribe when already paused and offline',
        () async {
          final container = await startAndTrack();
          addTearDown(container.dispose);

          container
              .read(menuCollaborationProvider(_menuId).notifier)
              .onConnectivityChanged(
                ConnectivityStatus.online,
                ConnectivityStatus.offline,
              );
          final countAfterFirst = fakeSubRepo.unsubscribeCalls.length;

          // Already paused — a second offline event is a no-op
          container
              .read(menuCollaborationProvider(_menuId).notifier)
              .onConnectivityChanged(
                ConnectivityStatus.offline,
                ConnectivityStatus.offline,
              );

          expect(fakeSubRepo.unsubscribeCalls.length, countAfterFirst);
        },
      );
    });

    // -----------------------------------------------------------------------
    group('onLifecycleChanged', () {
      test('should pause when app goes to background', () async {
        final container = await startAndTrack(
          connectivity: const AsyncData(ConnectivityStatus.online),
        );
        addTearDown(container.dispose);

        container
            .read(menuCollaborationProvider(_menuId).notifier)
            .onLifecycleChanged(true, false);

        expect(
          container.read(menuCollaborationProvider(_menuId)).isPaused,
          isTrue,
        );
      });

      test('should resume when app returns to foreground while online', () async {
        final container = await startAndTrack(
          connectivity: const AsyncData(ConnectivityStatus.online),
        );
        addTearDown(container.dispose);

        container
            .read(menuCollaborationProvider(_menuId).notifier)
            .onLifecycleChanged(true, false);
        expect(
          container.read(menuCollaborationProvider(_menuId)).isPaused,
          isTrue,
        );

        // _resumeSubscriptions calls _startPresenceTracking (async, fire-and-forget).
        // Yield to let it complete while the container is still alive.
        container
            .read(menuCollaborationProvider(_menuId).notifier)
            .onLifecycleChanged(false, true);
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(menuCollaborationProvider(_menuId)).isPaused,
          isFalse,
        );
      });
    });

    // -----------------------------------------------------------------------
    group('findEditingPresence', () {
      test('should return null when widget has no editingBy', () {
        final container = createContainer();
        addTearDown(container.dispose);

        const widget = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1.0',
          index: 0,
          props: {},
        );

        final notifier = container.read(
          menuCollaborationProvider(_menuId).notifier,
        );

        expect(notifier.findEditingPresence(widget), isNull);
      });

      test(
        'should return null when editingBy does not match any presence',
        () async {
          fakePresenceRepo.whenGetActiveUsers(
            _menuId,
            Success([_testPresence]),
          );

          final container = await startAndTrack();
          addTearDown(container.dispose);

          const widget = WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'text',
            version: '1.0',
            index: 0,
            props: {},
            editingBy: 'unknown-user',
          );

          expect(
            container
                .read(menuCollaborationProvider(_menuId).notifier)
                .findEditingPresence(widget),
            isNull,
          );
        },
      );

      test(
        'should return the matching presence when editingBy matches a tracked user',
        () async {
          fakePresenceRepo.whenGetActiveUsers(
            _menuId,
            Success([_testPresence]),
          );

          final container = await startAndTrack();
          addTearDown(container.dispose);

          const widget = WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'text',
            version: '1.0',
            index: 0,
            props: {},
            editingBy: 'user-1',
          );

          expect(
            container
                .read(menuCollaborationProvider(_menuId).notifier)
                .findEditingPresence(widget),
            _testPresence,
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    group('cleanup on dispose', () {
      test('should call unsubscribe on dispose', () async {
        final container = await startAndTrack();
        container.dispose();
        await Future<void>.delayed(Duration.zero);

        expect(
          fakeSubRepo.unsubscribeCalls.where((c) => c.menuId == _menuId),
          isNotEmpty,
        );
      });

      test('should call leaveMenu with the correct user on dispose', () async {
        final container = await startAndTrack();
        container.dispose();
        await Future<void>.delayed(Duration.zero);

        expect(fakePresenceRepo.leaveMenuCalls, hasLength(1));
        expect(fakePresenceRepo.leaveMenuCalls.first.menuId, _menuId);
        expect(fakePresenceRepo.leaveMenuCalls.first.userId, 'user-1');
      });

      test('should call unsubscribePresence on dispose', () async {
        final container = await startAndTrack();
        container.dispose();
        await Future<void>.delayed(Duration.zero);

        expect(
          fakePresenceRepo.unsubscribePresenceCalls.where(
            (c) => c.menuId == _menuId,
          ),
          isNotEmpty,
        );
      });

      test('should not call leaveMenu when no user was logged in', () async {
        final container = await startAndTrack(currentUser: null);
        container.dispose();
        await Future<void>.delayed(Duration.zero);

        expect(fakePresenceRepo.leaveMenuCalls, isEmpty);
      });
    });
  });
}
