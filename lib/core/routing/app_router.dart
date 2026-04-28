import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/di/app_scope.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/oxo_router.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/create_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/delete_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_available_menus_for_bundles_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_menu_bundles_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/publish_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/update_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_route_adapter.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/screens/admin_exportable_menus_screen.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/view_models/admin_exportable_menus_view_model.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_bundle_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_menu_bundle_usecase.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/create_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/delete_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/list_sizes_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/update_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_route_adapter.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/screens/admin_sizes_screen.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/view_models/admin_sizes_view_model.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/create_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_areas_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_sizes_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_route_adapter.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/screens/admin_template_creator_screen.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/view_models/admin_template_creator_view_model.dart';
import 'package:oxo_menus/shared/data/repositories/area_repository_impl.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_page_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_page_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/duplicate_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_areas_for_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_sizes_for_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/load_template_for_editor_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/move_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/reorder_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_template_menu_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_route_adapter.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/screens/admin_template_editor_screen.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/view_models/admin_template_editor_view_model.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_route_adapter.dart';
import 'package:oxo_menus/features/admin_templates/presentation/screens/admin_templates_screen.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
import 'package:oxo_menus/features/collaboration/data/repositories/menu_subscription_repository_impl.dart';
import 'package:oxo_menus/features/collaboration/data/repositories/presence_repository_impl.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/auth_route_adapter.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/login_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/forgot_password_view_model.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/login_view_model.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/reset_password_view_model.dart';
import 'package:oxo_menus/features/home/domain/use_cases/get_home_overview_use_case.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_route_adapter.dart';
import 'package:oxo_menus/features/home/presentation/screens/home_screen.dart';
import 'package:oxo_menus/features/home/presentation/view_models/home_view_model.dart';
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/create_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/delete_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/load_menu_for_editor_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/lock_widget_for_editing_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/menu_presence_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/move_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/publish_exportable_bundles_for_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/save_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/unlock_widget_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/update_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/watch_menu_changes_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_route_adapter.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_route_adapter.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/menu_editor_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/pdf_preview_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/menu_editor_view_model.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/pdf_preview_view_model.dart';
import 'package:oxo_menus/shared/data/repositories/asset_loader_repository_impl.dart';
import 'package:oxo_menus/shared/data/repositories/file_repository_impl.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/create_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/delete_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/list_menus_for_viewer_use_case.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_route_adapter.dart';
import 'package:oxo_menus/features/menu_list/presentation/screens/menu_list_screen.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_app_version_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_settings_overview_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/request_password_reset_use_case.dart'
    as settings_request_password_reset;
import 'package:oxo_menus/features/settings/domain/use_cases/set_admin_view_as_user_use_case.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_route_adapter.dart';
import 'package:oxo_menus/features/settings/presentation/screens/settings_screen.dart';
import 'package:oxo_menus/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/app_shell.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';

/// Builds the production [OxoRouter] for the app.
///
/// Owns the per-route view-model builders and references the
/// [AppScopeData] supplied by the surrounding [AppScope]. Production wiring
/// constructs an [AppRouter] with only [scope]; tests pass per-route builder
/// overrides to swap in fake use cases without standing up a real
/// [DirectusDataSource].
class AppRouter {
  AppRouter({
    required this.scope,
    MenuListViewModelBuilder? menuListBuilder,
    AdminTemplatesViewModelBuilder? adminTemplatesBuilder,
    AdminSizesViewModelBuilder? adminSizesBuilder,
    AdminTemplateCreatorViewModelBuilder? adminTemplateCreatorBuilder,
    PdfPreviewViewModelBuilder? pdfPreviewBuilder,
    AdminExportableMenusViewModelBuilder? adminExportableMenusBuilder,
    MenuEditorViewModelBuilder? menuEditorBuilder,
    AdminTemplateEditorViewModelBuilder? adminTemplateEditorBuilder,
  }) : menuListBuilder = menuListBuilder ?? _defaultMenuListViewModelBuilder,
       adminTemplatesBuilder =
           adminTemplatesBuilder ?? _defaultAdminTemplatesViewModelBuilder,
       adminSizesBuilder =
           adminSizesBuilder ?? _defaultAdminSizesViewModelBuilder,
       adminTemplateCreatorBuilder =
           adminTemplateCreatorBuilder ??
           _defaultAdminTemplateCreatorViewModelBuilder,
       pdfPreviewBuilder =
           pdfPreviewBuilder ?? _defaultPdfPreviewViewModelBuilder,
       adminExportableMenusBuilder =
           adminExportableMenusBuilder ??
           _defaultAdminExportableMenusViewModelBuilder,
       menuEditorBuilder =
           menuEditorBuilder ?? _defaultMenuEditorViewModelBuilder,
       adminTemplateEditorBuilder =
           adminTemplateEditorBuilder ??
           _defaultAdminTemplateEditorViewModelBuilder;

