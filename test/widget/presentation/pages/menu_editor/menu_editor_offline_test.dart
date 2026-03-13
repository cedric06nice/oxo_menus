import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/offline_error_page.dart';
import 'package:oxo_menus/main.reflectable.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockMenuSubscriptionRepository extends Mock
    implements MenuSubscriptionRepository {}

class MockPresenceRepository extends Mock implements PresenceRepository {}

class MockWidgetRepo extends Mock implements WidgetRepository {}

void main() {
  late MockMenuRepository mockMenuRepo;
  late MockPageRepository mockPageRepo;
  late MockMenuSubscriptionRepository mockSubRepo;
  late MockPresenceRepository mockPresenceRepo;
  late StreamController<ConnectivityStatus> connectivityController;
  late StreamController<MenuChangeEvent> changeController;

  final testMenu = Menu(
    id: 1,
    name: 'Test Menu',
    status: Status.draft,
    version: '1.0',
    dateCreated: DateTime(2024),
    dateUpdated: DateTime(2024),
  );

  setUpAll(() {
    initializeReflectable();
  });

  setUp(() {
    mockMenuRepo = MockMenuRepository();
    mockPageRepo = MockPageRepository();
    mockSubRepo = MockMenuSubscriptionRepository();
    mockPresenceRepo = MockPresenceRepository();
    connectivityController = StreamController<ConnectivityStatus>.broadcast();
    changeController = StreamController<MenuChangeEvent>.broadcast();

    when(
      () => mockMenuRepo.getById(any()),
    ).thenAnswer((_) async => Success(testMenu));
    when(
      () => mockPageRepo.getAllForMenu(any()),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => mockSubRepo.subscribeToMenuChanges(any()),
    ).thenAnswer((_) => changeController.stream);
    when(() => mockSubRepo.unsubscribe(any())).thenAnswer((_) async {});
    when(
      () => mockPresenceRepo.joinMenu(
        any(),
        any(),
        userName: any(named: 'userName'),
        userAvatar: any(named: 'userAvatar'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockPresenceRepo.watchActiveUsers(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockPresenceRepo.heartbeat(any(), any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockPresenceRepo.getActiveUsers(any()),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => mockPresenceRepo.unsubscribePresence(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockPresenceRepo.leaveMenu(any(), any()),
    ).thenAnswer((_) async => const Success(null));
  });

  tearDown(() {
    connectivityController.close();
    changeController.close();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepo),
        pageRepositoryProvider.overrideWithValue(mockPageRepo),
        menuSubscriptionRepositoryProvider.overrideWithValue(mockSubRepo),
        presenceRepositoryProvider.overrideWithValue(mockPresenceRepo),
        widgetRepositoryProvider.overrideWithValue(MockWidgetRepo()),
        widgetRegistryProvider.overrideWithValue(WidgetRegistry()),
        currentUserProvider.overrideWithValue(
          const User(
            id: 'user1',
            email: 'test@test.com',
            firstName: 'Test',
            lastName: 'User',
          ),
        ),
        connectivityProvider.overrideWith((_) => connectivityController.stream),
        isAppInForegroundProvider.overrideWithValue(true),
      ],
      child: const MaterialApp(home: MenuEditorPage(menuId: 1)),
    );
  }

  group('MenuEditorPage _loadMenu reentrancy guard', () {
    testWidgets('_loadMenu is not called concurrently', (tester) async {
      var getByIdCallCount = 0;
      final menuCompleter = Completer<Result<Menu, DomainError>>();

      // First call returns normally for initial load
      when(
        () => mockMenuRepo.getById(any()),
      ).thenAnswer((_) async => Success(testMenu));

      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Now make getById slow — track calls with a completer
      getByIdCallCount = 0;
      when(() => mockMenuRepo.getById(any())).thenAnswer((_) {
        getByIdCallCount++;
        if (getByIdCallCount == 1) {
          return menuCompleter.future;
        }
        return Future.value(Success(testMenu));
      });

      // Trigger a WebSocket change event → debounced _loadMenu
      changeController.add(
        const WidgetChangedEvent(eventType: 'update', data: {}, ids: null),
      );
      // Advance past debounce (500ms)
      await tester.pump(const Duration(milliseconds: 600));

      // First _loadMenu is in progress (waiting on completer)
      expect(getByIdCallCount, 1);

      // Trigger another change event → another debounced _loadMenu
      changeController.add(
        const WidgetChangedEvent(eventType: 'update', data: {}, ids: null),
      );
      await tester.pump(const Duration(milliseconds: 600));

      // Second _loadMenu should be skipped (reentrancy guard)
      expect(
        getByIdCallCount,
        1,
        reason: 'second _loadMenu should be skipped while first is running',
      );

      // Complete the first _loadMenu
      menuCompleter.complete(Success(testMenu));
      await tester.pumpAndSettle();
    });
  });

  group('MenuEditorPage offline error page', () {
    testWidgets('shows OfflineErrorPage when offline after loading', (
      tester,
    ) async {
      // Start online, let page load
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify editor loaded (no OfflineErrorPage)
      expect(find.byType(OfflineErrorPage), findsNothing);

      // Go offline
      connectivityController.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();

      // Should show offline error page
      expect(find.byType(OfflineErrorPage), findsOneWidget);
      expect(find.text('You are offline'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows normal editor when online', (tester) async {
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(OfflineErrorPage), findsNothing);
      // Editor content should be present (menu name in title)
      expect(find.text('Test Menu'), findsOneWidget);
    });

    testWidgets('hides OfflineErrorPage when back online after retry', (
      tester,
    ) async {
      // Start online, let page load
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Go offline
      connectivityController.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();
      expect(find.byType(OfflineErrorPage), findsOneWidget);

      // Prepare for re-subscription on resume
      changeController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockSubRepo.subscribeToMenuChanges(any()),
      ).thenAnswer((_) => changeController.stream);

      // Come back online
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpAndSettle();

      // Should hide offline error page
      expect(find.byType(OfflineErrorPage), findsNothing);
    });
  });
}
