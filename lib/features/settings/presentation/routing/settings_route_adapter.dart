import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';

/// Adapter that fulfills [SettingsRouter] by forwarding to the `OxoRouter`
/// tree via a [RouteNavigator].
///
/// Wired by `_SettingsRouteHost` in `app_router.dart` for the
/// `/settings` route.
class SettingsRouteAdapter implements SettingsRouter {
  SettingsRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
