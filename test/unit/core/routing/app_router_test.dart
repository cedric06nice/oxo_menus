import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/login_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/home/presentation/screens/home_screen.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart'
    as size_entity;
import 'package:oxo_menus/features/menu_list/domain/use_cases/create_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/delete_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/list_menus_for_viewer_use_case.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/legacy_menu_list_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/screens/menu_list_screen.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';
import 'package:oxo_menus/features/settings/presentation/screens/settings_screen.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/legacy_pdf_preview_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/pdf_preview_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/pdf_preview_view_model.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/create_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/delete_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/list_sizes_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/update_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/legacy_admin_sizes_router.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/screens/admin_sizes_screen.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/view_models/admin_sizes_view_model.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/create_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_areas_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_sizes_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/legacy_admin_template_creator_router.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/screens/admin_template_creator_screen.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/view_models/admin_template_creator_view_model.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/legacy_admin_templates_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/screens/admin_templates_screen.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
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
import '../../../fakes/fake_connectivity_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
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

/// No-op [ListMenusForViewerUseCase] used by [_buildLegacyMenuListVm] so the
/// legacy `/menus` host can stand up a [MenuListViewModel] without touching a
/// real `DirectusDataSource`.
class _StubListMenusForViewerUseCase implements ListMenusForViewerUseCase {
  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async =>
      const Success(<Menu>[]);
}

class _StubCreateMenuUseCase implements CreateMenuUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(CreateMenuInput input) async =>
      const Failure(UnauthorizedError());
}

class _StubDeleteMenuUseCase implements DeleteMenuUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

/// Builds a [MenuListViewModel] backed entirely by stubs — used by the router
/// tests so the Phase 18 legacy `/menus` host can mount [MenuListScreen]
/// without spinning up a real `DirectusDataSource`. Mirrors the existing
/// [`_FakeDuplicateMenuUseCase`] pattern above.
MenuListViewModel _buildLegacyMenuListVm(
  BuildContext context,
  AppContainer container,
) {
  return MenuListViewModel(
    listMenusForViewer: _StubListMenusForViewerUseCase(),
    createMenu: _StubCreateMenuUseCase(),
    deleteMenu: _StubDeleteMenuUseCase(),
    duplicateMenu: _FakeDuplicateMenuUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: LegacyMenuListRouter(GoRouterLegacyNavigator(context)),
  );
}

/// No-op [ListTemplatesForAdminUseCase] used by [_buildLegacyAdminTemplatesVm]
/// so the legacy `/admin/templates` host can stand up an
/// [AdminTemplatesViewModel] without touching a real `DirectusDataSource`.
class _StubListTemplatesForAdminUseCase
    implements ListTemplatesForAdminUseCase {
  @override
  Future<Result<List<Menu>, DomainError>> execute(
    ListTemplatesForAdminInput input,
  ) async => const Success(<Menu>[]);
}

class _StubDeleteTemplateUseCase implements DeleteTemplateUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

/// Builds an [AdminTemplatesViewModel] backed entirely by stubs — used by the
/// router tests so the Phase 19 legacy `/admin/templates` host can mount
/// [AdminTemplatesScreen] without spinning up a real `DirectusDataSource`.
AdminTemplatesViewModel _buildLegacyAdminTemplatesVm(
  BuildContext context,
  AppContainer container,
) {
  return AdminTemplatesViewModel(
    listTemplates: _StubListTemplatesForAdminUseCase(),
    deleteTemplate: _StubDeleteTemplateUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: LegacyAdminTemplatesRouter(GoRouterLegacyNavigator(context)),
  );
}

/// Empty-list [ListSizesForAdminUseCase] used by [_buildLegacyAdminSizesVm] so
/// the legacy `/admin/sizes` host can stand up an [AdminSizesViewModel]
/// without touching a real `DirectusDataSource`.
class _StubListSizesForAdminUseCase implements ListSizesForAdminUseCase {
  @override
  Future<Result<List<size_entity.Size>, DomainError>> execute(
    ListSizesForAdminInput input,
  ) async => const Success(<size_entity.Size>[]);
}

