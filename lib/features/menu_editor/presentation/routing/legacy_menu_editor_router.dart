import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_router.dart';

/// Adapter that fulfills [MenuEditorRouter] by forwarding to the legacy
/// `go_router` tree via a [LegacyNavigator].
///
/// Used while the menu editor lives at the legacy `/menus/:id` path inside
/// `app_router.dart`. [goBack] returns to the menu list and [goToPdfPreview]
/// deep-links to the legacy PDF-preview path served by the same go_router
/// tree. Once `MainRouter` mounts the menu list and the PDF preview itself
/// this adapter can be deleted.
class LegacyMenuEditorRouter implements MenuEditorRouter {
  LegacyMenuEditorRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.menus);

  @override
  void goToPdfPreview(int menuId) => _navigator.go(AppRoutes.menuPdf(menuId));
}
