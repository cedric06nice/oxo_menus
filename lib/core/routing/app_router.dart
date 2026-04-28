import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
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
      // Auth screens are served by the MVVM stack at the canonical paths.
      // Each host owns the ViewModel and disposes it when the route leaves
      // the stack.
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          final container = ref.watch(appContainerProvider);
          return _LoginRouteHost(container: container);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) {
          final container = ref.watch(appContainerProvider);
          return _ForgotPasswordRouteHost(container: container);
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final container = ref.watch(appContainerProvider);
          return _ResetPasswordRouteHost(
            container: container,
            token: state.uri.queryParameters['token'],
          );
        },
      ),
      // All authenticated routes wrapped in AppShell for persistent navigation
      ShellRoute(
        builder: (context, state, child) => Consumer(
          builder: (context, ref, _) {
            final connectivity = ref.watch(connectivityProvider).value;
            return AppShell(
              navigator: GoRouterRouteNavigator(context),
              currentLocation: state.matchedLocation,
              isAdmin: ref.watch(isAdminProvider),
              isOffline: connectivity == ConnectivityStatus.offline,
              child: child,
            );
          },
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              return _HomeRouteHost(container: container);
            },
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              return _SettingsRouteHost(container: container);
            },
          ),
          GoRoute(
            path: AppRoutes.menus,
            name: 'menus',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              final builder = ref.read(menuListViewModelBuilderProvider);
              return _MenuListRouteHost(container: container, builder: builder);
            },
            routes: [
              GoRoute(
                path: 'pdf/:id',
                name: 'menu-pdf',
                builder: (context, state) {
                  final int menuId = int.parse(state.pathParameters['id']!);
                  final container = ref.watch(appContainerProvider);
                  final builder = ref.read(pdfPreviewViewModelBuilderProvider);
                  return _PdfPreviewRouteHost(
                    container: container,
                    builder: builder,
                    menuId: menuId,
                  );
                },
              ),
              // /menus/:id hosts the MVVM MenuEditorScreen directly via
              // _MenuEditorRouteHost.
              GoRoute(
                path: ':id',
                name: 'menu-editor',
                builder: (context, state) {
                  final int menuId = int.parse(state.pathParameters['id']!);
                  final container = ref.watch(appContainerProvider);
                  final builder = ref.read(menuEditorViewModelBuilderProvider);
                  return _MenuEditorRouteHost(
                    container: container,
                    builder: builder,
                    menuId: menuId,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.adminSizes,
            name: 'admin-sizes',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              final builder = ref.read(adminSizesViewModelBuilderProvider);
              return _AdminSizesRouteHost(
                container: container,
                builder: builder,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.adminExportableMenus,
            name: 'admin-exportable-menus',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              final builder = ref.read(
                adminExportableMenusViewModelBuilderProvider,
              );
              return _AdminExportableMenusRouteHost(
                container: container,
                builder: builder,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.adminTemplates,
            name: 'admin-templates',
            builder: (context, state) {
              final container = ref.watch(appContainerProvider);
              final builder = ref.read(adminTemplatesViewModelBuilderProvider);
              return _AdminTemplatesRouteHost(
                container: container,
                builder: builder,
              );
            },
            routes: [
              GoRoute(
                path: 'create',
                name: 'admin-template-create',
                builder: (context, state) {
                  final container = ref.watch(appContainerProvider);
                  final builder = ref.read(
                    adminTemplateCreatorViewModelBuilderProvider,
                  );
                  return _AdminTemplateCreatorRouteHost(
                    container: container,
                    builder: builder,
                  );
                },
              ),
              // /admin/templates/:id hosts the MVVM
              // AdminTemplateEditorScreen directly via
              // _AdminTemplateEditorRouteHost.
              GoRoute(
                path: ':id',
                name: 'admin-template-editor',
                builder: (context, state) {
                  final int menuId = int.parse(state.pathParameters['id']!);
                  final container = ref.watch(appContainerProvider);
                  final builder = ref.read(
                    adminTemplateEditorViewModelBuilderProvider,
                  );
                  return _AdminTemplateEditorRouteHost(
                    container: container,
                    builder: builder,
                    menuId: menuId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Phase 15 — auth route hosts
//
// Each host is a small StatefulWidget that owns the ViewModel for its screen
// for the lifetime of the GoRoute. The MVVM auth screens are pure
// (no Riverpod, no BuildContext use), so the host is the single place that
// bridges go_router's `BuildContext` into the screen via `AuthRouteAdapter`.
// ---------------------------------------------------------------------------

class _LoginRouteHost extends StatefulWidget {
  const _LoginRouteHost({required this.container});

  final AppContainer container;

  @override
  State<_LoginRouteHost> createState() => _LoginRouteHostState();
}

class _LoginRouteHostState extends State<_LoginRouteHost> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(
      login: LoginUseCase(gateway: widget.container.authGateway),
      router: AuthRouteAdapter(GoRouterRouteNavigator(context)),
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

class _ForgotPasswordRouteHost extends StatefulWidget {
  const _ForgotPasswordRouteHost({required this.container});

  final AppContainer container;

  @override
  State<_ForgotPasswordRouteHost> createState() =>
      _ForgotPasswordRouteHostState();
}

class _ForgotPasswordRouteHostState extends State<_ForgotPasswordRouteHost> {
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel(
      requestPasswordReset: RequestPasswordResetUseCase(
        gateway: widget.container.authGateway,
      ),
      router: AuthRouteAdapter(GoRouterRouteNavigator(context)),
      connectivityGateway: widget.container.connectivityGateway,
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
  const _ResetPasswordRouteHost({required this.container, required this.token});

  final AppContainer container;
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
    _viewModel = ResetPasswordViewModel(
      confirmPasswordReset: ConfirmPasswordResetUseCase(
        gateway: widget.container.authGateway,
      ),
      router: AuthRouteAdapter(GoRouterRouteNavigator(context)),
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
//
// Owns the HomeViewModel for the lifetime of the GoRoute under the
// AppShell. The MVVM HomeScreen is pure (no Riverpod, no BuildContext use) so
// this host bridges go_router into it via HomeRouteAdapter.
// ---------------------------------------------------------------------------

class _HomeRouteHost extends StatefulWidget {
  const _HomeRouteHost({required this.container});

  final AppContainer container;

  @override
  State<_HomeRouteHost> createState() => _HomeRouteHostState();
}

class _HomeRouteHostState extends State<_HomeRouteHost> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      getHomeOverview: GetHomeOverviewUseCase(
        gateway: widget.container.authGateway,
      ),
      router: HomeRouteAdapter(GoRouterRouteNavigator(context)),
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
//
// Owns the SettingsViewModel for the lifetime of the GoRoute under the
// AppShell. The MVVM SettingsScreen is pure (no Riverpod, no BuildContext use)
// so this host bridges go_router into it via SettingsRouteAdapter.
// ---------------------------------------------------------------------------

class _SettingsRouteHost extends StatefulWidget {
  const _SettingsRouteHost({required this.container});

  final AppContainer container;

  @override
  State<_SettingsRouteHost> createState() => _SettingsRouteHostState();
}

class _SettingsRouteHostState extends State<_SettingsRouteHost> {
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
      router: SettingsRouteAdapter(GoRouterRouteNavigator(context)),
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
//
// Owns the MenuListViewModel for the lifetime of the GoRoute under the
// AppShell. The MVVM MenuListScreen is pure (no Riverpod, no BuildContext
// reads) so this host bridges go_router into it via MenuListRouteAdapter,
// which deep-links into `/menus/:id` and `/admin/templates/:id`.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultMenuListViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the `/menus` route host to construct the
/// [MenuListViewModel] from the live [AppContainer]. The [BuildContext] is the
/// route's context and is used by the default builder to bridge into
/// `go_router` via [GoRouterRouteNavigator].
typedef MenuListViewModelBuilder =
    MenuListViewModel Function(BuildContext context, AppContainer container);

/// Riverpod entry point for the `/menus` view-model builder.
///
/// Defaults to [_defaultMenuListViewModelBuilder] which wires the live
/// menu repositories from the container's `DirectusDataSource`. Tests override
/// this with a stub builder that returns a [MenuListViewModel] backed by fake
/// use cases.
final menuListViewModelBuilderProvider = Provider<MenuListViewModelBuilder>(
  (ref) => _defaultMenuListViewModelBuilder,
);

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
    router: MenuListRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

class _MenuListRouteHost extends StatefulWidget {
  const _MenuListRouteHost({required this.container, required this.builder});

  final AppContainer container;
  final MenuListViewModelBuilder builder;

  @override
  State<_MenuListRouteHost> createState() => _MenuListRouteHostState();
}

class _MenuListRouteHostState extends State<_MenuListRouteHost> {
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
// Phase 19 — /admin/templates route host
//
// Owns the AdminTemplatesViewModel for the lifetime of the GoRoute
// under the AppShell. The MVVM AdminTemplatesScreen is pure (no Riverpod, no
// BuildContext reads) so this host bridges go_router into it via
// AdminTemplatesRouteAdapter, which deep-links into
// `/admin/templates/:id` for the editor.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultAdminTemplatesViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the `/admin/templates` route host to construct the
/// [AdminTemplatesViewModel] from the live [AppContainer]. The [BuildContext]
/// is the route's context and is used by the default builder to bridge into
/// `go_router` via [GoRouterRouteNavigator].
typedef AdminTemplatesViewModelBuilder =
    AdminTemplatesViewModel Function(
      BuildContext context,
      AppContainer container,
    );

/// Riverpod entry point for the `/admin/templates` view-model builder.
///
/// Defaults to [_defaultAdminTemplatesViewModelBuilder] which wires the
/// live menu repository from the container's `DirectusDataSource`. Tests
/// override this with a stub builder that returns an
/// [AdminTemplatesViewModel] backed by fake use cases.
final adminTemplatesViewModelBuilderProvider =
    Provider<AdminTemplatesViewModelBuilder>(
      (ref) => _defaultAdminTemplatesViewModelBuilder,
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
    router: AdminTemplatesRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

class _AdminTemplatesRouteHost extends StatefulWidget {
  const _AdminTemplatesRouteHost({
    required this.container,
    required this.builder,
  });

  final AppContainer container;
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

// ---------------------------------------------------------------------------
// Phase 20 — /admin/sizes route host
//
// Owns the AdminSizesViewModel for the lifetime of the GoRoute under
// the AppShell. The MVVM AdminSizesScreen is pure (no Riverpod, no
// BuildContext reads) so this host bridges go_router into it via
// AdminSizesRouteAdapter. The screen is a navigation leaf — the router only
// exposes "back" — so no deep-link forwarding is needed.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultAdminSizesViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the `/admin/sizes` route host to construct the
/// [AdminSizesViewModel] from the live [AppContainer]. The [BuildContext] is
/// the route's context and is used by the default builder to bridge into
/// `go_router` via [GoRouterRouteNavigator].
typedef AdminSizesViewModelBuilder =
    AdminSizesViewModel Function(BuildContext context, AppContainer container);

/// Riverpod entry point for the `/admin/sizes` view-model builder.
///
/// Defaults to [_defaultAdminSizesViewModelBuilder] which wires the live
/// size repository from the container's `DirectusDataSource`. Tests override
/// this with a stub builder that returns an [AdminSizesViewModel] backed by
/// fake use cases.
final adminSizesViewModelBuilderProvider = Provider<AdminSizesViewModelBuilder>(
  (ref) => _defaultAdminSizesViewModelBuilder,
);

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
    router: AdminSizesRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

class _AdminSizesRouteHost extends StatefulWidget {
  const _AdminSizesRouteHost({required this.container, required this.builder});

  final AppContainer container;
  final AdminSizesViewModelBuilder builder;

  @override
  State<_AdminSizesRouteHost> createState() => _AdminSizesRouteHostState();
}

class _AdminSizesRouteHostState extends State<_AdminSizesRouteHost> {
  late final AdminSizesViewModel _viewModel;

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
    return AdminSizesScreen(viewModel: _viewModel);
  }
}

// ---------------------------------------------------------------------------
// Phase 21 — /admin/templates/create route host
//
// Owns the AdminTemplateCreatorViewModel for the lifetime of the GoRoute
// under the AppShell. The MVVM AdminTemplateCreatorScreen is pure (no
// Riverpod, no BuildContext reads) so this host bridges go_router into it via
// AdminTemplateCreatorRouteAdapter, which deep-links into
// `/admin/templates/:id` for the editor. The "Manage Page Sizes" CTA resolves
// to the `/admin/sizes` GoRoute.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultAdminTemplateCreatorViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the `/admin/templates/create` route host to construct
/// the [AdminTemplateCreatorViewModel] from the live [AppContainer]. The
/// [BuildContext] is the route's context and is used by the default builder to
/// bridge into `go_router` via [GoRouterRouteNavigator].
typedef AdminTemplateCreatorViewModelBuilder =
    AdminTemplateCreatorViewModel Function(
      BuildContext context,
      AppContainer container,
    );

/// Riverpod entry point for the `/admin/templates/create` view-model
/// builder.
///
/// Defaults to [_defaultAdminTemplateCreatorViewModelBuilder] which
/// wires the live menu / size / area repositories from the container's
/// `DirectusDataSource`. Tests override this with a stub builder that returns
/// an [AdminTemplateCreatorViewModel] backed by fake use cases.
final adminTemplateCreatorViewModelBuilderProvider =
    Provider<AdminTemplateCreatorViewModelBuilder>(
      (ref) => _defaultAdminTemplateCreatorViewModelBuilder,
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
    router: AdminTemplateCreatorRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

class _AdminTemplateCreatorRouteHost extends StatefulWidget {
  const _AdminTemplateCreatorRouteHost({
    required this.container,
    required this.builder,
  });

  final AppContainer container;
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
    _viewModel = widget.builder(context, widget.container);
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
//
// Owns the PdfPreviewViewModel for the lifetime of the GoRoute under
// the AppShell. The MVVM PdfPreviewScreen is pure (no Riverpod, no
// BuildContext reads) so this host bridges go_router into it via
// PdfPreviewRouteAdapter. The screen is a navigation leaf — the router only
// exposes "back" — so no deep-link forwarding is needed.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultPdfPreviewViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the `/menus/pdf/:id` route host to construct the
/// [PdfPreviewViewModel] from the live [AppContainer]. The [BuildContext] is
/// the route's context and is used by the default builder to bridge into
/// `go_router` via [GoRouterRouteNavigator]. The `menuId` is the path
/// parameter the user navigated to.
typedef PdfPreviewViewModelBuilder =
    PdfPreviewViewModel Function(
      BuildContext context,
      AppContainer container,
      int menuId,
    );

/// Riverpod entry point for the `/menus/pdf/:id` view-model builder.
///
/// Defaults to [_defaultPdfPreviewViewModelBuilder] which wires the live
/// menu / file repositories from the container's `DirectusDataSource`. Tests
/// override this with a stub builder that returns a [PdfPreviewViewModel]
/// backed by fake use cases.
final pdfPreviewViewModelBuilderProvider = Provider<PdfPreviewViewModelBuilder>(
  (ref) => _defaultPdfPreviewViewModelBuilder,
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
    router: PdfPreviewRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

class _PdfPreviewRouteHost extends StatefulWidget {
  const _PdfPreviewRouteHost({
    required this.container,
    required this.builder,
    required this.menuId,
  });

  final AppContainer container;
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
    _viewModel = widget.builder(context, widget.container, widget.menuId);
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
//
// Owns the AdminExportableMenusViewModel for the lifetime of the GoRoute
// under the AppShell. The MVVM AdminExportableMenusScreen is pure (no
// Riverpod, no BuildContext reads) so this host bridges go_router into it via
// AdminExportableMenusRouteAdapter. The screen is a navigation leaf — the
// router only exposes "back" — so no deep-link forwarding is needed.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultAdminExportableMenusViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the `/admin/exportable_menus` route host to
/// construct the [AdminExportableMenusViewModel] from the live [AppContainer].
/// The [BuildContext] is the route's context and is used by the default
/// builder to bridge into `go_router` via [GoRouterRouteNavigator].
typedef AdminExportableMenusViewModelBuilder =
    AdminExportableMenusViewModel Function(
      BuildContext context,
      AppContainer container,
    );

/// Riverpod entry point for the `/admin/exportable_menus` view-model
/// builder.
///
/// Defaults to [_defaultAdminExportableMenusViewModelBuilder] which
/// wires the live menu / bundle / file repositories from the container's
/// `DirectusDataSource`. Tests override this with a stub builder that returns
/// an [AdminExportableMenusViewModel] backed by fake use cases.
final adminExportableMenusViewModelBuilderProvider =
    Provider<AdminExportableMenusViewModelBuilder>(
      (ref) => _defaultAdminExportableMenusViewModelBuilder,
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
    router: AdminExportableMenusRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

class _AdminExportableMenusRouteHost extends StatefulWidget {
  const _AdminExportableMenusRouteHost({
    required this.container,
    required this.builder,
  });

  final AppContainer container;
  final AdminExportableMenusViewModelBuilder builder;

  @override
  State<_AdminExportableMenusRouteHost> createState() =>
      _AdminExportableMenusRouteHostState();
}

class _AdminExportableMenusRouteHostState
    extends State<_AdminExportableMenusRouteHost> {
  late final AdminExportableMenusViewModel _viewModel;

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
    return AdminExportableMenusScreen(
      viewModel: _viewModel,
      directusBaseUrl: widget.container.directusBaseUrl ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// Phase 24 — /menus/:id route host
//
// Owns the MenuEditorViewModel for the lifetime of the GoRoute under
// the AppShell. The MVVM MenuEditorScreen is pure (no Riverpod, no
// BuildContext reads) so this host bridges go_router into it via
// MenuEditorRouteAdapter, which deep-links `goToPdfPreview` into the
// `/menus/pdf/:id` GoRoute.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultMenuEditorViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the `/menus/:id` route host to construct the
/// [MenuEditorViewModel] from the live [AppContainer]. The [BuildContext] is
/// the route's context and is used by the default builder to bridge into
/// `go_router` via [GoRouterRouteNavigator]. The `menuId` is the path
/// parameter the user navigated to.
typedef MenuEditorViewModelBuilder =
    MenuEditorViewModel Function(
      BuildContext context,
      AppContainer container,
      int menuId,
    );

/// Riverpod entry point for the `/menus/:id` view-model builder.
///
/// Defaults to [_defaultMenuEditorViewModelBuilder] which wires the
/// live menu / page / container / column / widget / bundle repositories and
/// the collaboration / presence repositories from the container's
/// `DirectusDataSource`. Tests override this with a stub builder that returns
/// a [MenuEditorViewModel] backed by fake use cases.
final menuEditorViewModelBuilderProvider = Provider<MenuEditorViewModelBuilder>(
  (ref) => _defaultMenuEditorViewModelBuilder,
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
    router: MenuEditorRouteAdapter(GoRouterRouteNavigator(context)),
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
  const _MenuEditorRouteHost({
    required this.container,
    required this.builder,
    required this.menuId,
  });

  final AppContainer container;
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
    _viewModel = widget.builder(context, widget.container, widget.menuId);
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
//
// Owns the AdminTemplateEditorViewModel for the lifetime of the GoRoute
// under the AppShell. The MVVM AdminTemplateEditorScreen is pure (no
// Riverpod, no BuildContext reads) so this host bridges go_router into it
// via AdminTemplateEditorRouteAdapter, which deep-links `goToPdfPreview` and
// `goToAdminSizes` into the `/menus/pdf/:id` and `/admin/sizes` GoRoutes.
//
// The view-model construction is exposed as a Riverpod-overridable builder so
// router tests can swap in fake use cases without standing up a real
// DirectusDataSource. Production wiring is the default and lives in
// [_defaultAdminTemplateEditorViewModelBuilder].
// ---------------------------------------------------------------------------

/// Factory used by the `/admin/templates/:id` route host to construct
/// the [AdminTemplateEditorViewModel] from the live [AppContainer]. The
/// [BuildContext] is the route's context and is used by the default builder
/// to bridge into `go_router` via [GoRouterRouteNavigator]. The `menuId` is
/// the path parameter the user navigated to.
typedef AdminTemplateEditorViewModelBuilder =
    AdminTemplateEditorViewModel Function(
      BuildContext context,
      AppContainer container,
      int menuId,
    );

/// Riverpod entry point for the `/admin/templates/:id` view-model
/// builder.
///
/// Defaults to [_defaultAdminTemplateEditorViewModelBuilder] which
/// wires the live menu / page / container / column / widget / size / area
/// repositories from the container's `DirectusDataSource`. Tests override
/// this with a stub builder that returns an [AdminTemplateEditorViewModel]
/// backed by fake use cases.
final adminTemplateEditorViewModelBuilderProvider =
    Provider<AdminTemplateEditorViewModelBuilder>(
      (ref) => _defaultAdminTemplateEditorViewModelBuilder,
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
    router: AdminTemplateEditorRouteAdapter(GoRouterRouteNavigator(context)),
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
    required this.container,
    required this.builder,
    required this.menuId,
  });

  final AppContainer container;
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
    _viewModel = widget.builder(context, widget.container, widget.menuId);
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
