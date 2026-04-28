import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/core/routing/migration/main_router_host.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/admin_exportable_menus_page.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/admin_sizes_page.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/pages/admin_template_creator_page.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/legacy_admin_templates_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/screens/admin_templates_screen.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/legacy_auth_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/login_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/forgot_password_view_model.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/login_view_model.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/reset_password_view_model.dart';
import 'package:oxo_menus/features/home/domain/use_cases/get_home_overview_use_case.dart';
import 'package:oxo_menus/features/home/presentation/routing/legacy_home_router.dart';
import 'package:oxo_menus/features/home/presentation/screens/home_screen.dart';
import 'package:oxo_menus/features/home/presentation/view_models/home_view_model.dart';
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu_editor/presentation/pages/pdf_preview_page.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/create_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/delete_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/list_menus_for_viewer_use_case.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/legacy_menu_list_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/screens/menu_list_screen.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_app_version_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_settings_overview_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/request_password_reset_use_case.dart'
    as settings_request_password_reset;
import 'package:oxo_menus/features/settings/domain/use_cases/set_admin_view_as_user_use_case.dart';
import 'package:oxo_menus/features/settings/presentation/routing/legacy_settings_router.dart';
import 'package:oxo_menus/features/settings/presentation/screens/settings_screen.dart';
import 'package:oxo_menus/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/app_shell.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';

/// Listenable that notifies when auth state changes
class AuthNotifierListenable extends ChangeNotifier {
  AuthNotifierListenable(this._ref) {
    _ref.listen(authProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

/// Provider for the auth listenable used by GoRouter
final authListenableProvider = Provider<AuthNotifierListenable>((ref) {
  return AuthNotifierListenable(ref);
});

/// Splash screen shown while checking authentication status
class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline =
        ref.watch(connectivityProvider).value == ConnectivityStatus.offline;

    return Scaffold(
      body: Column(
        children: [
          if (isOffline) const OfflineBanner(),
          const Expanded(child: Center(child: AdaptiveLoadingIndicator())),
        ],
      ),
    );
  }
}

/// App router configuration using go_router
///
/// Provides navigation with authentication guards and route management
final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authListenableProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      // Check if still loading/checking auth
      final isLoading = authState.maybeWhen(
        initial: () => true,
        loading: () => true,
        orElse: () => false,
      );

      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final isAdmin = authState.maybeWhen(
        authenticated: (user) => user.role == UserRole.admin,
        orElse: () => false,
      );

      final isGoingToSplash = state.matchedLocation == AppRoutes.splash;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;
      final isGoingToAdminRoute = state.matchedLocation.startsWith('/admin');

      // If loading, stay on or go to splash
      if (isLoading) {
        return isGoingToSplash ? null : AppRoutes.splash;
      }

      // If on splash and not loading, redirect based on auth status
      if (isGoingToSplash) {
        return isAuthenticated ? AppRoutes.home : AppRoutes.login;
      }

      // If not authenticated and not going to a public route, redirect to login
      final isGoingToPublicRoute =
          isGoingToLogin ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.resetPassword;
      if (!isAuthenticated && !isGoingToPublicRoute) {
        return AppRoutes.login;
      }

      // If authenticated and going to login, redirect to home
      if (isAuthenticated && isGoingToLogin) {
        return AppRoutes.home;
      }

