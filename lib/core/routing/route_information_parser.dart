import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/routing/route_config.dart';

/// Parses platform [RouteInformation] into a [RouteConfig] (and back).
///
/// Phase 0: every URI maps to [UnknownRouteConfig], which means `MainRouter`
/// renders nothing and the legacy go_router handles the route. As features
/// migrate, add a `case` here that returns the matching feature route config.
class AppRouteInformationParser extends RouteInformationParser<RouteConfig> {
  AppRouteInformationParser();

  @override
  Future<RouteConfig> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return UnknownRouteConfig(routeInformation.uri);
  }

  @override
  RouteInformation? restoreRouteInformation(RouteConfig configuration) {
    return switch (configuration) {
      UnknownRouteConfig(:final uri) => RouteInformation(uri: uri),
    };
  }
}
