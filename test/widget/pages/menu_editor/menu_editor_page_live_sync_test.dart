import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
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
  late StreamController<MenuChangeEvent> changeStreamController;

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
    changeStreamController = StreamController<MenuChangeEvent>.broadcast();

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

  tearDown(() {
    changeStreamController.close();
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
    ).thenAnswer((_) => changeStreamController.stream);
    when(
      () => mockMenuSubscriptionRepository.unsubscribe(testMenuId),
    ).thenAnswer((_) async {});
  }

  void stubPresence() {
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
    when(
      () => mockPresenceRepository.watchActiveUsers(testMenuId),
    ).thenAnswer((_) => const Stream<List<MenuPresence>>.empty());
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
      ],
      child: MaterialApp(home: MenuEditorPage(menuId: testMenuId)),
    );
  }

  group('MenuEditorPage Live Sync', () {
    testWidgets('should subscribe to menu changes after initial load', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(
        () => mockMenuSubscriptionRepository.subscribeToMenuChanges(testMenuId),
      ).called(1);
    });

    testWidgets('should unsubscribe when disposed', (tester) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Dispose by replacing with a different widget
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('Replaced'))),
      );
      await tester.pumpAndSettle();

      verify(
        () => mockMenuSubscriptionRepository.unsubscribe(testMenuId),
      ).called(1);
    });

    testWidgets('should reload menu when receiving a change event', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initial load: getById called once
      verify(() => mockMenuRepository.getById(testMenuId)).called(1);

      // Emit a change event
      changeStreamController.add(
        const WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 1},
          ids: null,
        ),
      );

      // Wait for debounce (500ms) plus some margin
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // getById should have been called again for the reload
      verify(() => mockMenuRepository.getById(testMenuId)).called(1);
    });

    testWidgets('should debounce multiple rapid change events', (tester) async {
      stubSuccessfulLoad();
      stubSubscription();
      stubPresence();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Reset verification count after initial load
      clearInteractions(mockMenuRepository);
      stubSuccessfulLoad(); // Re-stub for reload calls

      // Emit several events rapidly
      changeStreamController.add(
        const WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 1},
          ids: null,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      changeStreamController.add(
        const WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 2},
          ids: null,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      changeStreamController.add(
        const WidgetChangedEvent(
          eventType: 'create',
          data: {'id': 3},
          ids: null,
        ),
      );

      // Wait for debounce to fire (500ms from last event)
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Only one reload despite 3 events
      verify(() => mockMenuRepository.getById(testMenuId)).called(1);
    });

    testWidgets('should show reconnecting banner on stream error', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubPresence();

      // Use a custom stream that emits an error after first listen
      final errorController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockMenuSubscriptionRepository.subscribeToMenuChanges(testMenuId),
      ).thenAnswer((_) => errorController.stream);
      when(
        () => mockMenuSubscriptionRepository.unsubscribe(testMenuId),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Emit an error on the stream (caught by onError handler)
      errorController.addError(Exception('WebSocket disconnected'));

      // Allow microtasks to deliver the error to the listener
      await tester.pump(Duration.zero);
      // Allow the setState to trigger a rebuild
      await tester.pump();

      // Should show a reconnecting indicator
      expect(find.text('Reconnecting...'), findsOneWidget);

      await errorController.close();
    });

    testWidgets('should fall back to polling after 3 stream errors', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubPresence();

      final errorController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockMenuSubscriptionRepository.subscribeToMenuChanges(testMenuId),
      ).thenAnswer((_) => errorController.stream);
      when(
        () => mockMenuSubscriptionRepository.unsubscribe(testMenuId),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Reset load count after initial
      clearInteractions(mockMenuRepository);
      stubSuccessfulLoad();

      // Emit 3 errors to trigger fallback
      errorController.addError(Exception('Error 1'));
      await tester.pump(Duration.zero);
      await tester.pump();
      errorController.addError(Exception('Error 2'));
      await tester.pump(Duration.zero);
      await tester.pump();
      errorController.addError(Exception('Error 3'));
      await tester.pump(Duration.zero);
      await tester.pump();

      // Wait for polling interval (30s) - use pump instead of pumpAndSettle
      // because the reconnecting banner has an active CircularProgressIndicator
      await tester.pump(const Duration(seconds: 31));

      // Should have polled at least once
      verify(() => mockMenuRepository.getById(testMenuId)).called(1);

      await errorController.close();
    });

    testWidgets('should hide reconnecting banner after successful reload', (
      tester,
    ) async {
      stubSuccessfulLoad();
      stubPresence();

      final errorController = StreamController<MenuChangeEvent>.broadcast();
      when(
        () => mockMenuSubscriptionRepository.subscribeToMenuChanges(testMenuId),
      ).thenAnswer((_) => errorController.stream);
      when(
        () => mockMenuSubscriptionRepository.unsubscribe(testMenuId),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Emit an error
      errorController.addError(Exception('WebSocket disconnected'));
      await tester.pump(Duration.zero);
      await tester.pump();
      expect(find.text('Reconnecting...'), findsOneWidget);

      // Emit a successful event (simulates reconnection)
      errorController.add(
        const WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 1},
          ids: null,
        ),
      );

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Banner should be gone
      expect(find.text('Reconnecting...'), findsNothing);

      await errorController.close();
    });
  });
}
