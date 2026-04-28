import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Bridge interface for navigating from the migrated `MainRouter` back into
/// the legacy `go_router` tree.
///
/// The host (`MainRouterHost`) provides a context-backed implementation; tests
/// inject a recording fake. Once every feature has migrated, this abstraction
/// can be deleted along with the legacy router.
abstract class LegacyNavigator {
  /// Navigate to [location] on the legacy `go_router`, replacing the current
  /// route. Equivalent to `context.go(location, extra: extra)`.
  void go(String location, {Object? extra});
}

/// Default [LegacyNavigator] that forwards to `context.go(...)` on the legacy
/// `go_router` tree.
///
/// Used by both `MainRouterHost` (so `MainRouter` can leave back into legacy
/// pages) and by the legacy `/login`, `/forgot-password`, `/reset-password`
/// GoRoute builders (so the MVVM auth ViewModels can navigate via the legacy
/// router during the migration).
class GoRouterLegacyNavigator implements LegacyNavigator {
  const GoRouterLegacyNavigator(this._context);

  final BuildContext _context;

  @override
  void go(String location, {Object? extra}) {
    _context.go(location, extra: extra);
  }
}
