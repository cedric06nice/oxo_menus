import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/admin_template_editor_page.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_page.dart';
import 'package:oxo_menus/presentation/pages/home/home_page.dart';
import 'package:oxo_menus/presentation/pages/login/login_page.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/menu_editor_page.dart';
import 'package:oxo_menus/presentation/pages/menu_list/menu_list_page.dart';
import 'package:oxo_menus/presentation/pages/settings/settings_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';

/// App router configuration using go_router
///
/// Provides navigation with authentication guards and route management
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final isAdmin = authState.maybeWhen(
        authenticated: (user) => user.role == UserRole.admin,
        orElse: () => false,
      );

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToAdminRoute = state.matchedLocation.startsWith('/admin');

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
            path: ':id',
            name: 'menu-editor',
            builder: (context, state) {
              final menuId = state.pathParameters['id']!;
              return MenuEditorPage(menuId: menuId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin/templates',
        name: 'admin-templates',
        builder: (context, state) => const AdminTemplatesPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'admin-template-editor',
            builder: (context, state) {
              final menuId = state.pathParameters['id']!;
              return AdminTemplateEditorPage(menuId: menuId);
            },
          ),
        ],
      ),
    ],
  );
});
