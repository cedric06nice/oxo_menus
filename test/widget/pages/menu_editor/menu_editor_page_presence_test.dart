import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/common/presence_bar.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockMenuSubscriptionRepository extends Mock
    implements MenuSubscriptionRepository {}

class MockPresenceRepository extends Mock implements PresenceRepository {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MockPageRepository mockPageRepository;
  late MockContainerRepository mockContainerRepository;
  late MockColumnRepository mockColumnRepository;
  late MockWidgetRepository mockWidgetRepository;
  late MockMenuSubscriptionRepository mockMenuSubscriptionRepository;
  late MockPresenceRepository mockPresenceRepository;
  late WidgetRegistry mockWidgetRegistry;

  const testMenuId = 42;

  final testMenu = Menu(
    id: testMenuId,
    name: 'Test Menu',
    status: Status.draft,
    version: '1.0.0',
  );

  final testPage = entity.Page(
    id: 1,
    menuId: testMenuId,
    name: 'Page 1',
    index: 0,
    type: entity.PageType.content,
  );

  final testContainer = entity.Container(id: 1, pageId: 1, index: 0);
  final testColumn = entity.Column(
    id: 1,
    containerId: 1,
    index: 0,
    isDroppable: true,
  );

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockPageRepository = MockPageRepository();
    mockContainerRepository = MockContainerRepository();
    mockColumnRepository = MockColumnRepository();
    mockWidgetRepository = MockWidgetRepository();
    mockMenuSubscriptionRepository = MockMenuSubscriptionRepository();
    mockPresenceRepository = MockPresenceRepository();

    mockWidgetRegistry = WidgetRegistry();
    mockWidgetRegistry.register(dishWidgetDefinition);
    mockWidgetRegistry.register(sectionWidgetDefinition);
    mockWidgetRegistry.register(textWidgetDefinition);

