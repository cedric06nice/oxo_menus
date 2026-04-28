import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';

/// Adapter that fulfills [AdminExportableMenusRouter] by forwarding to the
/// `OxoRouter` via a [RouteNavigator]. The screen is a leaf — its only
/// navigation is "back" — so the adapter exposes nothing more.
///
/// Wired by `_AdminExportableMenusRouteHost` in `app_router.dart` for
/// the `/admin/exportable_menus` route.
class AdminExportableMenusRouteAdapter implements AdminExportableMenusRouter {
  AdminExportableMenusRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
