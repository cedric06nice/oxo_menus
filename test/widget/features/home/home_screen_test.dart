import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/home/domain/entities/home_overview.dart';
import 'package:oxo_menus/features/home/domain/use_cases/get_home_overview_use_case.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';
import 'package:oxo_menus/features/home/presentation/screens/home_screen.dart';
import 'package:oxo_menus/features/home/presentation/view_models/home_view_model.dart';
import 'package:oxo_menus/features/home/presentation/widgets/quick_action_card.dart';
import 'package:oxo_menus/features/home/presentation/widgets/role_badge.dart';
import 'package:oxo_menus/features/home/presentation/widgets/welcome_card.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

import '../../../helpers/build_view_model_test_harness.dart';

class _StubGetHomeOverviewUseCase implements GetHomeOverviewUseCase {
  _StubGetHomeOverviewUseCase(this._overview);

  final HomeOverview _overview;

  @override
  Result<HomeOverview, DomainError> execute(NoInput input) {
    return Success(_overview);
  }
}

class _RecordingHomeRouter implements HomeRouter {
  int menusCalls = 0;
  int settingsCalls = 0;
  int adminTemplatesCalls = 0;
  int adminTemplateCreateCalls = 0;
  int adminExportableMenusCalls = 0;

  @override
  void goToMenus() => menusCalls++;

  @override
  void goToSettings() => settingsCalls++;

  @override
  void goToAdminTemplates() => adminTemplatesCalls++;

  @override
  void goToAdminTemplateCreate() => adminTemplateCreateCalls++;

  @override
  void goToAdminExportableMenus() => adminExportableMenusCalls++;
}

const _admin = User(
  id: 'u-1',
  email: 'admin@example.com',
  firstName: 'Adam',
  role: UserRole.admin,
);
const _regular = User(
  id: 'u-2',
  email: 'bob@example.com',
  firstName: 'Bob',
  role: UserRole.user,
);

HomeViewModel _viewModelWith({
  HomeOverview overview = const HomeOverview(user: _regular, isAdmin: false),
  _RecordingHomeRouter? router,
  DateTime? now,
}) {
  return HomeViewModel(
    getHomeOverview: _StubGetHomeOverviewUseCase(overview),
    router: router ?? _RecordingHomeRouter(),
    clock: () => now ?? DateTime(2026, 4, 27, 9),
  );
}

void main() {
  group('HomeScreen — chrome', () {
    testWidgets('renders an AppBar with title "Home"', (tester) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    });

    testWidgets('renders a WelcomeCard with the greeting from the VM', (
      tester,
    ) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(
          overview: const HomeOverview(user: _admin, isAdmin: true),
          now: DateTime(2026, 4, 27, 9),
        ),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(find.byType(WelcomeCard), findsOneWidget);
      expect(find.text('Good morning, Adam!'), findsOneWidget);
    });

    testWidgets('renders a Quick Actions section header', (tester) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(find.text('Quick Actions'), findsOneWidget);
    });
  });

  group('HomeScreen — role badge', () {
    testWidgets('shows the Admin badge when the VM marks the user as admin', (
      tester,
    ) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(
          overview: const HomeOverview(user: _admin, isAdmin: true),
        ),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(find.byType(RoleBadge), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('shows the User badge for non-admin sessions', (tester) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(
          overview: const HomeOverview(user: _regular, isAdmin: false),
        ),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(find.text('User'), findsOneWidget);
    });
  });

  group('HomeScreen — quick actions', () {
    testWidgets('always renders the Menus quick action', (tester) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(find.byKey(const Key('quick_action_menus')), findsOneWidget);
      expect(find.text('OXO Menus'), findsOneWidget);
    });

    testWidgets('hides admin-only quick actions for regular users', (
      tester,
    ) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(
          overview: const HomeOverview(user: _regular, isAdmin: false),
        ),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(
        find.byKey(const Key('quick_action_admin_templates')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('quick_action_admin_template_create')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('quick_action_admin_exportable_menus')),
        findsNothing,
      );
    });

    testWidgets('shows admin-only quick actions for admin users', (
      tester,
    ) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(
          overview: const HomeOverview(user: _admin, isAdmin: true),
        ),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(
        find.byKey(const Key('quick_action_admin_templates')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('quick_action_admin_template_create')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('quick_action_admin_exportable_menus')),
        findsOneWidget,
      );
      expect(find.byType(QuickActionCard), findsNWidgets(4));
    });

    testWidgets('tapping the Menus action calls router.goToMenus', (
      tester,
    ) async {
      final router = _RecordingHomeRouter();
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(router: router),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      await tester.tap(find.byKey(const Key('quick_action_menus')));
      await tester.pump();

      expect(router.menusCalls, 1);
    });

    testWidgets(
      'tapping the Settings AppBar action calls router.goToSettings',
      (tester) async {
        final router = _RecordingHomeRouter();
        await pumpScreenWithViewModel<HomeViewModel>(
          tester,
          viewModel: _viewModelWith(router: router),
          screenBuilder: (vm) => HomeScreen(viewModel: vm),
        );

        await tester.tap(find.byKey(const Key('home_action_settings')));
        await tester.pump();

        expect(router.settingsCalls, 1);
      },
    );

    testWidgets('tapping Manage Templates calls router.goToAdminTemplates', (
      tester,
    ) async {
      final router = _RecordingHomeRouter();
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(
          overview: const HomeOverview(user: _admin, isAdmin: true),
          router: router,
        ),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      await tester.tap(find.byKey(const Key('quick_action_admin_templates')));
      await tester.pump();

      expect(router.adminTemplatesCalls, 1);
    });

    testWidgets(
      'tapping Create Template calls router.goToAdminTemplateCreate',
      (tester) async {
        final router = _RecordingHomeRouter();
        await pumpScreenWithViewModel<HomeViewModel>(
          tester,
          viewModel: _viewModelWith(
            overview: const HomeOverview(user: _admin, isAdmin: true),
            router: router,
          ),
          screenBuilder: (vm) => HomeScreen(viewModel: vm),
        );

        await tester.tap(
          find.byKey(const Key('quick_action_admin_template_create')),
        );
        await tester.pump();

        expect(router.adminTemplateCreateCalls, 1);
      },
    );

    testWidgets(
      'tapping Exportable Menus calls router.goToAdminExportableMenus',
      (tester) async {
        final router = _RecordingHomeRouter();
        await pumpScreenWithViewModel<HomeViewModel>(
          tester,
          viewModel: _viewModelWith(
            overview: const HomeOverview(user: _admin, isAdmin: true),
            router: router,
          ),
          screenBuilder: (vm) => HomeScreen(viewModel: vm),
        );

        await tester.tap(
          find.byKey(const Key('quick_action_admin_exportable_menus')),
        );
        await tester.pump();

        expect(router.adminExportableMenusCalls, 1);
      },
    );
  });

  group('HomeScreen — anonymous fallback', () {
    testWidgets('renders the fallback greeting when no user is signed in', (
      tester,
    ) async {
      await pumpScreenWithViewModel<HomeViewModel>(
        tester,
        viewModel: _viewModelWith(
          overview: const HomeOverview(user: null, isAdmin: false),
          now: DateTime(2026, 4, 27, 20),
        ),
        screenBuilder: (vm) => HomeScreen(viewModel: vm),
      );

      expect(find.text('Good evening, User!'), findsOneWidget);
    });
  });
}
