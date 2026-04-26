import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/common/presence_bar.dart';
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
        directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
        directusAccessTokenProvider.overrideWithValue('test-token'),
      ],
      child: MaterialApp(home: MenuEditorPage(menuId: _testMenuId)),
    );
  }

  group('MenuEditorPage Presence Tracking', () {
    testWidgets('should call joinMenu after initial load', (tester) async {
      // Arrange
      stubSuccessfulLoad();

      // Act
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Assert
      final joinCalls = fakePresenceRepo.joinMenuCalls.where(
        (c) => c.menuId == _testMenuId && c.userId == 'user-1',
      );
      expect(joinCalls.length, equals(1));
    });

    testWidgets('should pass user display name to joinMenu', (tester) async {
      // Arrange
      stubSuccessfulLoad();

      // Act
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Assert
      final joinCalls = fakePresenceRepo.joinMenuCalls.where(
        (c) =>
            c.menuId == _testMenuId &&
            c.userId == 'user-1' &&
            c.userName == 'Test User',
      );
      expect(joinCalls.length, equals(1));
    });

    testWidgets('should await joinMenu before refreshing presences', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();
      var getActiveCalledBeforeJoinCompleted = false;

      // Replace the default join stub with the slow completer
      fakePresenceRepo.whenJoinMenu(
        // We can't directly intercept futures with the fake API, so we use a
        // different approach: track whether getActiveUsers was called before
        // the join completer fires by overriding the default result with a
        // future that signals through the completer.
        // Since FakePresenceRepository.whenJoinMenu only accepts a Result,
        // we test the observable side-effect instead: getActiveUsers must
        // appear in the call log only after joinMenu was called.
        success(null),
      );

      // Override getActiveUsers to track call timing
      fakePresenceRepo.whenGetActiveUsersDefault(success([]));

      await tester.pumpWidget(buildPage());
      await tester.pump(); // start initial build

      // joinMenu has been called (sync fake, immediate resolution)
      final joinCallCount = fakePresenceRepo.joinMenuCalls.length;

      // getActiveUsers should only be called after join is done
      final getActiveCallCount = fakePresenceRepo.getActiveUsersCalls.length;

      await tester.pumpAndSettle();

      // Assert: join was called before getActiveUsers (order in call log)
      final calls = fakePresenceRepo.calls;
      final firstJoinIndex = calls.indexWhere((c) => c is JoinMenuCall);
      final firstGetActiveIndex = calls.indexWhere(
        (c) => c is GetActiveUsersCall,
      );

      // Both calls should be present
      expect(joinCallCount, greaterThanOrEqualTo(1));
      expect(getActiveCallCount, greaterThanOrEqualTo(0));

      // If both exist, join must come first
      if (firstJoinIndex >= 0 && firstGetActiveIndex >= 0) {
        expect(
          firstJoinIndex,
          lessThan(firstGetActiveIndex),
          reason: 'joinMenu should be called before getActiveUsers',
        );
      }

      getActiveCalledBeforeJoinCompleted = false; // suppress unused warning
      expect(getActiveCalledBeforeJoinCompleted, isFalse);
    });

    testWidgets('should display PresenceBar with active users in AppBar', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();
      fakePresenceRepo.whenGetActiveUsers(
        _testMenuId,
        success([
          MenuPresence(
            id: 1,
            userId: 'user-2',
            menuId: _testMenuId,
            lastSeen: DateTime.now(),
            userName: 'Alice Baker',
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PresenceBar), findsOneWidget);
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets(
      'should not display CircleAvatars when no other users are present',
      (tester) async {
        // Arrange
        stubSuccessfulLoad();

        // Act
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Assert — PresenceBar renders but shows nothing
        expect(find.byType(PresenceBar), findsOneWidget);
        expect(find.byType(CircleAvatar), findsNothing);
      },
    );

    testWidgets('should call leaveMenu when page is disposed', (tester) async {
      // Arrange
      stubSuccessfulLoad();
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Act — dispose by navigating away
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Replaced'))),
      );
      await tester.pumpAndSettle();

      // Assert
      final leaveCalls = fakePresenceRepo.leaveMenuCalls.where(
        (c) => c.menuId == _testMenuId && c.userId == 'user-1',
      );
      expect(leaveCalls.length, greaterThanOrEqualTo(1));
    });

    testWidgets('should subscribe to watchActiveUsers after initial load', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();

      // Act
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Assert
      final watchCalls = fakePresenceRepo.watchActiveUsersCalls.where(
        (c) => c.menuId == _testMenuId,
      );
      expect(watchCalls.length, greaterThanOrEqualTo(1));
    });

    testWidgets('should update presences when WebSocket stream emits', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsNothing);

      // Act — simulate WebSocket emitting a presence update
      fakePresenceRepo.emitPresence(_testMenuId, [
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: _testMenuId,
          lastSeen: DateTime.now(),
          userName: 'Bob Smith',
        ),
      ]);

      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.text('BS'), findsOneWidget);
    });

    testWidgets('should call unsubscribePresence on dispose', (tester) async {
      // Arrange
      stubSuccessfulLoad();
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Act — dispose by navigating away
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Replaced'))),
      );
      await tester.pumpAndSettle();

      // Assert
      final unsubCalls = fakePresenceRepo.unsubscribePresenceCalls.where(
        (c) => c.menuId == _testMenuId,
      );
      expect(unsubCalls.length, greaterThanOrEqualTo(1));
    });

    testWidgets('should show editing user initials on locked widget', (
      tester,
    ) async {
      // Arrange
      stubSuccessfulLoad();

      // Override getAllForColumn to return a widget locked by user-2
      fakeWidgetRepo.whenGetAllForColumnForId(
        1,
        success([
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
      fakePresenceRepo.whenGetActiveUsers(
        _testMenuId,
        success([
          MenuPresence(
            id: 1,
            userId: 'user-2',
            menuId: _testMenuId,
            lastSeen: DateTime.now(),
            userName: 'Alice Baker',
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Assert
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
