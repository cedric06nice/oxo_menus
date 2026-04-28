import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';

/// Adapter that fulfills [AdminExportableMenusRouter] by forwarding to the
/// legacy `go_router` tree via a [LegacyNavigator].
///
/// Used while the admin exportable-menus screen lives at the legacy
/// `/admin/exportable_menus` path inside `app_router.dart`. The screen is a
/// leaf — its only navigation is "back" — so the adapter exposes nothing more.
/// Once `MainRouter` mounts the entire admin flow, the screen will be served
/// from `MainRouter` directly and this adapter can be deleted.
class LegacyAdminExportableMenusRouter implements AdminExportableMenusRouter {
  LegacyAdminExportableMenusRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
