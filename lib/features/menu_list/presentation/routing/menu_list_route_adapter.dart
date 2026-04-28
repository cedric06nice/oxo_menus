import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';

/// Adapter that fulfills [MenuListRouter] by forwarding to the `go_router`
/// tree via a [RouteNavigator]. The editor methods deep-link into
/// `/menus/:id` and `/admin/templates/:id`.
///
/// Wired by `_MenuListRouteHost` in `app_router.dart` for the `/menus`
/// GoRoute.
class MenuListRouteAdapter implements MenuListRouter {
  MenuListRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goToMenuEditor(int menuId) =>
      _navigator.go(AppRoutes.menuEditor(menuId));

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go(AppRoutes.adminTemplateEditor(menuId));

  @override
  void pushAdminSizes() => _navigator.push(AppRoutes.adminSizes);

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
