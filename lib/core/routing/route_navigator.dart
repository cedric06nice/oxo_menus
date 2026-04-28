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
/// [OxoRouterScope] at construction time and forwards `go`/`push` to it. Used
/// by every `_*RouteHost` to bridge `BuildContext` into the feature's
/// `*RouteAdapter`.
///
/// Resolving the router eagerly (rather than on every navigation) is what
/// keeps post-await calls from ViewModels safe: even after the route host's
/// element has been deactivated by a redirect or replacement, the navigator
/// still holds a live router reference and never touches the original
/// `BuildContext` again.
class OxoRouterRouteNavigator implements RouteNavigator {
  OxoRouterRouteNavigator(BuildContext context)
    : _router = OxoRouterScope.read(context);

  final OxoRouter _router;

  @override
  void go(String location, {Object? extra}) =>
      _router.go(location, extra: extra);

  @override
  void push(String location, {Object? extra}) =>
      _router.push(location, extra: extra);
}
