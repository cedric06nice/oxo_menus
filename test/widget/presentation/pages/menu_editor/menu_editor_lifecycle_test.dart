import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/main.reflectable.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockMenuSubscriptionRepository extends Mock
    implements MenuSubscriptionRepository {}

class MockPresenceRepository extends Mock implements PresenceRepository {}

class MockWidgetRepo extends Mock implements WidgetRepository {}

class MockPresentableWidgetRegistry extends Mock
    implements PresentableWidgetRegistry {}

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
        widgetRegistryProvider.overrideWithValue(PresentableWidgetRegistry()),
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

  group('MenuEditorPage lifecycle', () {
    testWidgets('pauses subscriptions when going offline', (tester) async {
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify subscriptions were started
      verify(() => mockSubRepo.subscribeToMenuChanges(1)).called(1);

      // Go offline
      connectivityController.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();

      // Verify subscriptions were cancelled
      verify(() => mockSubRepo.unsubscribe(1)).called(1);
      verify(() => mockPresenceRepo.unsubscribePresence(1)).called(1);
    });

    testWidgets('resumes subscriptions when coming back online', (
      tester,
    ) async {
      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Go offline then online
      connectivityController.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();

      // Reset change stream for re-subscription
      changeController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockSubRepo.subscribeToMenuChanges(any()),
      ).thenAnswer((_) => changeController.stream);

      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpAndSettle();

      // Verify re-subscription happened (initial + resume)
      verify(() => mockSubRepo.subscribeToMenuChanges(1)).called(2);
    });

    testWidgets('shows retry button in error state', (tester) async {
      when(() => mockMenuRepo.getById(any())).thenAnswer(
        (_) async => const Failure(NetworkError('Connection failed')),
      );

      connectivityController.add(ConnectivityStatus.online);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
