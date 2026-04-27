import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/main_router.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/core/routing/route_information_parser.dart';

/// Hosts the [MainRouter] inside the legacy `go_router` tree during the
/// migration.
///
/// Mounted by `app_router.dart` at the `'/app/*'` route. As features migrate,
/// they push their `RoutePage` onto `MainRouter` from inside this host; from
/// here a [LegacyNavigator] is still used to leave back to legacy routes.
class MainRouterHost extends StatefulWidget {
  const MainRouterHost({super.key, required this.container});

  final AppContainer container;

  @override
  State<MainRouterHost> createState() => _MainRouterHostState();
}

class _MainRouterHostState extends State<MainRouterHost> {
  late final MainRouter _router;
  late final AppRouteInformationParser _parser;

  @override
  void initState() {
    super.initState();
    _router = MainRouter(container: widget.container);
    _parser = AppRouteInformationParser();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _router.legacyNavigator = _GoRouterLegacyNavigator(context);
    return Router<Object>(
      routerDelegate: _router,
      routeInformationParser: _parser,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}

class _GoRouterLegacyNavigator implements LegacyNavigator {
  const _GoRouterLegacyNavigator(this._context);

  final BuildContext _context;

  @override
  void go(String location, {Object? extra}) {
    _context.go(location, extra: extra);
  }
}
