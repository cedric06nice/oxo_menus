import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/routing/oxo_router.dart';

/// Bridge interface that lets each feature's `*RouteAdapter` navigate the
/// router tree without exposing `BuildContext` or any Flutter primitives to
/// ViewModels.
///
/// The route hosts in `app_router.dart` provide a context-backed
/// [OxoRouterRouteNavigator]; tests inject a recording fake.
abstract class RouteNavigator {
  /// Navigate to [location], replacing the current navigation stack.
  /// Equivalent to `OxoRouter.go(location, extra: extra)`.
  void go(String location, {Object? extra});

  /// Push [location] on top of the current navigation stack so the previous
  /// route remains beneath it. Equivalent to `OxoRouter.push(location,
  /// extra: extra)`.
  void push(String location, {Object? extra});
}

/// Default [RouteNavigator] that resolves the surrounding [OxoRouter] via
/// [OxoRouterScope] and forwards `go`/`push` to it. Used by every
/// `_*RouteHost` to bridge `BuildContext` into the feature's `*RouteAdapter`.
class OxoRouterRouteNavigator implements RouteNavigator {
  const OxoRouterRouteNavigator(this._context);

  final BuildContext _context;

  @override
  void go(String location, {Object? extra}) {
    OxoRouterScope.of(_context).go(location, extra: extra);
  }

  @override
  void push(String location, {Object? extra}) {
    OxoRouterScope.of(_context).push(location, extra: extra);
  }
}
