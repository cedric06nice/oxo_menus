import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Bridge interface that lets each feature's `*RouteAdapter` navigate the
/// `go_router` tree without exposing `BuildContext` or any Flutter primitives
/// to ViewModels.
///
/// The route hosts in `app_router.dart` provide a context-backed
/// [GoRouterRouteNavigator]; tests inject a recording fake.
abstract class RouteNavigator {
  /// Navigate to [location] on the `go_router`, replacing the current route.
  /// Equivalent to `context.go(location, extra: extra)`.
  void go(String location, {Object? extra});

  /// Push [location] on top of the current navigation stack so the previous
  /// route remains beneath it. Equivalent to `context.push(location, extra: extra)`.
  void push(String location, {Object? extra});
}

/// Default [RouteNavigator] that forwards to `context.go(...)` and
/// `context.push(...)` on the `go_router` tree. Used by every `_*RouteHost`
/// to bridge `BuildContext` into the feature's `*RouteAdapter`.
class GoRouterRouteNavigator implements RouteNavigator {
  const GoRouterRouteNavigator(this._context);

  final BuildContext _context;

  @override
  void go(String location, {Object? extra}) {
    _context.go(location, extra: extra);
  }

  @override
  void push(String location, {Object? extra}) {
    _context.push(location, extra: extra);
  }
}
