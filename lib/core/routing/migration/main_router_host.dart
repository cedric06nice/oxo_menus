import 'package:flutter/material.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/main_router.dart';
import 'package:oxo_menus/core/routing/route_information_parser.dart';

/// Hosts the [MainRouter] inside the legacy `go_router` tree during the
/// migration.
///
/// Mounted by `app_router.dart` at the `'/app/*'` route. As features migrate,
/// they push their `RoutePage` onto `MainRouter` from inside this host; from
/// here `context.go(...)` is still used to leave back to legacy routes.
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
    return Router<Object>(
      routerDelegate: _router,
      routeInformationParser: _parser,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}
