import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/login_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/settings/presentation/screens/settings_screen.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/pages/admin_template_creator_page.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_area_repository.dart';
import '../../../fakes/fake_connectivity_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_size_repository.dart';
import '../../../fakes/builders/user_builder.dart';
import '../../../fakes/reflectable_bootstrap.dart';

// ---------------------------------------------------------------------------
// Local test-only DuplicateMenuUseCase fake
// ---------------------------------------------------------------------------

/// Extends [DuplicateMenuUseCase] and satisfies all required repository
/// constructor args with no-op stubs so tests can override execute() behaviour.
class _FakeDuplicateMenuUseCase extends DuplicateMenuUseCase {
  _FakeDuplicateMenuUseCase()
    : super(
        fetchMenuTreeUseCase: _ThrowFetchMenuTreeUseCase(),
        menuRepository: _ThrowMenuRepository(),
        pageRepository: _ThrowPageRepository(),
        containerRepository: _ThrowContainerRepository(),
        columnRepository: _ThrowColumnRepository(),
        widgetRepository: _ThrowWidgetRepository(),
        sizeRepository: _ThrowSizeRepository(),
      );
}

// Minimal throw-only stubs used solely to satisfy DuplicateMenuUseCase constructor

class _ThrowFetchMenuTreeUseCase extends FetchMenuTreeUseCase {
  _ThrowFetchMenuTreeUseCase()
    : super(
        menuRepository: _ThrowMenuRepository(),
        pageRepository: _ThrowPageRepository(),
        containerRepository: _ThrowContainerRepository(),
        columnRepository: _ThrowColumnRepository(),
        widgetRepository: _ThrowWidgetRepository(),
      );

  @override
  Future<Result<MenuTree, DomainError>> execute(int menuId) async {
    throw StateError('_ThrowFetchMenuTreeUseCase.execute should not be called');
  }
}

class _ThrowMenuRepository implements MenuRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowMenuRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowPageRepository implements PageRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowPageRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowContainerRepository implements ContainerRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowContainerRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowColumnRepository implements ColumnRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowColumnRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowWidgetRepository implements WidgetRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowWidgetRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowSizeRepository implements SizeRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowSizeRepository.${i.memberName} called unexpectedly',
  );
}

/// Static [AppVersionGateway] used by router tests that mount the MVVM
/// Settings screen — avoids invoking the real `package_info_plus` plugin which
/// is not available in the unit-test sandbox.
class _FakeAppVersionGateway implements AppVersionGateway {
  @override
  Future<String> read() async => '1.0.0';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds the minimal [ProviderScope] required for the router to
/// function without hitting real infrastructure.
///
/// [fakeAuth] — pre-configured with a [defaultTryRestoreSessionResponse].
/// [fakeMenu] — pre-configured with a listAll and getById response.
/// [extraOverrides] — additional provider overrides appended after the defaults.
Widget _buildApp({
  required FakeAuthRepository fakeAuth,
  required FakeMenuRepository fakeMenu,
  List<dynamic> extraOverrides = const [],
  void Function(GoRouter)? onRouter,
  AppVersionGateway? appVersionGateway,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(fakeAuth),
      menuRepositoryProvider.overrideWithValue(fakeMenu),
      duplicateMenuUseCaseProvider.overrideWithValue(
        _FakeDuplicateMenuUseCase(),
      ),
      // Phase 15 — the legacy /login, /forgot-password, /reset-password
      // GoRoutes mount the MVVM screens directly, which read use cases and
      // gateways through the AppContainer. Wire it up so the same
      // AuthGateway backs the auth state machine and the auth screens.
      appContainerProvider.overrideWith(
        (ref) => AppContainer(
          authGateway: ref.watch(authGatewayProvider),
          connectivityGateway: ConnectivityGateway(
            repository: FakeConnectivityRepository()
              ..whenCheckConnectivity(ConnectivityStatus.online),
          ),
          appVersionGateway: appVersionGateway,
        ),
      ),
      ...extraOverrides.cast(),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(appRouterProvider);
        onRouter?.call(router);
        return MaterialApp.router(routerConfig: router);
      },
    ),
  );
}

/// Configures [FakeMenuRepository] with the empty-list defaults that
/// nearly every router test needs so pages don't throw on load.
void _configureMenuRepository(FakeMenuRepository repo) {
  repo.whenListAll(const Success([]));
  repo.whenGetById(const Failure(NotFoundError()));
}

