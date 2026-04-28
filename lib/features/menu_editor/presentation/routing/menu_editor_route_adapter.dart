import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_router.dart';

/// Adapter that fulfills [MenuEditorRouter] by forwarding to the `go_router`
/// tree via a [RouteNavigator]. [goBack] returns to `/menus` and
/// [goToPdfPreview] deep-links to `/menus/pdf/:id`.
///
/// Wired by `_MenuEditorRouteHost` in `app_router.dart` for the
/// `/menus/:id` GoRoute.
class MenuEditorRouteAdapter implements MenuEditorRouter {
  MenuEditorRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.menus);

  @override
  void goToPdfPreview(int menuId) => _navigator.go(AppRoutes.menuPdf(menuId));
}
