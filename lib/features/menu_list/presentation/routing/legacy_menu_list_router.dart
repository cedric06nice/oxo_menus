import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';

/// Adapter that fulfills [MenuListRouter] by forwarding to the `go_router`
/// tree via a [LegacyNavigator]. The editor methods deep-link into
/// `/menus/:id` and `/admin/templates/:id`.
///
/// Wired by `_LegacyMenuListRouteHost` in `app_router.dart` for the `/menus`
/// GoRoute.
class LegacyMenuListRouter implements MenuListRouter {
  LegacyMenuListRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goToMenuEditor(int menuId) =>
      _navigator.go(AppRoutes.menuEditor(menuId));

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go(AppRoutes.adminTemplateEditor(menuId));

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
