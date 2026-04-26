import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

import '../../../fakes/fake_column_repository.dart';
import '../../../fakes/fake_container_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_menu_subscription_repository.dart';
import '../../../fakes/fake_page_repository.dart';
import '../../../fakes/fake_presence_repository.dart';
import '../../../fakes/fake_widget_repository.dart';
import '../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _testMenuId = 42;

final _testMenu = Menu(
  id: _testMenuId,
  name: 'Test Menu',
  status: Status.draft,
  version: '1.0.0',
);

final _testPage = entity.Page(
  id: 1,
  menuId: _testMenuId,
  name: 'Page 1',
  index: 0,
  type: entity.PageType.content,
);

final _testContainer = entity.Container(id: 1, pageId: 1, index: 0);

final _testColumn = entity.Column(
  id: 1,
  containerId: 1,
  index: 0,
  isDroppable: true,
);

const _testUser = User(
  id: 'user-1',
  email: 'test@example.com',
  firstName: 'Test',
  lastName: 'User',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeMenuRepository fakeMenuRepo;
  late FakePageRepository fakePageRepo;
  late FakeContainerRepository fakeContainerRepo;
  late FakeColumnRepository fakeColumnRepo;
  late FakeWidgetRepository fakeWidgetRepo;
  late FakeMenuSubscriptionRepository fakeSubRepo;
  late FakePresenceRepository fakePresenceRepo;
  late PresentableWidgetRegistry registry;

  setUp(() {
    fakeMenuRepo = FakeMenuRepository();
    fakePageRepo = FakePageRepository();
    fakeContainerRepo = FakeContainerRepository();
    fakeColumnRepo = FakeColumnRepository();
    fakeWidgetRepo = FakeWidgetRepository();
    fakeSubRepo = FakeMenuSubscriptionRepository();
    fakePresenceRepo = FakePresenceRepository();

    registry = PresentableWidgetRegistry();
    registry.register(dishWidgetDefinition);
    registry.register(sectionWidgetDefinition);
    registry.register(textWidgetDefinition);

    fakePresenceRepo.whenJoinMenu(success(null));
    fakePresenceRepo.whenLeaveMenu(success(null));
    fakePresenceRepo.whenHeartbeat(success(null));
    fakePresenceRepo.whenGetActiveUsersDefault(success([]));
  });

  tearDown(() {
    fakeSubRepo.dispose();
    fakePresenceRepo.dispose();
  });

  void stubSuccessfulLoad() {
    fakeMenuRepo.whenGetById(success(_testMenu));
    fakePageRepo.whenGetAllForMenu(success([_testPage]));
    fakeContainerRepo.whenGetAllForPage(success([_testContainer]));
    fakeContainerRepo.whenGetAllForContainer(success(<entity.Container>[]));
    fakeColumnRepo.whenGetAllForContainer(success([_testColumn]));
    fakeWidgetRepo.whenGetAllForColumn(success([]));
  }

  Widget buildPage() {
    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
        pageRepositoryProvider.overrideWithValue(fakePageRepo),
        containerRepositoryProvider.overrideWithValue(fakeContainerRepo),
        columnRepositoryProvider.overrideWithValue(fakeColumnRepo),
        widgetRepositoryProvider.overrideWithValue(fakeWidgetRepo),
        widgetRegistryProvider.overrideWithValue(registry),
        currentUserProvider.overrideWithValue(_testUser),
        menuSubscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
        presenceRepositoryProvider.overrideWithValue(fakePresenceRepo),
      ],
      child: MaterialApp(home: MenuEditorPage(menuId: _testMenuId)),
    );
  }

  group('MenuEditorPage Live Sync', () {
    testWidgets('should subscribe to menu changes after initial load', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();

      // Act
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Assert
      expect(
        fakeSubRepo.subscribeCalls.where((c) => c.menuId == _testMenuId).length,
        equals(1),
      );
    });

    testWidgets('should unsubscribe when disposed', (tester) async {
      // Arrange
      stubSuccessfulLoad();
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Act — replace with a different widget to dispose MenuEditorPage
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Replaced'))),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        fakeSubRepo.unsubscribeCalls
            .where((c) => c.menuId == _testMenuId)
            .length,
        greaterThanOrEqualTo(1),
      );
    });

    testWidgets('should reload menu when receiving a change event', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      final loadCountBeforeEvent = fakeMenuRepo.getByIdCalls.length;

      // Act — emit a change event
      fakeSubRepo.emitChange(
        _testMenuId,
        const WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 1},
          ids: null,
        ),
      );

      // Wait for debounce (500 ms) plus margin
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert — getById should have been called again for the reload
      expect(
        fakeMenuRepo.getByIdCalls.length,
        greaterThan(loadCountBeforeEvent),
      );
    });

    testWidgets(
      'should debounce multiple rapid change events into a single reload',
      (tester) async {
        // Arrange
        stubSuccessfulLoad();
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        final loadCountAfterInitial = fakeMenuRepo.getByIdCalls.length;

        // Act — emit several events rapidly
        fakeSubRepo.emitChange(
          _testMenuId,
          const WidgetChangedEvent(
            eventType: 'update',
            data: {'id': 1},
            ids: null,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        fakeSubRepo.emitChange(
          _testMenuId,
          const WidgetChangedEvent(
            eventType: 'update',
            data: {'id': 2},
            ids: null,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        fakeSubRepo.emitChange(
          _testMenuId,
          const WidgetChangedEvent(
            eventType: 'create',
            data: {'id': 3},
            ids: null,
          ),
        );

        // Wait for debounce to fire (500 ms from last event)
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        // Assert — only one additional reload despite 3 events
        expect(
          fakeMenuRepo.getByIdCalls.length,
          equals(loadCountAfterInitial + 1),
        );
      },
    );

    testWidgets('should show reconnecting banner on stream error', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Act — emit an error on the stream
      fakeSubRepo.addError(_testMenuId, Exception('WebSocket disconnected'));
      await tester.pump(Duration.zero);
      await tester.pump();

      // Assert
      expect(find.text('Reconnecting...'), findsOneWidget);
    });

    testWidgets('should fall back to polling after 3 stream errors', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      final loadCountAfterInitial = fakeMenuRepo.getByIdCalls.length;

      // Act — emit 3 errors to trigger fallback
      fakeSubRepo.addError(_testMenuId, Exception('Error 1'));
      await tester.pump(Duration.zero);
      await tester.pump();

      fakeSubRepo.addError(_testMenuId, Exception('Error 2'));
      await tester.pump(Duration.zero);
      await tester.pump();

      fakeSubRepo.addError(_testMenuId, Exception('Error 3'));
      await tester.pump(Duration.zero);
      await tester.pump();

      // Wait for polling interval (30 s)
      await tester.pump(const Duration(seconds: 31));

      // Assert — should have polled at least once
      expect(
        fakeMenuRepo.getByIdCalls.length,
        greaterThan(loadCountAfterInitial),
      );
    });

    testWidgets('should hide reconnecting banner after successful reload', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Act step 1 — emit an error to show the banner
      fakeSubRepo.addError(_testMenuId, Exception('WebSocket disconnected'));
      await tester.pump(Duration.zero);
      await tester.pump();

      expect(find.text('Reconnecting...'), findsOneWidget);

      // Act step 2 — emit a successful event (simulates reconnection)
      fakeSubRepo.emitChange(
        _testMenuId,
        const WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 1},
          ids: null,
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reconnecting...'), findsNothing);
    });
  });
}