class _StubCreateSizeUseCase implements CreateSizeUseCase {
  @override
  Future<Result<size_entity.Size, DomainError>> execute(
    CreateSizeInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdateSizeUseCase implements UpdateSizeUseCase {
  @override
  Future<Result<size_entity.Size, DomainError>> execute(
    UpdateSizeInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDeleteSizeUseCase implements DeleteSizeUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

/// Builds an [AdminSizesViewModel] backed entirely by stubs — used by the
/// router tests so the Phase 20 legacy `/admin/sizes` host can mount
/// [AdminSizesScreen] without spinning up a real `DirectusDataSource`.
AdminSizesViewModel _buildLegacyAdminSizesVm(
  BuildContext context,
  AppContainer container,
) {
  return AdminSizesViewModel(
    listSizes: _StubListSizesForAdminUseCase(),
    createSize: _StubCreateSizeUseCase(),
    updateSize: _StubUpdateSizeUseCase(),
    deleteSize: _StubDeleteSizeUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: LegacyAdminSizesRouter(GoRouterLegacyNavigator(context)),
  );
}

/// Empty-list [ListSizesForCreatorUseCase] used by
/// [_buildLegacyAdminTemplateCreatorVm] so the legacy
/// `/admin/templates/create` host can stand up an
/// [AdminTemplateCreatorViewModel] without touching a real
/// `DirectusDataSource`.
class _StubListSizesForCreatorUseCase implements ListSizesForCreatorUseCase {
  @override
  Future<Result<List<size_entity.Size>, DomainError>> execute(
    NoInput input,
  ) async => const Success(<size_entity.Size>[]);
}

class _StubListAreasForCreatorUseCase implements ListAreasForCreatorUseCase {
  @override
  Future<Result<List<Area>, DomainError>> execute(NoInput input) async =>
      const Success(<Area>[]);
}

class _StubCreateTemplateUseCase implements CreateTemplateUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(CreateTemplateInput input) async =>
      const Failure(UnauthorizedError());
}

/// Builds an [AdminTemplateCreatorViewModel] backed entirely by stubs — used
/// by the router tests so the Phase 21 legacy `/admin/templates/create` host
/// can mount [AdminTemplateCreatorScreen] without spinning up a real
/// `DirectusDataSource`.
AdminTemplateCreatorViewModel _buildLegacyAdminTemplateCreatorVm(
  BuildContext context,
  AppContainer container,
) {
  return AdminTemplateCreatorViewModel(
    listSizes: _StubListSizesForCreatorUseCase(),
    listAreas: _StubListAreasForCreatorUseCase(),
    createTemplate: _StubCreateTemplateUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: LegacyAdminTemplateCreatorRouter(GoRouterLegacyNavigator(context)),
  );
}

/// [GenerateMenuPdfUseCase] that always fails. Used by the Phase 22 router
/// test so the legacy `/menus/pdf/:id` host can mount [PdfPreviewScreen]
/// without spinning up a real `DirectusDataSource` — the screen settles into
/// its error state immediately, which is enough for the cutover assertion.
class _StubGenerateMenuPdfUseCase implements GenerateMenuPdfUseCase {
  @override
  Future<Result<GenerateMenuPdfOutput, DomainError>> execute(
    GenerateMenuPdfInput input,
  ) async => const Failure(NetworkError('stub'));
}

/// Builds a [PdfPreviewViewModel] backed entirely by stubs — used by the
/// router tests so the Phase 22 legacy `/menus/pdf/:id` host can mount
/// [PdfPreviewScreen] without spinning up a real `DirectusDataSource`.
PdfPreviewViewModel _buildLegacyPdfPreviewVm(
  BuildContext context,
  AppContainer container,
  int menuId,
) {
  return PdfPreviewViewModel(
    menuId: menuId,
    generatePdf: _StubGenerateMenuPdfUseCase(),
    router: LegacyPdfPreviewRouter(GoRouterLegacyNavigator(context)),
  );
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
      // Phase 18 — the legacy /menus GoRoute mounts MenuListScreen, whose
      // ViewModel needs a live DirectusDataSource. Override the builder so
      // the router tests can mount the screen without one.
      legacyMenuListViewModelBuilderProvider.overrideWithValue(
        _buildLegacyMenuListVm,
      ),
      // Phase 19 — the legacy /admin/templates GoRoute mounts
      // AdminTemplatesScreen, whose ViewModel needs a live DirectusDataSource.
      // Override the builder so the router tests can mount the screen
      // without one.
      legacyAdminTemplatesViewModelBuilderProvider.overrideWithValue(
        _buildLegacyAdminTemplatesVm,
      ),
      // Phase 20 — the legacy /admin/sizes GoRoute mounts AdminSizesScreen,
      // whose ViewModel needs a live DirectusDataSource. Override the builder
      // so the router tests can mount the screen without one.
      legacyAdminSizesViewModelBuilderProvider.overrideWithValue(
        _buildLegacyAdminSizesVm,
      ),
      // Phase 21 — the legacy /admin/templates/create GoRoute mounts
      // AdminTemplateCreatorScreen, whose ViewModel needs a live
      // DirectusDataSource. Override the builder so the router tests can mount
      // the screen without one.
      legacyAdminTemplateCreatorViewModelBuilderProvider.overrideWithValue(
        _buildLegacyAdminTemplateCreatorVm,
      ),
      // Phase 22 — the legacy /menus/pdf/:id GoRoute mounts PdfPreviewScreen,
      // whose ViewModel needs a live DirectusDataSource. Override the builder
      // so the router tests can mount the screen without one.
      legacyPdfPreviewViewModelBuilderProvider.overrideWithValue(
        _buildLegacyPdfPreviewVm,
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

  // Phase 17 — the legacy /home GoRoute now hosts the MVVM HomeScreen
  // directly instead of the retired HomePage widget. This test pins the
  // cutover so the screen cannot silently regress.
  group('AppRouter — legacy /home hosts MVVM screen', () {
    testWidgets('/home mounts HomeScreen', (tester) async {
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

      router.go('/home');
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  // Phase 18 — the legacy /menus GoRoute now hosts the MVVM MenuListScreen
  // directly instead of the retired MenuListPage widget. This test pins the
  // cutover so the screen cannot silently regress.
  group('AppRouter — legacy /menus hosts MVVM screen', () {
    testWidgets('/menus mounts MenuListScreen', (tester) async {
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

      expect(find.byType(MenuListScreen), findsOneWidget);
    });
  });

  // Phase 19 — the legacy /admin/templates GoRoute now hosts the MVVM
  // AdminTemplatesScreen directly instead of the retired AdminTemplatesPage
  // widget. This test pins the cutover so the screen cannot silently regress.
  group('AppRouter — legacy /admin/templates hosts MVVM screen', () {
    testWidgets('/admin/templates mounts AdminTemplatesScreen', (tester) async {
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

      expect(find.byType(AdminTemplatesScreen), findsOneWidget);
    });
  });

  // Phase 20 — the legacy /admin/sizes GoRoute now hosts the MVVM
  // AdminSizesScreen directly instead of the retired AdminSizesPage widget.
  // This test pins the cutover so the screen cannot silently regress.
  group('AppRouter — legacy /admin/sizes hosts MVVM screen', () {
    testWidgets('/admin/sizes mounts AdminSizesScreen', (tester) async {
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

      router.go('/admin/sizes');
      await tester.pumpAndSettle();

      expect(find.byType(AdminSizesScreen), findsOneWidget);
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

  // Phase 21 — the legacy /admin/templates/create GoRoute now hosts the MVVM
  // AdminTemplateCreatorScreen directly instead of the retired
  // AdminTemplateCreatorPage widget. This test pins the cutover so the screen
  // cannot silently regress.
  //
  // The /admin/templates/:id legacy route was removed in Phase 11. The
  // template editor is now served by MainRouter at
  // /app/admin/templates/{id}/edit (see main_router_test.dart and
  // route_config_test.dart).
  group('AppRouter — legacy /admin/templates/create hosts MVVM screen', () {
    testWidgets('/admin/templates/create mounts AdminTemplateCreatorScreen', (
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

      router.go('/admin/templates/create');
      await tester.pumpAndSettle();

      expect(find.byType(AdminTemplateCreatorScreen), findsOneWidget);
    });
  });

  // Phase 22 — the legacy /menus/pdf/:id GoRoute now hosts the MVVM
  // PdfPreviewScreen directly instead of the retired PdfPreviewPage widget.
  // This test pins the cutover so the screen cannot silently regress.
  group('AppRouter — legacy /menus/pdf/:id hosts MVVM screen', () {
    testWidgets('/menus/pdf/1 mounts PdfPreviewScreen', (tester) async {
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

      router.go('/menus/pdf/1');
      await tester.pumpAndSettle();

      expect(find.byType(PdfPreviewScreen), findsOneWidget);
    });
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