    registerFallbackValue(const UpdateMenuInput(id: -1));
    registerFallbackValue(
      const CreateWidgetInput(
        columnId: -1,
        type: '',
        version: '',
        index: 0,
        props: {},
      ),
    );
    registerFallbackValue(const UpdateWidgetInput(id: -1));
  });

  void stubSuccessfulLoad() {
    when(
      () => mockMenuRepository.getById(testMenuId),
    ).thenAnswer((_) async => Success(testMenu));
    when(
      () => mockPageRepository.getAllForMenu(testMenuId),
    ).thenAnswer((_) async => Success([testPage]));
    when(
      () => mockContainerRepository.getAllForPage(1),
    ).thenAnswer((_) async => Success([testContainer]));
    when(
      () => mockColumnRepository.getAllForContainer(1),
    ).thenAnswer((_) async => Success([testColumn]));
    when(
      () => mockWidgetRepository.getAllForColumn(1),
    ).thenAnswer((_) async => const Success([]));
  }

  void stubSubscription() {
    when(
      () => mockMenuSubscriptionRepository.subscribeToMenuChanges(testMenuId),
    ).thenAnswer((_) => const Stream<MenuChangeEvent>.empty());
    when(
      () => mockMenuSubscriptionRepository.unsubscribe(testMenuId),
    ).thenAnswer((_) async {});
  }

  void stubPresence({
    StreamController<List<MenuPresence>>? presenceStreamController,
  }) {
    when(
      () => mockPresenceRepository.joinMenu(
        testMenuId,
        'user-1',
        userName: any(named: 'userName'),
        userAvatar: any(named: 'userAvatar'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockPresenceRepository.leaveMenu(testMenuId, 'user-1'),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockPresenceRepository.heartbeat(testMenuId, 'user-1'),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockPresenceRepository.getActiveUsers(testMenuId),
    ).thenAnswer((_) async => const Success(<MenuPresence>[]));
    when(() => mockPresenceRepository.watchActiveUsers(testMenuId)).thenAnswer(
      (_) =>
          presenceStreamController?.stream ??
          const Stream<List<MenuPresence>>.empty(),
    );
    when(
      () => mockPresenceRepository.unsubscribePresence(testMenuId),
    ).thenAnswer((_) async {});
  }

  Widget createWidgetUnderTest() {
    final mockUser = User(
      id: 'user-1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.user,
    );

    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        pageRepositoryProvider.overrideWithValue(mockPageRepository),
        containerRepositoryProvider.overrideWithValue(mockContainerRepository),
        columnRepositoryProvider.overrideWithValue(mockColumnRepository),
        widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
        widgetRegistryProvider.overrideWithValue(mockWidgetRegistry),
        currentUserProvider.overrideWithValue(mockUser),
        menuSubscriptionRepositoryProvider.overrideWithValue(
          mockMenuSubscriptionRepository,
        ),
        presenceRepositoryProvider.overrideWithValue(mockPresenceRepository),
        directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
        directusAccessTokenProvider.overrideWithValue('test-token'),
      ],
      child: MaterialApp(home: MenuEditorPage(menuId: testMenuId)),
    );
  }

  group('MenuEditorPage Presence Tracking', () {
    testWidgets('should call joinMenu after initial load', (tester) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(
        () => mockPresenceRepository.joinMenu(
          testMenuId,
          'user-1',
          userName: any(named: 'userName'),
          userAvatar: any(named: 'userAvatar'),
        ),
      ).called(1);
    });

    testWidgets('should pass user display name to joinMenu', (tester) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(
        () => mockPresenceRepository.joinMenu(
          testMenuId,
          'user-1',
          userName: 'Test User',
          userAvatar: any(named: 'userAvatar'),
        ),
      ).called(1);
    });

    testWidgets('should await joinMenu before refreshing presences', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      // Track when getActiveUsers is called relative to joinMenu completion
      final joinCompleter = Completer<Result<void, DomainError>>();
      var getActiveCalledBeforeJoinCompleted = false;

      when(
        () => mockPresenceRepository.joinMenu(
          testMenuId,
          'user-1',
          userName: any(named: 'userName'),
          userAvatar: any(named: 'userAvatar'),
        ),
      ).thenAnswer((_) => joinCompleter.future);
      when(() => mockPresenceRepository.getActiveUsers(testMenuId)).thenAnswer((
        _,
      ) async {
        if (!joinCompleter.isCompleted) {
          getActiveCalledBeforeJoinCompleted = true;
        }
        return const Success(<MenuPresence>[]);
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Complete joinMenu after a microtask delay
      joinCompleter.complete(const Success(null));
      await tester.pumpAndSettle();

      expect(
        getActiveCalledBeforeJoinCompleted,
        isFalse,
        reason: 'getActiveUsers should not be called before joinMenu completes',
      );
    });

    testWidgets('should display PresenceBar with active users in AppBar', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      // Override getActiveUsers to return other users
      when(() => mockPresenceRepository.getActiveUsers(testMenuId)).thenAnswer(
        (_) async => Success([
          MenuPresence(
            id: 1,
            userId: 'user-2',
            menuId: testMenuId,
            lastSeen: DateTime.now(),
            userName: 'Alice Baker',
          ),
        ]),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // PresenceBar should be rendered with avatar
      expect(find.byType(PresenceBar), findsOneWidget);
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('should not display PresenceBar when no other users', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // PresenceBar rendered but shows nothing (SizedBox.shrink)
      expect(find.byType(PresenceBar), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('should call leaveMenu when disposed', (tester) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Dispose by navigating away
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('Replaced'))),
      );
      await tester.pumpAndSettle();

      verify(
        () => mockPresenceRepository.leaveMenu(testMenuId, 'user-1'),
      ).called(1);
    });

    testWidgets('should subscribe to watchActiveUsers after initial load', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(
        () => mockPresenceRepository.watchActiveUsers(testMenuId),
      ).called(1);
    });

    testWidgets('should update presences when WebSocket stream emits', (
      tester,
    ) async {
      final presenceController =
          StreamController<List<MenuPresence>>.broadcast();

      stubSuccessfulLoad();
      stubSubscription();
      stubPresence(presenceStreamController: presenceController);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially no other users
      expect(find.byType(CircleAvatar), findsNothing);

      // Simulate WebSocket emitting a presence update
      presenceController.add([
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: testMenuId,
          lastSeen: DateTime.now(),
          userName: 'Bob Smith',
        ),
      ]);

      await tester.pump();
      await tester.pump();

      // Now should show the other user's avatar
      expect(find.text('BS'), findsOneWidget);

      presenceController.close();
    });

    testWidgets('should call unsubscribePresence on dispose', (tester) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Dispose by navigating away
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('Replaced'))),
      );
      await tester.pumpAndSettle();

      verify(
        () => mockPresenceRepository.unsubscribePresence(testMenuId),
      ).called(1);
    });

    testWidgets('should show editing user initials on locked widget', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      // Override getAllForColumn AFTER stubSuccessfulLoad to return a widget
      // being edited by user-2
      when(() => mockWidgetRepository.getAllForColumn(1)).thenAnswer(
        (_) async => Success([
          WidgetInstance(
            id: 10,
            columnId: 1,
            type: 'dish',
            version: '1.0.0',
            index: 0,
            props: const {'name': 'Pasta', 'price': 12.50},
            editingBy: 'user-2',
            editingSince: DateTime.now(),
          ),
        ]),
      );

      // Override getActiveUsers to return presence for user-2
      when(() => mockPresenceRepository.getActiveUsers(testMenuId)).thenAnswer(
        (_) async => Success([
          MenuPresence(
            id: 1,
            userId: 'user-2',
            menuId: testMenuId,
            lastSeen: DateTime.now(),
            userName: 'Alice Baker',
          ),
        ]),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show the editing user's initials within the lock overlay badge
      expect(
        find.descendant(
          of: find.byKey(const Key('editing_lock_overlay_10')),
          matching: find.text('AB'),
        ),
        findsOneWidget,
      );
    });
  });
}