      // If not admin and going to admin route, redirect to home
      if (isGoingToAdminRoute && !isAdmin) {
        return AppRoutes.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      // Phase 15 — auth screens are served by the MVVM stack at the legacy
      // paths. The retired `*_page.dart` widgets used to live here. Each host
      // owns the ViewModel and disposes it when the route leaves the stack.
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          final container = ref.watch(appContainerProvider);
          return _LegacyLoginRouteHost(container: container);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) {
          final container = ref.watch(appContainerProvider);
          return _LegacyForgotPasswordRouteHost(container: container);
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final container = ref.watch(appContainerProvider);
          return _LegacyResetPasswordRouteHost(
            container: container,
            token: state.uri.queryParameters['token'],
          );
        },
      ),
      // Phase 0 bridge: a single sub-tree under '/app' is rendered by the new
      // MainRouter. Migrated features push their RoutePage onto MainRouter;
      // un-migrated features stay on go_router.
      GoRoute(
        path: '/app',
        name: 'app-root',
        builder: (context, state) {
          final container = ref.watch(appContainerProvider);
          return MainRouterHost(container: container);
        },
      ),
      // All authenticated routes wrapped in AppShell for persistent navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              return _LegacyHomeRouteHost(container: container);
            },
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              return _LegacySettingsRouteHost(container: container);
            },
          ),
          GoRoute(
            path: AppRoutes.menus,
            name: 'menus',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              final builder = ref.read(legacyMenuListViewModelBuilderProvider);
              return _LegacyMenuListRouteHost(
                container: container,
                builder: builder,
              );
            },
            routes: [
              GoRoute(
                path: 'pdf/:id',
                name: 'menu-pdf',
                builder: (context, state) {
                  final int menuId = int.parse(state.pathParameters['id']!);
                  final displayOptions = state.extra as MenuDisplayOptions?;
                  return PdfPreviewPage(
                    menuId: menuId,
                    displayOptions: displayOptions,
                  );
                },
              ),
              // The menu editor is served by the migrated MainRouter at
              // `/app/menus/{id}/edit` (Phase 12). The legacy /menus/:id
              // route is intentionally absent.
            ],
          ),
          GoRoute(
            path: AppRoutes.adminSizes,
            name: 'admin-sizes',
            builder: (context, state) => const AdminSizesPage(),
          ),
          GoRoute(
            path: AppRoutes.adminExportableMenus,
            name: 'admin-exportable-menus',
            builder: (context, state) => const AdminExportableMenusPage(),
          ),
          GoRoute(
            path: AppRoutes.adminTemplates,
            name: 'admin-templates',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              final builder = ref.read(
                legacyAdminTemplatesViewModelBuilderProvider,
              );
              return _LegacyAdminTemplatesRouteHost(
                container: container,
                builder: builder,
              );
            },
            routes: [
              GoRoute(
                path: 'create',
                name: 'admin-template-create',
                builder: (context, state) => const AdminTemplateCreatorPage(),
              ),
              // The admin template editor is served by the migrated MainRouter
              // at `/app/admin/templates/{id}/edit` (Phase 11). The legacy
              // /admin/templates/:id route is intentionally absent.
            ],
          ),
        ],
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Phase 15 — legacy auth route hosts
//
// Each host is a small StatefulWidget that owns the ViewModel for its screen
// for the lifetime of the legacy GoRoute. The MVVM auth screens are pure
// (no Riverpod, no BuildContext use), so the host is the single place that
// bridges go_router's `BuildContext` into the screen via `LegacyAuthRouter`.
// These will be deleted when the auth feature is fully cut over to the
// MainRouter stack.
// ---------------------------------------------------------------------------

class _LegacyLoginRouteHost extends StatefulWidget {
  const _LegacyLoginRouteHost({required this.container});

  final AppContainer container;

  @override
  State<_LegacyLoginRouteHost> createState() => _LegacyLoginRouteHostState();
}

class _LegacyLoginRouteHostState extends State<_LegacyLoginRouteHost> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(
      login: LoginUseCase(gateway: widget.container.authGateway),
      router: LegacyAuthRouter(GoRouterLegacyNavigator(context)),
      connectivityGateway: widget.container.connectivityGateway,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(viewModel: _viewModel);
  }
}

class _LegacyForgotPasswordRouteHost extends StatefulWidget {
  const _LegacyForgotPasswordRouteHost({required this.container});

  final AppContainer container;

  @override
  State<_LegacyForgotPasswordRouteHost> createState() =>
      _LegacyForgotPasswordRouteHostState();
}

class _LegacyForgotPasswordRouteHostState
    extends State<_LegacyForgotPasswordRouteHost> {
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel(
      requestPasswordReset: RequestPasswordResetUseCase(
        gateway: widget.container.authGateway,
      ),
      router: LegacyAuthRouter(GoRouterLegacyNavigator(context)),
      connectivityGateway: widget.container.connectivityGateway,
      resetUrl: _resolveLegacyResetUrl(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ForgotPasswordScreen(viewModel: _viewModel);
  }
}

class _LegacyResetPasswordRouteHost extends StatefulWidget {
  const _LegacyResetPasswordRouteHost({
    required this.container,
    required this.token,
  });

  final AppContainer container;
  final String? token;

  @override
  State<_LegacyResetPasswordRouteHost> createState() =>
      _LegacyResetPasswordRouteHostState();
}

class _LegacyResetPasswordRouteHostState
    extends State<_LegacyResetPasswordRouteHost> {
  late final ResetPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel(
      confirmPasswordReset: ConfirmPasswordResetUseCase(
        gateway: widget.container.authGateway,
      ),
      router: LegacyAuthRouter(GoRouterLegacyNavigator(context)),
      connectivityGateway: widget.container.connectivityGateway,
      token: widget.token,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResetPasswordScreen(viewModel: _viewModel);
  }
}

/// Resolves the deep-link URL embedded in the password-reset email when the
/// forgot-password screen is mounted under the legacy go_router tree. Mirrors
/// the resolver inside `ForgotPasswordRoutePage` so the legacy and migrated
/// hosts emit identical reset links.
String? _resolveLegacyResetUrl() {
  if (kIsWeb) {
    return Uri.base.resolve(AppRoutes.resetPassword).toString();
  }
  const resetUrlBase = String.fromEnvironment('RESET_URL_BASE');
  if (resetUrlBase.isNotEmpty) {
    return '$resetUrlBase${AppRoutes.resetPassword}';
  }
  return null;
}

// ---------------------------------------------------------------------------
// Phase 17 — legacy /home route host
//
// Owns the HomeViewModel for the lifetime of the legacy GoRoute under the
// AppShell. The MVVM HomeScreen is pure (no Riverpod, no BuildContext use) so
// this host bridges go_router into it via LegacyHomeRouter. Will be deleted
// when the home feature is fully cut over to the MainRouter stack.
// ---------------------------------------------------------------------------

class _LegacyHomeRouteHost extends StatefulWidget {
  const _LegacyHomeRouteHost({required this.container});

  final AppContainer container;

  @override
  State<_LegacyHomeRouteHost> createState() => _LegacyHomeRouteHostState();
}

class _LegacyHomeRouteHostState extends State<_LegacyHomeRouteHost> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      getHomeOverview: GetHomeOverviewUseCase(
        gateway: widget.container.authGateway,
      ),
      router: LegacyHomeRouter(GoRouterLegacyNavigator(context)),
      clock: DateTime.now,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(viewModel: _viewModel);
  }
}

