import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';

/// Adapter that fulfills [SettingsRouter] by forwarding to the `go_router`
/// tree via a [LegacyNavigator].
///
/// Wired by `_LegacySettingsRouteHost` in `app_router.dart` for the
/// `/settings` GoRoute.
class LegacySettingsRouter implements SettingsRouter {
  LegacySettingsRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
