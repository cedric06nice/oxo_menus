import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';

/// Adapter that fulfills [HomeRouter] by forwarding quick-action taps to the
/// `OxoRouter` via a [RouteNavigator].
///
/// Wired by `_HomeRouteHost` in `app_router.dart` for the `/home`
/// route.
class HomeRouteAdapter implements HomeRouter {
  HomeRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goToMenus() => _navigator.go(AppRoutes.menus);

  @override
  void goToSettings() => _navigator.go(AppRoutes.settings);

  @override
  void goToAdminTemplates() => _navigator.go(AppRoutes.adminTemplates);

  @override
  void goToAdminTemplateCreate() =>
      _navigator.go(AppRoutes.adminTemplateCreate);

  @override
  void goToAdminExportableMenus() =>
      _navigator.go(AppRoutes.adminExportableMenus);
}
