import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_router.dart';

/// Adapter that fulfills [AdminSizesRouter] by forwarding to the `go_router`
/// tree via a [LegacyNavigator]. The screen is a leaf — its only navigation
/// is "back" — so the adapter exposes nothing more.
///
/// Wired by `_LegacyAdminSizesRouteHost` in `app_router.dart` for the
/// `/admin/sizes` GoRoute.
class LegacyAdminSizesRouter implements AdminSizesRouter {
  LegacyAdminSizesRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
