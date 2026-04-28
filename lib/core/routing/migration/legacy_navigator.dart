import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Bridge interface that lets each feature's `Legacy*Router` adapter navigate
/// the live `go_router` tree without exposing `BuildContext` or any Flutter
/// primitives to ViewModels.
///
/// The route hosts in `app_router.dart` provide a context-backed
/// [GoRouterLegacyNavigator]; tests inject a recording fake.
abstract class LegacyNavigator {
  /// Navigate to [location] on the `go_router`, replacing the current route.
  /// Equivalent to `context.go(location, extra: extra)`.
  void go(String location, {Object? extra});
}

/// Default [LegacyNavigator] that forwards to `context.go(...)` on the
/// `go_router` tree. Used by every `_Legacy*RouteHost` to bridge `BuildContext`
/// into the feature's `Legacy*Router` adapter.
class GoRouterLegacyNavigator implements LegacyNavigator {
  const GoRouterLegacyNavigator(this._context);

  final BuildContext _context;

  @override
  void go(String location, {Object? extra}) {
    _context.go(location, extra: extra);
  }
}
