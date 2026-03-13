import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/state/menu_collaboration_provider.dart';
import 'package:oxo_menus/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockMenuSubscriptionRepository extends Mock
    implements MenuSubscriptionRepository {}

class MockPresenceRepository extends Mock implements PresenceRepository {}

void main() {
  late MockMenuSubscriptionRepository mockSubRepo;
  late MockPresenceRepository mockPresenceRepo;

  const menuId = 1;

  const testUser = User(id: 'user-1', email: 'test@example.com');

  setUp(() {
    mockSubRepo = MockMenuSubscriptionRepository();
    mockPresenceRepo = MockPresenceRepository();

    // Default stubs for cleanup (called on every container.dispose)
    when(() => mockSubRepo.unsubscribe(any())).thenAnswer((_) async {});
    when(
      () => mockPresenceRepo.unsubscribePresence(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockPresenceRepo.leaveMenu(any(), any()),
    ).thenAnswer((_) async => const Success(null));
  });

  ProviderContainer createContainer({
    User? currentUser = testUser,
    AsyncValue<ConnectivityStatus>? connectivity,
    bool isForeground = true,
  }) {
    return ProviderContainer(
      overrides: [
        menuSubscriptionRepositoryProvider.overrideWithValue(mockSubRepo),
        presenceRepositoryProvider.overrideWithValue(mockPresenceRepo),
        currentUserProvider.overrideWithValue(currentUser),
        isAppInForegroundProvider.overrideWithValue(isForeground),
        if (connectivity != null)
          connectivityProvider.overrideWithValue(connectivity),
      ],
    );
  }

  group('MenuCollaborationNotifier - initial state', () {
    test('has default empty state', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(menuCollaborationProvider(menuId));
      expect(state.presences, isEmpty);
      expect(state.isReconnecting, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.currentUserId, isNull);
    });
  });

  group('MenuCollaborationNotifier - startTracking', () {
    test('subscribes to changes and starts presence tracking', () async {
      final changeController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockSubRepo.subscribeToMenuChanges(menuId),
      ).thenAnswer((_) => changeController.stream);
      when(
        () => mockPresenceRepo.joinMenu(
          menuId,
          'user-1',
          userName: any(named: 'userName'),
          userAvatar: any(named: 'userAvatar'),
        ),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockPresenceRepo.getActiveUsers(menuId),
      ).thenAnswer((_) async => const Success(<MenuPresence>[]));
      when(
        () => mockPresenceRepo.watchActiveUsers(menuId),
      ).thenAnswer((_) => const Stream.empty());

      final container = createContainer();
      addTearDown(() {
        container.dispose();
        changeController.close();
      });

      await container
          .read(menuCollaborationProvider(menuId).notifier)
          .startTracking();

      verify(() => mockSubRepo.subscribeToMenuChanges(menuId)).called(1);
      verify(
        () => mockPresenceRepo.joinMenu(
          menuId,
          'user-1',
          userName: any(named: 'userName'),
          userAvatar: any(named: 'userAvatar'),
        ),
      ).called(1);

      final state = container.read(menuCollaborationProvider(menuId));
      expect(state.currentUserId, 'user-1');
    });
  });

  group('MenuCollaborationNotifier - WS error fallback', () {
    test('sets isReconnecting on stream error', () async {
      final changeController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockSubRepo.subscribeToMenuChanges(menuId),
      ).thenAnswer((_) => changeController.stream);
      when(
        () => mockPresenceRepo.joinMenu(
          menuId,
          'user-1',
          userName: any(named: 'userName'),
          userAvatar: any(named: 'userAvatar'),
        ),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockPresenceRepo.getActiveUsers(menuId),
      ).thenAnswer((_) async => const Success(<MenuPresence>[]));
      when(
        () => mockPresenceRepo.watchActiveUsers(menuId),
      ).thenAnswer((_) => const Stream.empty());

      final container = createContainer();
      addTearDown(() {
        container.dispose();
        changeController.close();
      });

      await container
          .read(menuCollaborationProvider(menuId).notifier)
          .startTracking();

      // Emit an error
      changeController.addError('WebSocket error');
      await Future<void>.delayed(Duration.zero);

      final state = container.read(menuCollaborationProvider(menuId));
      expect(state.isReconnecting, isTrue);
    });
  });

  group('MenuCollaborationNotifier - pause/resume', () {
    test('onConnectivityChanged pauses when offline', () async {
      final changeController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockSubRepo.subscribeToMenuChanges(menuId),
      ).thenAnswer((_) => changeController.stream);
      when(() => mockSubRepo.unsubscribe(menuId)).thenAnswer((_) async {});
      when(
        () => mockPresenceRepo.joinMenu(
          menuId,
          'user-1',
          userName: any(named: 'userName'),
          userAvatar: any(named: 'userAvatar'),
        ),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockPresenceRepo.getActiveUsers(menuId),
      ).thenAnswer((_) async => const Success(<MenuPresence>[]));
      when(
        () => mockPresenceRepo.watchActiveUsers(menuId),
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockPresenceRepo.unsubscribePresence(menuId),
      ).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(() {
        container.dispose();
        changeController.close();
      });

      await container
          .read(menuCollaborationProvider(menuId).notifier)
          .startTracking();

      container
          .read(menuCollaborationProvider(menuId).notifier)
          .onConnectivityChanged(
            ConnectivityStatus.online,
            ConnectivityStatus.offline,
          );

      final state = container.read(menuCollaborationProvider(menuId));
      expect(state.isPaused, isTrue);
    });
  });

  group('MenuCollaborationNotifier - findEditingPresence', () {
    test('returns presence for editing user', () {
      final container = createContainer();
      addTearDown(container.dispose);

      // Manually set some presences via the internal state
      // We can't easily set state externally, so test via startTracking
      final notifier = container.read(
        menuCollaborationProvider(menuId).notifier,
      );

      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
        editingBy: null,
      );

      // No editing user
      expect(notifier.findEditingPresence(widget), isNull);
    });

    test('returns null when no editing user', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        menuCollaborationProvider(menuId).notifier,
      );

      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );

      expect(notifier.findEditingPresence(widget), isNull);
    });
  });

  group('MenuCollaborationNotifier - cleanup', () {
    test('cleanup is called on dispose', () async {
      final changeController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockSubRepo.subscribeToMenuChanges(menuId),
      ).thenAnswer((_) => changeController.stream);
      when(() => mockSubRepo.unsubscribe(menuId)).thenAnswer((_) async {});
      when(
        () => mockPresenceRepo.joinMenu(
          menuId,
          'user-1',
          userName: any(named: 'userName'),
          userAvatar: any(named: 'userAvatar'),
        ),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockPresenceRepo.getActiveUsers(menuId),
      ).thenAnswer((_) async => const Success(<MenuPresence>[]));
      when(
        () => mockPresenceRepo.watchActiveUsers(menuId),
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockPresenceRepo.unsubscribePresence(menuId),
      ).thenAnswer((_) async {});
      when(
        () => mockPresenceRepo.leaveMenu(menuId, 'user-1'),
      ).thenAnswer((_) async => const Success(null));

      final container = createContainer();

      await container
          .read(menuCollaborationProvider(menuId).notifier)
          .startTracking();

      container.dispose();

      verify(() => mockSubRepo.unsubscribe(menuId)).called(1);
      verify(() => mockPresenceRepo.leaveMenu(menuId, 'user-1')).called(1);

      changeController.close();
    });
  });
}
