import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/home/home_page.dart';
import 'package:oxo_menus/presentation/pages/home/widgets/quick_action_card.dart';
import 'package:oxo_menus/presentation/pages/home/widgets/role_badge.dart';
import 'package:oxo_menus/presentation/pages/home/widgets/welcome_card.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/theme/app_theme.dart';
import 'package:oxo_menus/presentation/widgets/common/user_avatar_widget.dart';

void main() {
  const adminUser = User(
    id: '1',
    email: 'admin@example.com',
    firstName: 'Alice',
    lastName: 'Smith',
    role: UserRole.admin,
  );

  const regularUser = User(
    id: '2',
    email: 'user@example.com',
    firstName: 'Bob',
    lastName: 'Jones',
    role: UserRole.user,
  );

  const noNameUser = User(
    id: '3',
    email: 'noname@example.com',
    role: UserRole.user,
  );

  Widget createWidgetUnderTest({
    User? user,
    bool isAdmin = false,
    TargetPlatform? platform,
    ThemeData? theme,
    DateTime? now,
  }) {
    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(user),
        isAdminProvider.overrideWithValue(isAdmin),
      ],
      child: MaterialApp(
        theme:
            theme ??
            (platform != null
                ? AppTheme.light.copyWith(platform: platform)
                : AppTheme.light),
        home: HomePage(now: now ?? DateTime(2024, 1, 15, 9, 0)),
      ),
    );
  }

  group('HomePage greeting', () {
    testWidgets('displays morning greeting with user first name', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          user: adminUser,
          isAdmin: true,
          now: DateTime(2024, 1, 15, 9, 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Alice!'), findsOneWidget);
    });

    testWidgets('displays afternoon greeting', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          user: regularUser,
          now: DateTime(2024, 1, 15, 14, 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good afternoon, Bob!'), findsOneWidget);
    });

    testWidgets('displays evening greeting', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          user: regularUser,
          now: DateTime(2024, 1, 15, 19, 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good evening, Bob!'), findsOneWidget);
    });

    testWidgets('falls back to email prefix when no firstName', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          user: noNameUser,
          now: DateTime(2024, 1, 15, 9, 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good morning, noname!'), findsOneWidget);
    });
  });

  group('HomePage welcome card', () {
    testWidgets('contains a WelcomeCard with key', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('welcome_card')), findsOneWidget);
      expect(find.byType(WelcomeCard), findsOneWidget);
    });

    testWidgets('welcome card uses Card with primaryContainer color', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byKey(const Key('welcome_card')));
      final theme = AppTheme.light;
      expect(card.color, theme.colorScheme.primaryContainer);
    });

    testWidgets('contains UserAvatarWidget with radius 36', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      final avatar = tester.widget<UserAvatarWidget>(
        find.descendant(
          of: find.byKey(const Key('welcome_card')),
          matching: find.byType(UserAvatarWidget),
        ),
      );
      expect(avatar.radius, 36);
    });

    testWidgets('displays subtitle text', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage your menus and templates'), findsOneWidget);
    });
  });

  group('HomePage role badge', () {
    testWidgets('shows Admin badge with shield icon for admin', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RoleBadge), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    });

    testWidgets('shows User badge with person icon for regular user', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(user: regularUser));
      await tester.pumpAndSettle();

      expect(find.byType(RoleBadge), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('does not use Chip widget', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      // RoleBadge should not contain a Chip (old design)
      expect(
        find.descendant(
          of: find.byType(RoleBadge),
          matching: find.byType(Chip),
        ),
        findsNothing,
      );
    });
  });

  group('HomePage quick actions', () {
    testWidgets('displays Quick Actions header', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('displays OXO Menus action card', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(user: regularUser));
      await tester.pumpAndSettle();

      expect(find.text('OXO Menus'), findsOneWidget);
      expect(find.text('Browse and manage menus'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('QuickActionCard widget is used', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(user: regularUser));
      await tester.pumpAndSettle();

      expect(find.byType(QuickActionCard), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping OXO Menus navigates to /menus', (tester) async {
      String? navigatedTo;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                HomePage(now: DateTime(2024, 1, 15, 9, 0)),
          ),
          GoRoute(
            path: '/menus',
            builder: (context, state) {
              navigatedTo = '/menus';
              return const Scaffold(body: Text('Menus Page'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(regularUser),
            isAdminProvider.overrideWithValue(false),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OXO Menus'));
      await tester.pumpAndSettle();

      expect(navigatedTo, '/menus');
    });

    testWidgets('admin sees Manage Templates and Create Template cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Templates'), findsOneWidget);
      expect(find.text('Create Template'), findsOneWidget);
    });

    testWidgets('regular user does not see admin cards', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: regularUser, isAdmin: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Templates'), findsNothing);
      expect(find.text('Create Template'), findsNothing);
    });
  });

  group('HomePage layout', () {
    testWidgets('has ConstrainedBox with maxWidth 800', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final hasMax800 = constrainedBoxes.any(
        (box) => box.constraints.maxWidth == 800,
      );
      expect(hasMax800, isTrue);
    });

    testWidgets('uses LayoutBuilder for responsive grid', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: adminUser, isAdmin: true),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LayoutBuilder), findsAtLeastNWidgets(1));
    });
  });

  group('HomePage platform adaptation', () {
    testWidgets('iOS: QuickActionCard uses CupertinoButton', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(user: regularUser, platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(QuickActionCard),
          matching: find.byType(CupertinoButton),
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('macOS: QuickActionCard uses CupertinoButton', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          user: regularUser,
          platform: TargetPlatform.macOS,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(QuickActionCard),
          matching: find.byType(CupertinoButton),
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('Android: QuickActionCard uses InkWell', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          user: regularUser,
          platform: TargetPlatform.android,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(QuickActionCard),
          matching: find.byType(InkWell),
        ),
        findsAtLeastNWidgets(1),
      );
    });
  });

  group('HomePage dark mode', () {
    testWidgets('renders without errors in dark mode', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          user: adminUser,
          isAdmin: true,
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });
  });
}
