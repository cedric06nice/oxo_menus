import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/routing/route_config.dart';
import 'package:oxo_menus/core/routing/route_page.dart';

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
/// During Phase 0 the stack starts empty; concrete `RoutePage` subclasses are
/// added as each feature migrates.
class MainRouter extends RouterDelegate<RouteConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteConfig> {
  MainRouter({required AppContainer container})
    : _container = container,
      _navigatorKey = GlobalKey<NavigatorState>() {
    _authSubscription = _container.authGateway.statusStream.listen((_) {
      _onAuthChanged();
    });
  }

  final AppContainer _container;
  final GlobalKey<NavigatorState> _navigatorKey;
  final List<RoutePage> _stack = <RoutePage>[];
  StreamSubscription<AuthStatus>? _authSubscription;
  RouteConfig? _currentConfiguration;
  bool _disposed = false;

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
    if (configuration is UnknownRouteConfig) {
      // Phase 0: unknown URIs are passed through to the legacy router.
      return;
    }
    notifyListeners();
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
