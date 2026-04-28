import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';

/// Adapter that fulfills [AdminTemplatesRouter] by forwarding to the
/// `go_router` tree via a [LegacyNavigator]. The editor and create methods
/// deep-link into `/admin/templates/:id` and [AppRoutes.adminTemplateCreate].
///
/// Wired by `_LegacyAdminTemplatesRouteHost` in `app_router.dart` for the
/// `/admin/templates` GoRoute.
class LegacyAdminTemplatesRouter implements AdminTemplatesRouter {
  LegacyAdminTemplatesRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goToAdminTemplateCreate() =>
      _navigator.go(AppRoutes.adminTemplateCreate);

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go(AppRoutes.adminTemplateEditor(menuId));

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
