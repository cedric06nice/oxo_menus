import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/main_router_host.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/admin_exportable_menus_page.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/admin_sizes_page.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/pages/admin_template_creator_page.dart';
import 'package:oxo_menus/features/admin_templates/presentation/admin_templates_page.dart';
import 'package:oxo_menus/features/home/presentation/pages/home_page.dart';
import 'package:oxo_menus/features/auth/presentation/pages/login_page.dart';
import 'package:oxo_menus/features/menu_editor/presentation/pages/pdf_preview_page.dart';
import 'package:oxo_menus/features/menu_list/presentation/pages/menu_list_page.dart';
import 'package:oxo_menus/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:oxo_menus/features/auth/presentation/pages/reset_password_page.dart';
import 'package:oxo_menus/features/settings/presentation/pages/settings_page.dart';
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
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        builder: (context, state) =>
            ResetPasswordPage(token: state.uri.queryParameters['token']),
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
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: AppRoutes.menus,
            name: 'menus',
            builder: (context, state) => const MenuListPage(),
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
            builder: (context, state) => const AdminTemplatesPage(),
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
