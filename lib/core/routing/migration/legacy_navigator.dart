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
