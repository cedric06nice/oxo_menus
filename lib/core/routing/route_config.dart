/// Sealed type describing every destination the `MainRouter` can render.
///
/// Each variant carries the data needed to construct the screen. New variants
/// are added per-phase as features migrate; until then [UnknownRouteConfig]
/// catches any URI handed to the router.
sealed class RouteConfig {
  const RouteConfig();
}

/// Login screen — the entry point for unauthenticated users.
final class LoginRouteConfig extends RouteConfig {
  const LoginRouteConfig();

  @override
  bool operator ==(Object other) => other is LoginRouteConfig;

  @override
  int get hashCode => (LoginRouteConfig).hashCode;

  @override
  String toString() => 'LoginRouteConfig()';
}

/// Forgot-password screen — reachable from the login screen and via deep
/// link.
final class ForgotPasswordRouteConfig extends RouteConfig {
  const ForgotPasswordRouteConfig();

  @override
  bool operator ==(Object other) => other is ForgotPasswordRouteConfig;

  @override
  int get hashCode => (ForgotPasswordRouteConfig).hashCode;

  @override
  String toString() => 'ForgotPasswordRouteConfig()';
}

/// Fallback variant for URIs that do not yet match a migrated feature.
///
/// During the migration the legacy `go_router` handles all unknown paths;
/// `MainRouter` simply records the URI so it can be restored if the user
/// refreshes the page.
final class UnknownRouteConfig extends RouteConfig {
  const UnknownRouteConfig(this.uri);

  final Uri uri;

  @override
  bool operator ==(Object other) =>
      other is UnknownRouteConfig && other.uri == uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => 'UnknownRouteConfig($uri)';
}