  final AppScopeData scope;
  final MenuListViewModelBuilder menuListBuilder;
  final AdminTemplatesViewModelBuilder adminTemplatesBuilder;
  final AdminSizesViewModelBuilder adminSizesBuilder;
  final AdminTemplateCreatorViewModelBuilder adminTemplateCreatorBuilder;
  final PdfPreviewViewModelBuilder pdfPreviewBuilder;
  final AdminExportableMenusViewModelBuilder adminExportableMenusBuilder;
  final MenuEditorViewModelBuilder menuEditorBuilder;
  final AdminTemplateEditorViewModelBuilder adminTemplateEditorBuilder;

  AppContainer get container => scope.container;

  /// Construct the [OxoRouter]. Subscribers (e.g. `MaterialApp.router`) take
  /// the returned router and own its lifetime.
  OxoRouter build() {
    return OxoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: Listenable.merge(<Listenable>[
        scope.auth,
        scope.adminViewAsUser,
      ]),
      redirect: _redirect,
      shellBuilder: _buildShell,
      routes: _buildRoutes(),
    );
  }

  String? _redirect(OxoRouteState state) {
    final status = scope.auth.status;
    final isLoading =
        status is AuthStatusInitial || status is AuthStatusLoading;
    final isAuthenticated = status is AuthStatusAuthenticated;
    final isAdmin =
        status is AuthStatusAuthenticated &&
        status.user.role == UserRole.admin &&
        !scope.adminViewAsUser.value;

    final matchedLocation = state.matchedLocation;
    final isGoingToSplash = matchedLocation == AppRoutes.splash;
    final isGoingToLogin = matchedLocation == AppRoutes.login;
    final isGoingToAdminRoute = matchedLocation.startsWith('/admin');

    if (isLoading) {
      return isGoingToSplash ? null : AppRoutes.splash;
    }

    if (isGoingToSplash) {
      return isAuthenticated ? AppRoutes.home : AppRoutes.login;
    }

    final isGoingToPublicRoute =
        isGoingToLogin ||
        matchedLocation == AppRoutes.forgotPassword ||
        matchedLocation == AppRoutes.resetPassword;
    if (!isAuthenticated && !isGoingToPublicRoute) {
      return AppRoutes.login;
    }

    if (isAuthenticated && isGoingToLogin) {
      return AppRoutes.home;
    }

    if (isGoingToAdminRoute && !isAdmin) {
      return AppRoutes.home;
    }

    return null;
  }

  Widget _buildShell(
    BuildContext context,
    String currentLocation,
    Widget child,
  ) {
    return _AppShellHost(currentLocation: currentLocation, child: child);
  }

  List<OxoRoute> _buildRoutes() {
    return <OxoRoute>[
      OxoRoute(
        pattern: AppRoutes.splash,
        builder: (context, match) => const _SplashScreen(),
      ),
      // Auth screens are served by the MVVM stack at the canonical paths.
      // Each host owns the ViewModel and disposes it when the route leaves
      // the stack.
      OxoRoute(
        pattern: AppRoutes.login,
        builder: (context, match) => const _LoginRouteHost(),
      ),
      OxoRoute(
        pattern: AppRoutes.forgotPassword,
        builder: (context, match) => const _ForgotPasswordRouteHost(),
      ),
      OxoRoute(
        pattern: AppRoutes.resetPassword,
        builder: (context, match) =>
            _ResetPasswordRouteHost(token: match.queryParameters['token']),
      ),
      // Shell-bound routes — the OxoRouter wraps each of these in the
      // shellBuilder above before mounting the page.
      OxoRoute(
        pattern: AppRoutes.home,
        inShell: true,
        builder: (context, match) => const _HomeRouteHost(),
      ),
      OxoRoute(
        pattern: AppRoutes.settings,
        inShell: true,
        builder: (context, match) => const _SettingsRouteHost(),
      ),
      OxoRoute(
        pattern: AppRoutes.menus,
        inShell: true,
        builder: (context, match) =>
            _MenuListRouteHost(builder: menuListBuilder),
      ),
      OxoRoute(
        pattern: '/menus/pdf/:id',
        inShell: true,
        builder: (context, match) {
          final menuId = int.parse(match.pathParameters['id']!);
          return _PdfPreviewRouteHost(
            builder: pdfPreviewBuilder,
            menuId: menuId,
          );
        },
      ),
      OxoRoute(
        pattern: '/menus/:id',
        inShell: true,
        builder: (context, match) {
          final menuId = int.parse(match.pathParameters['id']!);
          return _MenuEditorRouteHost(
            builder: menuEditorBuilder,
            menuId: menuId,
          );
        },
      ),
      OxoRoute(
        pattern: AppRoutes.adminSizes,
        inShell: true,
        builder: (context, match) =>
            _AdminSizesRouteHost(builder: adminSizesBuilder),
      ),
      OxoRoute(
        pattern: AppRoutes.adminExportableMenus,
        inShell: true,
        builder: (context, match) => _AdminExportableMenusRouteHost(
          builder: adminExportableMenusBuilder,
        ),
      ),
      OxoRoute(
        pattern: AppRoutes.adminTemplateCreate,
        inShell: true,
        builder: (context, match) => _AdminTemplateCreatorRouteHost(
          builder: adminTemplateCreatorBuilder,
        ),
      ),
      OxoRoute(
        pattern: AppRoutes.adminTemplates,
        inShell: true,
        builder: (context, match) =>
            _AdminTemplatesRouteHost(builder: adminTemplatesBuilder),
      ),
      OxoRoute(
        pattern: '/admin/templates/:id',
        inShell: true,
        builder: (context, match) {
          final menuId = int.parse(match.pathParameters['id']!);
          return _AdminTemplateEditorRouteHost(
            builder: adminTemplateEditorBuilder,
            menuId: menuId,
          );
        },
      ),
    ];
  }
}

