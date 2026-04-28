import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';

/// Adapter that fulfills [AdminTemplateCreatorRouter] by forwarding to the
/// `go_router` tree via a [RouteNavigator]. [goToAdminTemplateEditor]
/// deep-links into `/admin/templates/:id`, [goToAdminSizes] into
/// `/admin/sizes`, and [goBack] returns to `/admin/templates`.
///
/// Wired by `_AdminTemplateCreatorRouteHost` in `app_router.dart` for
/// the `/admin/templates/create` GoRoute.
class AdminTemplateCreatorRouteAdapter implements AdminTemplateCreatorRouter {
  AdminTemplateCreatorRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.adminTemplates);

  @override
  void goToAdminSizes() => _navigator.go(AppRoutes.adminSizes);

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go(AppRoutes.adminTemplateEditor(menuId));
}
