import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_page.dart';
import 'package:oxo_menus/presentation/pages/admin_template_creator/admin_template_creator_page.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/admin_template_editor_page.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_page.dart';
import 'package:oxo_menus/presentation/pages/home/home_page.dart';
import 'package:oxo_menus/presentation/pages/login/login_page.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/pdf_preview_dialog.dart';
import 'package:oxo_menus/presentation/pages/menu_list/menu_list_page.dart';
import 'package:oxo_menus/presentation/pages/settings/settings_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';

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
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// App router configuration using go_router
///
/// Provides navigation with authentication guards and route management
final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authListenableProvider);

  return GoRouter(
    initialLocation: '/splash',
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

      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToAdminRoute = state.matchedLocation.startsWith('/admin');

      // If loading, stay on or go to splash
      if (isLoading) {
        return isGoingToSplash ? null : '/splash';
      }

      // If on splash and not loading, redirect based on auth status
      if (isGoingToSplash) {
        return isAuthenticated ? '/home' : '/login';
      }

      // If not authenticated and not going to login, redirect to login
      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      // If authenticated and going to login, redirect to home
      if (isAuthenticated && isGoingToLogin) {
        return '/home';
      }

      // If not admin and going to admin route, redirect to home
      if (isGoingToAdminRoute && !isAdmin) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/menus',
        name: 'menus',
        builder: (context, state) => const MenuListPage(),
        routes: [
          GoRoute(
            path: 'pdf/:id',
            name: 'menu-pdf',
            builder: (context, state) {
              final int menuId = int.parse(state.pathParameters['id']!);
              return PdfPreviewDialog(menuId: menuId);
            },
          ),
          GoRoute(
            path: ':id',
            name: 'menu-editor',
            builder: (context, state) {
              final int menuId = int.parse(state.pathParameters['id']!);
              return MenuEditorPage(menuId: menuId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin/sizes',
        name: 'admin-sizes',
        builder: (context, state) => const AdminSizesPage(),
      ),
      GoRoute(
        path: '/admin/templates',
        name: 'admin-templates',
        builder: (context, state) => const AdminTemplatesPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'admin-template-create',
            builder: (context, state) => const AdminTemplateCreatorPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'admin-template-editor',
            builder: (context, state) {
              final int menuId = int.parse(state.pathParameters['id']!);
              return AdminTemplateEditorPage(menuId: menuId);
            },
          ),
        ],
      ),
    ],
  );
});