// ---------------------------------------------------------------------------
// Phase 16 — legacy /settings route host
//
// Owns the SettingsViewModel for the lifetime of the legacy GoRoute under the
// AppShell. The MVVM SettingsScreen is pure (no Riverpod, no BuildContext use)
// so this host bridges go_router into it via LegacySettingsRouter. Will be
// deleted when the settings feature is fully cut over to the MainRouter stack.
// ---------------------------------------------------------------------------

class _LegacySettingsRouteHost extends StatefulWidget {
  const _LegacySettingsRouteHost({required this.container});

  final AppContainer container;

  @override
  State<_LegacySettingsRouteHost> createState() =>
      _LegacySettingsRouteHostState();
}

class _LegacySettingsRouteHostState extends State<_LegacySettingsRouteHost> {
  late final SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = widget.container;
    _viewModel = SettingsViewModel(
      getOverview: GetSettingsOverviewUseCase(
        authGateway: container.authGateway,
        adminViewAsUserGateway: container.adminViewAsUserGateway,
      ),
      getAppVersion: GetAppVersionUseCase(gateway: container.appVersionGateway),
      requestPasswordReset:
          settings_request_password_reset.RequestPasswordResetUseCase(
            authGateway: container.authGateway,
          ),
      logout: LogoutUseCase(authGateway: container.authGateway),
      setAdminViewAsUser: SetAdminViewAsUserUseCase(
        gateway: container.adminViewAsUserGateway,
      ),
      adminViewAsUserGateway: container.adminViewAsUserGateway,
      router: LegacySettingsRouter(GoRouterLegacyNavigator(context)),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(viewModel: _viewModel);
  }
}

// ---------------------------------------------------------------------------
// Phase 18 — legacy /menus route host
//
// Owns the MenuListViewModel for the lifetime of the legacy GoRoute under the
// AppShell. The MVVM MenuListScreen is pure (no Riverpod, no BuildContext
// reads) so this host bridges go_router into it via LegacyMenuListRouter. The
// downstream menu editor and admin template editor are already served by the
// migrated MainRouter (Phases 11 & 12), so the router deep-links straight into
// `/app/...` paths. Will be deleted when the menu list is fully cut over to
// the MainRouter stack.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultLegacyMenuListViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the legacy `/menus` route host to construct the
/// [MenuListViewModel] from the live [AppContainer]. The [BuildContext] is the
/// route's context and is used by the default builder to bridge into
/// `go_router` via [GoRouterLegacyNavigator].
typedef LegacyMenuListViewModelBuilder =
    MenuListViewModel Function(BuildContext context, AppContainer container);

/// Riverpod entry point for the legacy `/menus` view-model builder.
///
/// Defaults to [_defaultLegacyMenuListViewModelBuilder] which wires the live
/// menu repositories from the container's `DirectusDataSource`. Tests override
/// this with a stub builder that returns a [MenuListViewModel] backed by fake
/// use cases.
final legacyMenuListViewModelBuilderProvider =
    Provider<LegacyMenuListViewModelBuilder>(
      (ref) => _defaultLegacyMenuListViewModelBuilder,
    );

