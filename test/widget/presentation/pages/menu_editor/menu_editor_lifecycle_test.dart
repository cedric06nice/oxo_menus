import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';

import '../../../../fakes/fake_menu_repository.dart';
import '../../../../fakes/fake_menu_subscription_repository.dart';
import '../../../../fakes/fake_page_repository.dart';
import '../../../../fakes/fake_presence_repository.dart';
import '../../../../fakes/fake_widget_repository.dart';
import '../../../../fakes/reflectable_bootstrap.dart';
import '../../../../fakes/result_helpers.dart';

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

  Widget buildPage() {
    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
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

  group('MenuEditorPage lifecycle', () {
    testWidgets('should pause subscriptions when going offline', (
      tester,
    ) async {
      // Arrange — start online
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      final subscribesBeforeOffline = fakeSubRepo.subscribeCalls.length;
      expect(subscribesBeforeOffline, greaterThanOrEqualTo(1));

      // Act — go offline
      connectivityController.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();

      // Assert — subscriptions were cancelled
      expect(
        fakeSubRepo.unsubscribeCalls
            .where((c) => c.menuId == _testMenuId)
            .length,
        greaterThanOrEqualTo(1),
      );
      expect(
        fakePresenceRepo.unsubscribePresenceCalls
            .where((c) => c.menuId == _testMenuId)
            .length,
        greaterThanOrEqualTo(1),
      );
    });

    testWidgets('should resume subscriptions when coming back online', (
      tester,
    ) async {
      // Arrange — start online
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      final subscribeCountAfterOnline = fakeSubRepo.subscribeCalls.length;

      // Act — go offline, then online again
      connectivityController.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();

      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpAndSettle();

      // Assert — re-subscription happened (at least one more subscribe call)
      expect(
        fakeSubRepo.subscribeCalls.length,
        greaterThan(subscribeCountAfterOnline),
      );
    });

    testWidgets('should show retry button in error state', (tester) async {
      // Arrange — make getById fail
      fakeMenuRepo.whenGetById(
        failure(const NetworkError('Connection failed')),
      );

      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
