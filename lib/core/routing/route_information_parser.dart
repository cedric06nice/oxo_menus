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
  static const String _forgotPasswordPath = '/app/forgot-password';
  static const String _homePath = '/app/home';
  static const String _menuListPath = '/app/menus';

  @override
  Future<RouteConfig> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    if (uri.path == _loginPath) {
      return const LoginRouteConfig();
    }
    if (uri.path == _forgotPasswordPath) {
      return const ForgotPasswordRouteConfig();
    }
    if (uri.path == _homePath) {
      return const HomeRouteConfig();
    }
    if (uri.path == _menuListPath) {
      return const MenuListRouteConfig();
    }
    return UnknownRouteConfig(uri);
  }

  @override
  RouteInformation? restoreRouteInformation(RouteConfig configuration) {
    return switch (configuration) {
      LoginRouteConfig() => RouteInformation(uri: Uri.parse(_loginPath)),
      ForgotPasswordRouteConfig() => RouteInformation(
        uri: Uri.parse(_forgotPasswordPath),
      ),
      HomeRouteConfig() => RouteInformation(uri: Uri.parse(_homePath)),
      MenuListRouteConfig() => RouteInformation(uri: Uri.parse(_menuListPath)),
      UnknownRouteConfig(:final uri) => RouteInformation(uri: uri),
    };
  }
}
