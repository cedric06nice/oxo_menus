import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_router.dart';

/// Adapter that fulfills [AdminSizesRouter] by forwarding to the `OxoRouter`
/// tree via a [RouteNavigator]. The screen is a leaf — its only navigation
/// is "back" — so the adapter exposes nothing more.
///
/// Wired by `_AdminSizesRouteHost` in `app_router.dart` for the
/// `/admin/sizes` route.
class AdminSizesRouteAdapter implements AdminSizesRouter {
  AdminSizesRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
