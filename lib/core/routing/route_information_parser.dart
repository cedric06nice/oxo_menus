import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/routing/route_config.dart';

/// Parses platform [RouteInformation] into a [RouteConfig] (and back).
///
/// As features migrate, each path under `/app/*` gains a matching variant
/// here. URIs that do not yet match a migrated feature are returned as
/// [UnknownRouteConfig] so the legacy go_router can keep serving them.
class AppRouteInformationParser extends RouteInformationParser<RouteConfig> {
  AppRouteInformationParser();

  static const String _loginPath = '/app/login';

  @override
  Future<RouteConfig> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    if (uri.path == _loginPath) {
      return const LoginRouteConfig();
    }
    return UnknownRouteConfig(uri);
  }

  @override
  RouteInformation? restoreRouteInformation(RouteConfig configuration) {
    return switch (configuration) {
      LoginRouteConfig() => RouteInformation(uri: Uri.parse(_loginPath)),
      UnknownRouteConfig(:final uri) => RouteInformation(uri: uri),
    };
  }
}
