import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';

/// Adapter that fulfills [AdminTemplatesRouter] by forwarding to the
/// `OxoRouter` via a [RouteNavigator]. The editor and create methods
/// deep-link into `/admin/templates/:id` and [AppRoutes.adminTemplateCreate].
///
/// Wired by `_AdminTemplatesRouteHost` in `app_router.dart` for the
/// `/admin/templates` route.
class AdminTemplatesRouteAdapter implements AdminTemplatesRouter {
  AdminTemplatesRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goToAdminTemplateCreate() =>
      _navigator.go(AppRoutes.adminTemplateCreate);

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go(AppRoutes.adminTemplateEditor(menuId));

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
