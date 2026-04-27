import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/core/routing/route_config.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_route_page.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_router.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_route_page.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_route_page.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_route_page.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_route_page.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_route_page.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_route_page.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_route_page.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';

/// Application-wide router and DI root for the migrated stack.
///
/// Responsibilities:
/// - Owns the page stack and exposes mutation methods (`push`, `pop`,
///   `replace`).
/// - Implements every per-feature `FeatureRouter` interface (added as
///   features migrate) so ViewModels receive a single, fully-typed router.
/// - Listens to [AuthGateway] and rebuilds the stack when the user signs in
///   or out — applying the auth gate to filter protected pages.
/// - Disposes a page's resources (its ViewModel) when the page leaves the
///   stack for good.
///
/// During the migration, [LegacyNavigator] lets MainRouter route the user
/// back into the legacy `go_router` tree (e.g. the `/home` shell that has not
/// yet been migrated). Once every feature has migrated this dependency can be
/// removed.
class MainRouter extends RouterDelegate<RouteConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteConfig>
    implements
        LoginRouter,
        ForgotPasswordRouter,
        HomeRouter,
        MenuListRouter,
        SettingsRouter,
        AdminTemplatesRouter,
        AdminTemplateCreatorRouter,
        AdminSizesRouter {
  MainRouter({
    required AppContainer container,
    LegacyNavigator? legacyNavigator,
  }) : _container = container,
       _legacyNavigator = legacyNavigator,
       _navigatorKey = GlobalKey<NavigatorState>() {
    _authSubscription = _container.authGateway.statusStream.listen((_) {
      _onAuthChanged();
    });
  }

  final AppContainer _container;
  LegacyNavigator? _legacyNavigator;
  final GlobalKey<NavigatorState> _navigatorKey;
  final List<RoutePage> _stack = <RoutePage>[];
  StreamSubscription<AuthStatus>? _authSubscription;
  RouteConfig? _currentConfiguration;
  bool _disposed = false;

  /// Update the legacy navigator after construction. `MainRouterHost` calls
  /// this from its `build` method so the navigator always points at the
  /// current `BuildContext`.
  set legacyNavigator(LegacyNavigator? navigator) {
    _legacyNavigator = navigator;
  }

  AppContainer get container => _container;

  List<RoutePage> get stack => List.unmodifiable(_stack);

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  @override
  RouteConfig? get currentConfiguration => _currentConfiguration;

  /// Push a page onto the top of the stack.
  void push(RoutePage page) {
    if (_disposed) {
      return;
    }
    _stack.add(page);
    notifyListeners();
  }

  /// Pop the top page. Returns `true` if a page was removed.
  bool pop() {
    if (_disposed || _stack.isEmpty) {
      return false;
    }
    final removed = _stack.removeLast();
    removed.disposeResources();
    notifyListeners();
    return true;
  }

  /// Replace the entire stack atomically. Pages no longer present have
  /// `disposeResources` called.
  void replace(List<RoutePage> next) {
    if (_disposed) {
      return;
    }
    final keptIdentities = next.map((p) => p.identity).toSet();
    for (final page in _stack) {
      if (!keptIdentities.contains(page.identity)) {
        page.disposeResources();
      }
    }
    _stack
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void _onAuthChanged() {
    if (_disposed) {
      return;
    }
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RouteConfig configuration) async {
    _currentConfiguration = configuration;
    switch (configuration) {
      case LoginRouteConfig():
        _replaceWithSingle(LoginRoutePage(router: this), identity: 'login');
      case ForgotPasswordRouteConfig():
        _replaceWithSingle(
          ForgotPasswordRoutePage(router: this),
          identity: 'forgot-password',
        );
      case HomeRouteConfig():
        _replaceWithSingle(HomeRoutePage(router: this), identity: 'home');
      case MenuListRouteConfig():
        _replaceWithSingle(
          MenuListRoutePage(router: this),
          identity: 'menu-list',
        );
      case SettingsRouteConfig():
        _replaceWithSingle(
          SettingsRoutePage(router: this),
          identity: 'settings',
        );
      case AdminTemplatesRouteConfig():
        _replaceWithSingle(
          AdminTemplatesRoutePage(router: this),
          identity: 'admin-templates',
        );
      case AdminSizesRouteConfig():
        _replaceWithSingle(
          AdminSizesRoutePage(router: this),
          identity: 'admin-sizes',
        );
      case AdminTemplateCreatorRouteConfig():
        _replaceWithSingle(
          AdminTemplateCreatorRoutePage(router: this),
          identity: 'admin-template-create',
        );
      case UnknownRouteConfig():
        // Migration fallback: legacy go_router still serves this URI.
        return;
    }
  }

  /// Replace the stack with a single page unless the top page already has the
  /// same identity. Lets `setNewRoutePath` be called repeatedly without
  /// rebuilding the screen each time.
  void _replaceWithSingle(RoutePage page, {required Object identity}) {
    if (_stack.length == 1 && _stack.single.identity == identity) {
      return;
    }
    replace(<RoutePage>[page]);
  }

  // ---------------------------------------------------------------- LoginRouter

  @override
  void goToHomeAfterLogin() {
    if (_disposed) {
      return;
    }
    _replaceWithSingle(HomeRoutePage(router: this), identity: 'home');
  }

  @override
  void goToForgotPassword() {
    if (_disposed) {
      return;
    }
    if (_stack.isNotEmpty && _stack.last.identity == 'forgot-password') {
      return;
    }
    push(ForgotPasswordRoutePage(router: this));
  }

  // -------------------------------------------------------- ForgotPasswordRouter

  @override
  void goBackToLogin() {
    if (_disposed) {
      return;
    }
    final loginIndex = _stack.lastIndexWhere((p) => p.identity == 'login');
    if (loginIndex < 0) {
      _replaceWithSingle(LoginRoutePage(router: this), identity: 'login');
      return;
    }
    var changed = false;
    while (_stack.length - 1 > loginIndex) {
      final removed = _stack.removeLast();
      removed.disposeResources();
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------- HomeRouter

  @override
  void goToMenus() {
    if (_disposed) {
      return;
    }
    if (_stack.isNotEmpty && _stack.last.identity == 'menu-list') {
      return;
    }
    push(MenuListRoutePage(router: this));
  }

  @override
  void goToSettings() {
    if (_disposed) {
      return;
    }
    if (_stack.isNotEmpty && _stack.last.identity == 'settings') {
      return;
    }
    push(SettingsRoutePage(router: this));
  }

  @override
  void goToAdminTemplates() {
    if (_disposed) {
      return;
    }
    if (_stack.isNotEmpty && _stack.last.identity == 'admin-templates') {
      return;
    }
    push(AdminTemplatesRoutePage(router: this));
  }

  @override
  void goToAdminTemplateCreate() {
    if (_disposed) {
      return;
    }
    if (_stack.isNotEmpty && _stack.last.identity == 'admin-template-create') {
      return;
    }
    push(AdminTemplateCreatorRoutePage(router: this));
  }

  @override
  void goToAdminExportableMenus() =>
      _legacyNavigator?.go(AppRoutes.adminExportableMenus);

  // ------------------------------------------------------------- MenuListRouter

  @override
  void goToMenuEditor(int menuId) =>
      _legacyNavigator?.go(AppRoutes.menuEditor(menuId));

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _legacyNavigator?.go(AppRoutes.adminTemplateEditor(menuId));

  // -------------------------- shared (MenuListRouter, SettingsRouter, AdminTemplatesRouter, AdminSizesRouter)

  @override
  void goBack() {
    pop();
  }

  // ----------------------------------------------------------- AdminSizes navigation

  /// Push the admin sizes screen onto the stack. Callable from any migrated
  /// feature that needs the sizes-management entry point (settings,
  /// template-create, template-editor once they migrate).
  @override
  void goToAdminSizes() {
    if (_disposed) {
      return;
    }
    if (_stack.isNotEmpty && _stack.last.identity == 'admin-sizes') {
      return;
    }
    push(AdminSizesRoutePage(router: this));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      pages: <Page<dynamic>>[
        for (final page in _stack)
          MaterialPage<void>(
            key: ValueKey(page.identity),
            child: page.buildScreen(_container),
          ),
      ],
      onDidRemovePage: (page) {
        // The framework will call us when a page is popped via the system
        // back button. Mirror the change in our stack.
        final identity = (page.key as ValueKey?)?.value;
        final index = _stack.indexWhere((p) => p.identity == identity);
        if (index < 0) {
          return;
        }
        final removed = _stack.removeAt(index);
        removed.disposeResources();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    unawaited(_authSubscription?.cancel());
    for (final page in _stack) {
      page.disposeResources();
    }
    _stack.clear();
    super.dispose();
  }
}
