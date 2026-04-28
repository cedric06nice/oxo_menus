import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_router.dart';

/// Adapter that fulfills [AdminTemplateEditorRouter] by forwarding to the
/// `OxoRouter` via a [RouteNavigator]. [goBack] returns to
/// `/admin/templates`, [goToAdminSizes] forwards to `/admin/sizes`, and
/// [goToPdfPreview] deep-links to `/menus/pdf/:id`.
///
/// Wired by `_AdminTemplateEditorRouteHost` in `app_router.dart` for
/// the `/admin/templates/:id` route.
class AdminTemplateEditorRouteAdapter implements AdminTemplateEditorRouter {
  AdminTemplateEditorRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.adminTemplates);

  @override
  void goToAdminSizes() => _navigator.go(AppRoutes.adminSizes);

  @override
  void goToPdfPreview(int menuId) => _navigator.go(AppRoutes.menuPdf(menuId));
}