void main() {
  setUpAll(initializeReflectableForTests);

  group('AppRouter — auth guards', () {
    testWidgets(
      'should redirect unauthenticated user to /login when visiting splash',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        await tester.pumpWidget(
          _buildApp(fakeAuth: fakeAuth, fakeMenu: fakeMenu),
        );
        await tester.pumpAndSettle();

        expect(find.text('OXO Menus'), findsOneWidget);
      },
    );

    testWidgets(
      'should redirect authenticated user to /home when visiting splash',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        await tester.pumpWidget(
          _buildApp(fakeAuth: fakeAuth, fakeMenu: fakeMenu),
        );
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      },
    );

    testWidgets(
      'should redirect unauthenticated user to /login when navigating to /menus',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/menus');
        await tester.pumpAndSettle();

        expect(find.text('OXO Menus'), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);
      },
    );

    testWidgets(
      'should redirect authenticated user away from /login to /home',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/login');
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      },
    );
  });

  group('AppRouter — admin guards', () {
    testWidgets(
      'should block non-admin user from /admin/templates and redirect to /home',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/admin/templates');
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('No templates found'), findsNothing);
      },
    );

    testWidgets('should allow admin user to access /admin/templates', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildAdminUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/admin/templates');
      await tester.pumpAndSettle();

      expect(find.text('No templates found'), findsOneWidget);
    });

    testWidgets(
      'should block non-admin user from /admin/sizes and redirect to /home',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/admin/sizes');
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      },
    );

    testWidgets(
      'should block non-admin user from /admin/exportable_menus and redirect to /home',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/admin/exportable_menus');
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      },
    );
  });

  group('AppRouter — public routes accessible when unauthenticated', () {
    testWidgets(
      'should allow unauthenticated user to access /forgot-password',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/forgot-password');
        await tester.pumpAndSettle();

        expect(find.text('Forgot Password'), findsOneWidget);
      },
    );

    testWidgets('should allow unauthenticated user to access /reset-password', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = const Failure(
        UnauthorizedError(),
      );

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/reset-password?token=abc123');
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsAtLeast(1));
      expect(find.byKey(const Key('login_button')), findsNothing);
    });
  });

  // Phase 15 — the legacy /login, /forgot-password, /reset-password GoRoutes
  // now host the MVVM screens directly (LoginScreen, ForgotPasswordScreen,
  // ResetPasswordScreen) instead of the retired *_page.dart widgets. These
  // tests pin the cutover so the screens cannot silently regress.
  group('AppRouter — legacy auth paths host MVVM screens', () {
    testWidgets('/login mounts LoginScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = const Failure(
        UnauthorizedError(),
      );

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/login');
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('/forgot-password mounts ForgotPasswordScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = const Failure(
        UnauthorizedError(),
      );

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/forgot-password');
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets(
      '/reset-password?token=… mounts ResetPasswordScreen with a usable token',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/reset-password?token=abc123');
        await tester.pumpAndSettle();

        expect(find.byType(ResetPasswordScreen), findsOneWidget);
        // Token is captured — the screen renders the form, not the
        // missing-token branch.
        expect(find.byKey(const Key('reset_password_button')), findsOneWidget);
        expect(find.text('Invalid or missing reset token'), findsNothing);
      },
    );

    testWidgets('/reset-password without a token mounts ResetPasswordScreen in '
        'missing-token branch', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = const Failure(
        UnauthorizedError(),
      );

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/reset-password');
      await tester.pumpAndSettle();

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text('Invalid or missing reset token'), findsOneWidget);
    });
  });

  // Phase 16 — the legacy /settings GoRoute now hosts the MVVM SettingsScreen
  // directly instead of the retired SettingsPage widget. This test pins the
  // cutover so the screen cannot silently regress.
  group('AppRouter — legacy /settings hosts MVVM screen', () {
    testWidgets('/settings mounts SettingsScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          appVersionGateway: _FakeAppVersionGateway(),
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('AppRouter — authenticated routes reachable', () {
    testWidgets('should render /menus page for authenticated user', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/menus');
      await tester.pumpAndSettle();

      expect(find.text('Menus'), findsAtLeast(1));
    });

    testWidgets('should render /settings page for authenticated user', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsAtLeast(1));
    });

    // Phase 12 retired the legacy /menus/:id GoRoute — the menu editor lives
    // on the migrated MainRouter at /app/menus/{id}/edit and is exercised by
    // the MenuEditor* tests under features/menu_editor/.
  });

  group('AppRouter — admin template routes', () {
    testWidgets('should render /admin/templates/create page for admin user', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildAdminUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      final fakeSize = FakeSizeRepository();
      fakeSize.whenGetAll(const Success([]));

      final fakeArea = FakeAreaRepository();
      fakeArea.whenGetAll(const Success([]));

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          extraOverrides: [
            sizeRepositoryProvider.overrideWithValue(fakeSize),
            areaRepositoryProvider.overrideWithValue(fakeArea),
          ],
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/admin/templates/create');
      await tester.pumpAndSettle();

      expect(find.byType(AdminTemplateCreatorPage), findsOneWidget);
    });

    // The /admin/templates/:id legacy route was removed in Phase 11. The
    // template editor is now served by MainRouter at
    // /app/admin/templates/{id}/edit (see main_router_test.dart and
    // route_config_test.dart).
  });

  group('AppRouter — deep linking', () {
    testWidgets(
      'should redirect deep link to /login when user is unauthenticated',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/menus/456');
        await tester.pumpAndSettle();

        expect(find.text('OXO Menus'), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);
      },
    );

    // Deep-link to /menus/:id was retired in Phase 12. The migrated equivalent
    // (/app/menus/{id}/edit) is exercised by the MenuEditor route tests under
    // features/menu_editor/.

    // The deep-link to /admin/templates/:id was retired in Phase 11. The
    // migrated equivalent (/app/admin/templates/{id}/edit) is exercised in
    // route_config_test.dart and main_router_test.dart.
  });
}
