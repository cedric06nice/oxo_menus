import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';

/// Adapter that fulfills [AdminExportableMenusRouter] by forwarding to the
/// `go_router` tree via a [LegacyNavigator]. The screen is a leaf — its only
/// navigation is "back" — so the adapter exposes nothing more.
///
/// Wired by `_LegacyAdminExportableMenusRouteHost` in `app_router.dart` for
/// the `/admin/exportable_menus` GoRoute.
class LegacyAdminExportableMenusRouter implements AdminExportableMenusRouter {
  LegacyAdminExportableMenusRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
