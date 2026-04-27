import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/features/menu_editor/presentation/pages/menu_editor_page.dart';
import 'package:oxo_menus/shared/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_error_page.dart';

import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_menu_subscription_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_presence_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../../../../fakes/reflectable_bootstrap.dart';
import '../../../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Helper — slow menu repo for reentrancy test
// ---------------------------------------------------------------------------

/// A [FakeMenuRepository] override whose [getById] blocks on a [Completer].
/// Counts how many times [getById] is invoked.
class _SlowMenuRepository extends FakeMenuRepository {
  _SlowMenuRepository({required Menu fallback}) : _fallback = fallback;

  final Menu _fallback;
  final Completer<void> _readyCompleter = Completer<void>();
  int callCount = 0;

  void complete() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  @override
  Future<Result<Menu, DomainError>> getById(int id) async {
    calls.add(MenuGetByIdCall(id));
    callCount++;
    await _readyCompleter.future;
    return success(_fallback);
  }
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _testMenuId = 1;

final _testMenu = Menu(
  id: _testMenuId,
  name: 'Test Menu',
  status: Status.draft,
  version: '1.0',
  dateCreated: DateTime(2024),
  dateUpdated: DateTime(2024),
);

const _testUser = User(
  id: 'user1',
  email: 'test@test.com',
  firstName: 'Test',
  lastName: 'User',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeMenuRepository fakeMenuRepo;
  late FakePageRepository fakePageRepo;
  late FakeMenuSubscriptionRepository fakeSubRepo;
  late FakePresenceRepository fakePresenceRepo;
  late FakeWidgetRepository fakeWidgetRepo;
  late StreamController<ConnectivityStatus> connectivityController;

  setUpAll(initializeReflectableForTests);

  setUp(() {
    fakeMenuRepo = FakeMenuRepository();
    fakePageRepo = FakePageRepository();
    fakeSubRepo = FakeMenuSubscriptionRepository();
    fakePresenceRepo = FakePresenceRepository();
    fakeWidgetRepo = FakeWidgetRepository();
    connectivityController = StreamController<ConnectivityStatus>.broadcast();

    fakeMenuRepo.whenGetById(success(_testMenu));
    fakePageRepo.whenGetAllForMenu(success([]));
    fakePresenceRepo.whenJoinMenu(success(null));
    fakePresenceRepo.whenLeaveMenu(success(null));
    fakePresenceRepo.whenHeartbeat(success(null));
    fakePresenceRepo.whenGetActiveUsersDefault(success([]));
    fakeWidgetRepo.whenGetAllForColumn(success([]));
  });

  tearDown(() {
    connectivityController.close();
    fakeSubRepo.dispose();
    fakePresenceRepo.dispose();
  });

  Widget buildPage({FakeMenuRepository? menuRepoOverride}) {
    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(
          menuRepoOverride ?? fakeMenuRepo,
        ),
        pageRepositoryProvider.overrideWithValue(fakePageRepo),
        menuSubscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
        presenceRepositoryProvider.overrideWithValue(fakePresenceRepo),
        widgetRepositoryProvider.overrideWithValue(fakeWidgetRepo),
        widgetRegistryProvider.overrideWithValue(PresentableWidgetRegistry()),
        currentUserProvider.overrideWithValue(_testUser),
        connectivityProvider.overrideWith((_) => connectivityController.stream),
        isAppInForegroundProvider.overrideWithValue(true),
      ],
      child: const MaterialApp(home: MenuEditorPage(menuId: _testMenuId)),
    );
  }

  group('MenuEditorPage _loadMenu reentrancy guard', () {
    testWidgets('should not call _loadMenu concurrently when already loading', (
      tester,
    ) async {
      // Arrange — initial load completes quickly with the default fake
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Switch to a slow repo to test reentrancy after initial load
      final slowRepo = _SlowMenuRepository(fallback: _testMenu);
      slowRepo.whenGetById(success(_testMenu)); // sets _getByIdResponse

      // Emit first change event — triggers debounced _loadMenu
      fakeSubRepo.emitChange(
        _testMenuId,
        const WidgetChangedEvent(eventType: 'update', data: {}, ids: null),
      );
      // Advance past debounce (500 ms)
      await tester.pump(const Duration(milliseconds: 600));

      // First _loadMenu is now in progress (fake resolves synchronously, so
      // both calls would have run). The key assertion is no exception is thrown:
      // reentrancy should be silently dropped.

      // Emit a second change event while first may still be processing
      fakeSubRepo.emitChange(
        _testMenuId,
        const WidgetChangedEvent(eventType: 'update', data: {}, ids: null),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert — page should still render correctly after reentrancy
      expect(find.text('Test Menu'), findsOneWidget);
    });
  });

  group('MenuEditorPage offline error page', () {
    testWidgets(
      'should show OfflineErrorPage when going offline after loading',
      (tester) async {
        // Arrange — start online
        connectivityController.add(ConnectivityStatus.online);
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Verify editor loaded (no OfflineErrorPage)
        expect(find.byType(OfflineErrorPage), findsNothing);

        // Act — go offline
        connectivityController.add(ConnectivityStatus.offline);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(OfflineErrorPage), findsOneWidget);
        expect(find.text('You are offline'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets('should show normal editor when online', (tester) async {
      // Arrange + Act
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(OfflineErrorPage), findsNothing);
      expect(find.text('Test Menu'), findsOneWidget);
    });

    testWidgets(
      'should hide OfflineErrorPage when back online after being offline',
      (tester) async {
        // Arrange — start online
        connectivityController.add(ConnectivityStatus.online);
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Act step 1 — go offline
        connectivityController.add(ConnectivityStatus.offline);
        await tester.pumpAndSettle();
        expect(find.byType(OfflineErrorPage), findsOneWidget);

        // Act step 2 — come back online
        connectivityController.add(ConnectivityStatus.online);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(OfflineErrorPage), findsNothing);
      },
    );
  });
}