/// Splash screen shown while checking authentication status.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final connectivity = AppScope.of(context).connectivity;
    return ListenableBuilder(
      listenable: connectivity,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              if (connectivity.isOffline) const OfflineBanner(),
              const Expanded(child: Center(child: AdaptiveLoadingIndicator())),
            ],
          ),
        );
      },
    );
  }
}

/// Hosts the [AppShell] inside the authenticated shell route. Listens to
/// the auth, connectivity, and admin-view-as-user controllers so the shell
/// rebuilds when navigation gating changes.
class _AppShellHost extends StatelessWidget {
  const _AppShellHost({required this.currentLocation, required this.child});

  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        scope.auth,
        scope.connectivity,
        scope.adminViewAsUser,
      ]),
      builder: (context, _) {
        final status = scope.auth.status;
        final isAdmin =
            status is AuthStatusAuthenticated &&
            status.user.role == UserRole.admin &&
            !scope.adminViewAsUser.value;
        return AppShell(
          navigator: OxoRouterRouteNavigator(context),
          currentLocation: currentLocation,
          isAdmin: isAdmin,
          isOffline: scope.connectivity.isOffline,
          child: child,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Phase 15 — auth route hosts
//
// Each host is a small StatefulWidget that owns the ViewModel for its screen
// for the lifetime of the route. The MVVM auth screens are pure (no Riverpod,
// no BuildContext use), so the host is the single place that bridges the
// router's `BuildContext` into the screen via `AuthRouteAdapter`.
// ---------------------------------------------------------------------------

class _LoginRouteHost extends StatefulWidget {
  const _LoginRouteHost();

  @override
  State<_LoginRouteHost> createState() => _LoginRouteHostState();
}

class _LoginRouteHostState extends State<_LoginRouteHost> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = LoginViewModel(
      login: LoginUseCase(gateway: container.authGateway),
      router: AuthRouteAdapter(OxoRouterRouteNavigator(context)),
      connectivityGateway: container.connectivityGateway,
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

class _ForgotPasswordRouteHost extends StatefulWidget {
  const _ForgotPasswordRouteHost();

  @override
  State<_ForgotPasswordRouteHost> createState() =>
      _ForgotPasswordRouteHostState();
}

class _ForgotPasswordRouteHostState extends State<_ForgotPasswordRouteHost> {
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = ForgotPasswordViewModel(
      requestPasswordReset: RequestPasswordResetUseCase(
        gateway: container.authGateway,
      ),
      router: AuthRouteAdapter(OxoRouterRouteNavigator(context)),
      connectivityGateway: container.connectivityGateway,
      resetUrl: _resolveResetUrl(),
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

class _ResetPasswordRouteHost extends StatefulWidget {
  const _ResetPasswordRouteHost({required this.token});

  final String? token;

  @override
  State<_ResetPasswordRouteHost> createState() =>
      _ResetPasswordRouteHostState();
}

class _ResetPasswordRouteHostState extends State<_ResetPasswordRouteHost> {
  late final ResetPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = ResetPasswordViewModel(
      confirmPasswordReset: ConfirmPasswordResetUseCase(
        gateway: container.authGateway,
      ),
      router: AuthRouteAdapter(OxoRouterRouteNavigator(context)),
      connectivityGateway: container.connectivityGateway,
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

/// Resolves the deep-link URL embedded in the password-reset email. On web,
/// the URL is derived from the current origin; on native, the
/// `RESET_URL_BASE` build define supplies it (or `null` if absent).
String? _resolveResetUrl() {
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
// Phase 17 — /home route host
// ---------------------------------------------------------------------------

class _HomeRouteHost extends StatefulWidget {
  const _HomeRouteHost();

  @override
  State<_HomeRouteHost> createState() => _HomeRouteHostState();
}

class _HomeRouteHostState extends State<_HomeRouteHost> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = HomeViewModel(
      getHomeOverview: GetHomeOverviewUseCase(gateway: container.authGateway),
      router: HomeRouteAdapter(OxoRouterRouteNavigator(context)),
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
// Phase 16 — /settings route host
// ---------------------------------------------------------------------------

class _SettingsRouteHost extends StatefulWidget {
  const _SettingsRouteHost();

  @override
  State<_SettingsRouteHost> createState() => _SettingsRouteHostState();
}

class _SettingsRouteHostState extends State<_SettingsRouteHost> {
  late final SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
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
      router: SettingsRouteAdapter(OxoRouterRouteNavigator(context)),
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
// Phase 18 — /menus route host
// ---------------------------------------------------------------------------

/// Factory used by the `/menus` route host to construct the
/// [MenuListViewModel] from the live [AppContainer]. The [BuildContext] is the
/// route's context and is used by the default builder to bridge into the
/// [OxoRouter] via [OxoRouterRouteNavigator].
typedef MenuListViewModelBuilder =
    MenuListViewModel Function(BuildContext context, AppContainer container);

MenuListViewModel _defaultMenuListViewModelBuilder(
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
    router: MenuListRouteAdapter(OxoRouterRouteNavigator(context)),
  );
}

class _MenuListRouteHost extends StatefulWidget {
  const _MenuListRouteHost({required this.builder});

  final MenuListViewModelBuilder builder;

  @override
  State<_MenuListRouteHost> createState() => _MenuListRouteHostState();
}

class _MenuListRouteHostState extends State<_MenuListRouteHost> {
  late final MenuListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = widget.builder(context, container);
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
// Phase 19 — /admin/templates route host
// ---------------------------------------------------------------------------

typedef AdminTemplatesViewModelBuilder =
    AdminTemplatesViewModel Function(
      BuildContext context,
      AppContainer container,
    );

AdminTemplatesViewModel _defaultAdminTemplatesViewModelBuilder(
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
    router: AdminTemplatesRouteAdapter(OxoRouterRouteNavigator(context)),
  );
}

class _AdminTemplatesRouteHost extends StatefulWidget {
  const _AdminTemplatesRouteHost({required this.builder});

  final AdminTemplatesViewModelBuilder builder;

  @override
  State<_AdminTemplatesRouteHost> createState() =>
      _AdminTemplatesRouteHostState();
}

class _AdminTemplatesRouteHostState extends State<_AdminTemplatesRouteHost> {
  late final AdminTemplatesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = widget.builder(context, container);
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

// ---------------------------------------------------------------------------
// Phase 20 — /admin/sizes route host
// ---------------------------------------------------------------------------

typedef AdminSizesViewModelBuilder =
    AdminSizesViewModel Function(BuildContext context, AppContainer container);

AdminSizesViewModel _defaultAdminSizesViewModelBuilder(
  BuildContext context,
  AppContainer container,
) {
  final sizeRepository = SizeRepositoryImpl(
    dataSource: container.directusDataSource,
  );
  return AdminSizesViewModel(
    listSizes: ListSizesForAdminUseCase(
      authGateway: container.authGateway,
      sizeRepository: sizeRepository,
    ),
    createSize: CreateSizeUseCase(
      authGateway: container.authGateway,
      sizeRepository: sizeRepository,
    ),
    updateSize: UpdateSizeUseCase(
      authGateway: container.authGateway,
      sizeRepository: sizeRepository,
    ),
    deleteSize: DeleteSizeUseCase(
      authGateway: container.authGateway,
      sizeRepository: sizeRepository,
    ),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminSizesRouteAdapter(OxoRouterRouteNavigator(context)),
  );
}

class _AdminSizesRouteHost extends StatefulWidget {
  const _AdminSizesRouteHost({required this.builder});

  final AdminSizesViewModelBuilder builder;

  @override
  State<_AdminSizesRouteHost> createState() => _AdminSizesRouteHostState();
}

class _AdminSizesRouteHostState extends State<_AdminSizesRouteHost> {
  late final AdminSizesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = widget.builder(context, container);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSizesScreen(viewModel: _viewModel);
  }
}

// ---------------------------------------------------------------------------
// Phase 21 — /admin/templates/create route host
// ---------------------------------------------------------------------------

typedef AdminTemplateCreatorViewModelBuilder =
    AdminTemplateCreatorViewModel Function(
      BuildContext context,
      AppContainer container,
    );

AdminTemplateCreatorViewModel _defaultAdminTemplateCreatorViewModelBuilder(
  BuildContext context,
  AppContainer container,
) {
  final dataSource = container.directusDataSource;
  final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
  final sizeRepository = SizeRepositoryImpl(dataSource: dataSource);
  final areaRepository = AreaRepositoryImpl(dataSource: dataSource);
  return AdminTemplateCreatorViewModel(
    listSizes: ListSizesForCreatorUseCase(
      authGateway: container.authGateway,
      sizeRepository: sizeRepository,
    ),
    listAreas: ListAreasForCreatorUseCase(
      authGateway: container.authGateway,
      areaRepository: areaRepository,
    ),
    createTemplate: CreateTemplateUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepository,
    ),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminTemplateCreatorRouteAdapter(OxoRouterRouteNavigator(context)),
  );
}

class _AdminTemplateCreatorRouteHost extends StatefulWidget {
  const _AdminTemplateCreatorRouteHost({required this.builder});

  final AdminTemplateCreatorViewModelBuilder builder;

  @override
  State<_AdminTemplateCreatorRouteHost> createState() =>
      _AdminTemplateCreatorRouteHostState();
}

class _AdminTemplateCreatorRouteHostState
    extends State<_AdminTemplateCreatorRouteHost> {
  late final AdminTemplateCreatorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = widget.builder(context, container);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminTemplateCreatorScreen(viewModel: _viewModel);
  }
}

// ---------------------------------------------------------------------------
// Phase 22 — /menus/pdf/:id route host
// ---------------------------------------------------------------------------

typedef PdfPreviewViewModelBuilder =
    PdfPreviewViewModel Function(
      BuildContext context,
      AppContainer container,
      int menuId,
    );

PdfPreviewViewModel _defaultPdfPreviewViewModelBuilder(
  BuildContext context,
  AppContainer container,
  int menuId,
) {
  final dataSource = container.directusDataSource;
  final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
  final pageRepository = PageRepositoryImpl(dataSource: dataSource);
  final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
  final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
  final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
  final fileRepository = FileRepositoryImpl(dataSource);
  final assetLoader = AssetLoaderRepositoryImpl();
  final fetchMenuTreeUseCase = FetchMenuTreeUseCase(
    menuRepository: menuRepository,
    pageRepository: pageRepository,
    containerRepository: containerRepository,
    columnRepository: columnRepository,
    widgetRepository: widgetRepository,
  );
  final generatePdfUseCase = GeneratePdfUseCase(
    fileRepository: fileRepository,
    assetLoader: assetLoader,
    useIsolate: !kIsWeb,
  );
  final generateMenuPdfUseCase = GenerateMenuPdfUseCase(
    authGateway: container.authGateway,
    fetchMenuTree: fetchMenuTreeUseCase,
    generatePdf: generatePdfUseCase,
  );
  return PdfPreviewViewModel(
    menuId: menuId,
    generatePdf: generateMenuPdfUseCase,
    router: PdfPreviewRouteAdapter(OxoRouterRouteNavigator(context)),
  );
}

class _PdfPreviewRouteHost extends StatefulWidget {
  const _PdfPreviewRouteHost({required this.builder, required this.menuId});

  final PdfPreviewViewModelBuilder builder;
  final int menuId;

  @override
  State<_PdfPreviewRouteHost> createState() => _PdfPreviewRouteHostState();
}

class _PdfPreviewRouteHostState extends State<_PdfPreviewRouteHost> {
  late final PdfPreviewViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = widget.builder(context, container, widget.menuId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfPreviewScreen(viewModel: _viewModel);
  }
}

// ---------------------------------------------------------------------------
// Phase 23 — /admin/exportable_menus route host
// ---------------------------------------------------------------------------

typedef AdminExportableMenusViewModelBuilder =
    AdminExportableMenusViewModel Function(
      BuildContext context,
      AppContainer container,
    );

AdminExportableMenusViewModel _defaultAdminExportableMenusViewModelBuilder(
  BuildContext context,
  AppContainer container,
) {
  final dataSource = container.directusDataSource;
  final bundleRepository = MenuBundleRepositoryImpl(dataSource: dataSource);
  final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
  final pageRepository = PageRepositoryImpl(dataSource: dataSource);
  final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
  final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
  final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
  final fileRepository = FileRepositoryImpl(dataSource);
  final assetLoader = AssetLoaderRepositoryImpl();
  final fetchMenuTreeUseCase = FetchMenuTreeUseCase(
    menuRepository: menuRepository,
    pageRepository: pageRepository,
    containerRepository: containerRepository,
    columnRepository: columnRepository,
    widgetRepository: widgetRepository,
  );
  final publishUseCase = PublishMenuBundleUseCase(
    repository: bundleRepository,
    fetchMenuTreeUseCase: fetchMenuTreeUseCase,
    fileRepository: fileRepository,
    assetLoader: assetLoader,
    pdfBuilder: const PdfDocumentBuilder(),
  );
  return AdminExportableMenusViewModel(
    listBundles: ListMenuBundlesForAdminUseCase(
      authGateway: container.authGateway,
      bundleRepository: bundleRepository,
    ),
    listAvailableMenus: ListAvailableMenusForBundlesUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepository,
    ),
    createBundle: CreateMenuBundleForAdminUseCase(
      authGateway: container.authGateway,
      bundleRepository: bundleRepository,
    ),
    updateBundle: UpdateMenuBundleForAdminUseCase(
      authGateway: container.authGateway,
      bundleRepository: bundleRepository,
    ),
    deleteBundle: DeleteMenuBundleForAdminUseCase(
      authGateway: container.authGateway,
      bundleRepository: bundleRepository,
    ),
    publishBundle: PublishMenuBundleForAdminUseCase(
      authGateway: container.authGateway,
      publishMenuBundleUseCase: publishUseCase,
    ),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminExportableMenusRouteAdapter(OxoRouterRouteNavigator(context)),
  );
}

class _AdminExportableMenusRouteHost extends StatefulWidget {
  const _AdminExportableMenusRouteHost({required this.builder});

  final AdminExportableMenusViewModelBuilder builder;

  @override
  State<_AdminExportableMenusRouteHost> createState() =>
      _AdminExportableMenusRouteHostState();
}

class _AdminExportableMenusRouteHostState
    extends State<_AdminExportableMenusRouteHost> {
  late final AdminExportableMenusViewModel _viewModel;
  late final String _directusBaseUrl;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = widget.builder(context, container);
    _directusBaseUrl = container.directusBaseUrl ?? '';
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminExportableMenusScreen(
      viewModel: _viewModel,
      directusBaseUrl: _directusBaseUrl,
    );
  }
}

// ---------------------------------------------------------------------------
// Phase 24 — /menus/:id route host
// ---------------------------------------------------------------------------

typedef MenuEditorViewModelBuilder =
    MenuEditorViewModel Function(
      BuildContext context,
      AppContainer container,
      int menuId,
    );

MenuEditorViewModel _defaultMenuEditorViewModelBuilder(
  BuildContext context,
  AppContainer container,
  int menuId,
) {
  final dataSource = container.directusDataSource;
  final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
  final pageRepository = PageRepositoryImpl(dataSource: dataSource);
  final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
  final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
  final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
  final menuBundleRepository = MenuBundleRepositoryImpl(dataSource: dataSource);
  final fileRepository = FileRepositoryImpl(dataSource);
  final assetLoader = AssetLoaderRepositoryImpl();
  final fetchMenuTreeUseCase = FetchMenuTreeUseCase(
    menuRepository: menuRepository,
    pageRepository: pageRepository,
    containerRepository: containerRepository,
    columnRepository: columnRepository,
    widgetRepository: widgetRepository,
  );
  final publishMenuBundleUseCase = PublishMenuBundleUseCase(
    repository: menuBundleRepository,
    fetchMenuTreeUseCase: fetchMenuTreeUseCase,
    fileRepository: fileRepository,
    assetLoader: assetLoader,
    pdfBuilder: const PdfDocumentBuilder(),
  );
  final publishBundlesForMenuUseCase = PublishBundlesForMenuUseCase(
    repository: menuBundleRepository,
    publishMenuBundleUseCase: publishMenuBundleUseCase,
  );
  final subscriptionRepository = MenuSubscriptionRepositoryImpl(
    dataSource: dataSource,
  );
  final presenceRepository = PresenceRepositoryImpl(dataSource: dataSource);
  return MenuEditorViewModel(
    menuId: menuId,
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: MenuEditorRouteAdapter(OxoRouterRouteNavigator(context)),
    registry: container.widgetRegistry,
    imageGateway: container.imageGateway,
    loadMenu: LoadMenuForEditorUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepository,
      pageRepository: pageRepository,
      containerRepository: containerRepository,
      columnRepository: columnRepository,
      widgetRepository: widgetRepository,
    ),
    createWidget: CreateWidgetInMenuUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    updateWidget: UpdateWidgetInMenuUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    deleteWidget: DeleteWidgetInMenuUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    moveWidget: MoveWidgetInMenuUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    lockWidget: LockWidgetForEditingUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    unlockWidget: UnlockWidgetUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    saveMenu: SaveMenuUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepository,
    ),
    publishBundles: PublishExportableBundlesForMenuUseCase(
      authGateway: container.authGateway,
      delegate: publishBundlesForMenuUseCase,
    ),
    watchChanges: WatchMenuChangesUseCase(repository: subscriptionRepository),
    presence: MenuPresenceUseCase(repository: presenceRepository),
  );
}

class _MenuEditorRouteHost extends StatefulWidget {
  const _MenuEditorRouteHost({required this.builder, required this.menuId});

  final MenuEditorViewModelBuilder builder;
  final int menuId;

  @override
  State<_MenuEditorRouteHost> createState() => _MenuEditorRouteHostState();
}

class _MenuEditorRouteHostState extends State<_MenuEditorRouteHost> {
  late final MenuEditorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = widget.builder(context, container, widget.menuId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuEditorScreen(viewModel: _viewModel);
  }
}

// ---------------------------------------------------------------------------
// Phase 24 — /admin/templates/:id route host
// ---------------------------------------------------------------------------

typedef AdminTemplateEditorViewModelBuilder =
    AdminTemplateEditorViewModel Function(
      BuildContext context,
      AppContainer container,
      int menuId,
    );

AdminTemplateEditorViewModel _defaultAdminTemplateEditorViewModelBuilder(
  BuildContext context,
  AppContainer container,
  int menuId,
) {
  final dataSource = container.directusDataSource;
  final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
  final pageRepository = PageRepositoryImpl(dataSource: dataSource);
  final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
  final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
  final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
  final sizeRepository = SizeRepositoryImpl(dataSource: dataSource);
  final areaRepository = AreaRepositoryImpl(dataSource: dataSource);
  return AdminTemplateEditorViewModel(
    menuId: menuId,
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminTemplateEditorRouteAdapter(OxoRouterRouteNavigator(context)),
    registry: container.widgetRegistry,
    imageGateway: container.imageGateway,
    loadTemplate: LoadTemplateForEditorUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepository,
      pageRepository: pageRepository,
      containerRepository: containerRepository,
      columnRepository: columnRepository,
      widgetRepository: widgetRepository,
    ),
    createPage: CreatePageInTemplateUseCase(
      authGateway: container.authGateway,
      pageRepository: pageRepository,
    ),
    deletePage: DeletePageInTemplateUseCase(
      authGateway: container.authGateway,
      pageRepository: pageRepository,
    ),
    createContainer: CreateContainerInTemplateUseCase(
      authGateway: container.authGateway,
      containerRepository: containerRepository,
    ),
    updateContainer: UpdateContainerInTemplateUseCase(
      authGateway: container.authGateway,
      containerRepository: containerRepository,
    ),
    deleteContainer: DeleteContainerInTemplateUseCase(
      authGateway: container.authGateway,
      containerRepository: containerRepository,
    ),
    reorderContainer: ReorderContainerInTemplateUseCase(
      authGateway: container.authGateway,
      reorderContainerUseCase: ReorderContainerUseCase(
        containerRepository: containerRepository,
      ),
    ),
    duplicateContainer: DuplicateContainerInTemplateUseCase(
      authGateway: container.authGateway,
      duplicateContainerUseCase: DuplicateContainerUseCase(
        containerRepository: containerRepository,
        columnRepository: columnRepository,
        widgetRepository: widgetRepository,
      ),
    ),
    createColumn: CreateColumnInTemplateUseCase(
      authGateway: container.authGateway,
      columnRepository: columnRepository,
    ),
    updateColumn: UpdateColumnInTemplateUseCase(
      authGateway: container.authGateway,
      columnRepository: columnRepository,
    ),
    deleteColumn: DeleteColumnInTemplateUseCase(
      authGateway: container.authGateway,
      columnRepository: columnRepository,
    ),
    createWidget: CreateWidgetInTemplateUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    updateWidget: UpdateWidgetInTemplateUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    deleteWidget: DeleteWidgetInTemplateUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    moveWidget: MoveWidgetInTemplateUseCase(
      authGateway: container.authGateway,
      widgetRepository: widgetRepository,
    ),
    updateMenu: UpdateTemplateMenuUseCase(
      authGateway: container.authGateway,
      menuRepository: menuRepository,
    ),
    listAreas: ListAreasForTemplateUseCase(
      authGateway: container.authGateway,
      areaRepository: areaRepository,
    ),
    listSizes: ListSizesForTemplateUseCase(
      authGateway: container.authGateway,
      sizeRepository: sizeRepository,
    ),
  );
}

class _AdminTemplateEditorRouteHost extends StatefulWidget {
  const _AdminTemplateEditorRouteHost({
    required this.builder,
    required this.menuId,
  });

  final AdminTemplateEditorViewModelBuilder builder;
  final int menuId;

  @override
  State<_AdminTemplateEditorRouteHost> createState() =>
      _AdminTemplateEditorRouteHostState();
}

class _AdminTemplateEditorRouteHostState
    extends State<_AdminTemplateEditorRouteHost> {
  late final AdminTemplateEditorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final container = AppScope.read(context).container;
    _viewModel = widget.builder(context, container, widget.menuId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminTemplateEditorScreen(viewModel: _viewModel);
  }
}