MenuListViewModel _defaultLegacyMenuListViewModelBuilder(
  BuildContext context,
  AppContainer container,
) {
  final dataSource = container.directusDataSource;
  final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
  final pageRepository = PageRepositoryImpl(dataSource: dataSource);
  final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
  final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
  final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
  final sizeRepository = SizeRepositoryImpl(dataSource: dataSource);
  final fetchMenuTreeUseCase = FetchMenuTreeUseCase(
    menuRepository: menuRepository,
    pageRepository: pageRepository,
    containerRepository: containerRepository,
    columnRepository: columnRepository,
    widgetRepository: widgetRepository,
  );
  final duplicateMenuUseCase = DuplicateMenuUseCase(
    fetchMenuTreeUseCase: fetchMenuTreeUseCase,
    menuRepository: menuRepository,
    pageRepository: pageRepository,
    containerRepository: containerRepository,
    columnRepository: columnRepository,
    widgetRepository: widgetRepository,
    sizeRepository: sizeRepository,
  );
  return MenuListViewModel(
    listMenusForViewer: ListMenusForViewerUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepository,
    ),
    createMenu: CreateMenuUseCase(menuRepository: menuRepository),
    deleteMenu: DeleteMenuUseCase(menuRepository: menuRepository),
    duplicateMenu: duplicateMenuUseCase,
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: LegacyMenuListRouter(GoRouterLegacyNavigator(context)),
  );
}

class _LegacyMenuListRouteHost extends StatefulWidget {
  const _LegacyMenuListRouteHost({
    required this.container,
    required this.builder,
  });

  final AppContainer container;
  final LegacyMenuListViewModelBuilder builder;

  @override
  State<_LegacyMenuListRouteHost> createState() =>
      _LegacyMenuListRouteHostState();
}

class _LegacyMenuListRouteHostState extends State<_LegacyMenuListRouteHost> {
  late final MenuListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.builder(context, widget.container);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuListScreen(viewModel: _viewModel);
  }
}

// ---------------------------------------------------------------------------
// Phase 19 — legacy /admin/templates route host
//
// Owns the AdminTemplatesViewModel for the lifetime of the legacy GoRoute
// under the AppShell. The MVVM AdminTemplatesScreen is pure (no Riverpod, no
// BuildContext reads) so this host bridges go_router into it via
// LegacyAdminTemplatesRouter. The downstream admin template editor is already
// served by the migrated MainRouter (Phase 11), so the router deep-links
// straight into `/app/admin/templates/{id}/edit`. Will be deleted when the
// admin templates list is fully cut over to the MainRouter stack.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultLegacyAdminTemplatesViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the legacy `/admin/templates` route host to construct the
/// [AdminTemplatesViewModel] from the live [AppContainer]. The [BuildContext]
/// is the route's context and is used by the default builder to bridge into
/// `go_router` via [GoRouterLegacyNavigator].
typedef LegacyAdminTemplatesViewModelBuilder =
    AdminTemplatesViewModel Function(
      BuildContext context,
      AppContainer container,
    );

/// Riverpod entry point for the legacy `/admin/templates` view-model builder.
///
/// Defaults to [_defaultLegacyAdminTemplatesViewModelBuilder] which wires the
/// live menu repository from the container's `DirectusDataSource`. Tests
/// override this with a stub builder that returns an
/// [AdminTemplatesViewModel] backed by fake use cases.
final legacyAdminTemplatesViewModelBuilderProvider =
    Provider<LegacyAdminTemplatesViewModelBuilder>(
      (ref) => _defaultLegacyAdminTemplatesViewModelBuilder,
    );

AdminTemplatesViewModel _defaultLegacyAdminTemplatesViewModelBuilder(
  BuildContext context,
  AppContainer container,
) {
  final menuRepository = MenuRepositoryImpl(
    dataSource: container.directusDataSource,
  );
  return AdminTemplatesViewModel(
    listTemplates: ListTemplatesForAdminUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepository,
    ),
    deleteTemplate: DeleteTemplateUseCase(menuRepository: menuRepository),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: LegacyAdminTemplatesRouter(GoRouterLegacyNavigator(context)),
  );
}

class _LegacyAdminTemplatesRouteHost extends StatefulWidget {
  const _LegacyAdminTemplatesRouteHost({
    required this.container,
    required this.builder,
  });

  final AppContainer container;
  final LegacyAdminTemplatesViewModelBuilder builder;

  @override
  State<_LegacyAdminTemplatesRouteHost> createState() =>
      _LegacyAdminTemplatesRouteHostState();
}

class _LegacyAdminTemplatesRouteHostState
    extends State<_LegacyAdminTemplatesRouteHost> {
  late final AdminTemplatesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.builder(context, widget.container);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminTemplatesScreen(viewModel: _viewModel);
  }
}
