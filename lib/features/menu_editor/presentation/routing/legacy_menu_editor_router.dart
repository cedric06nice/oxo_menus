import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_router.dart';

/// Adapter that fulfills [MenuEditorRouter] by forwarding to the `go_router`
/// tree via a [LegacyNavigator]. [goBack] returns to `/menus` and
/// [goToPdfPreview] deep-links to `/menus/pdf/:id`.
///
/// Wired by `_LegacyMenuEditorRouteHost` in `app_router.dart` for the
/// `/menus/:id` GoRoute.
class LegacyMenuEditorRouter implements MenuEditorRouter {
  LegacyMenuEditorRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.menus);

  @override
  void goToPdfPreview(int menuId) => _navigator.go(AppRoutes.menuPdf(menuId));
}
