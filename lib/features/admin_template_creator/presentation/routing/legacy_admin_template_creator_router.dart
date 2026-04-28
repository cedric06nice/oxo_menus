import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';

/// Adapter that fulfills [AdminTemplateCreatorRouter] by forwarding to the
/// `go_router` tree via a [LegacyNavigator]. [goToAdminTemplateEditor]
/// deep-links into `/admin/templates/:id`, [goToAdminSizes] into
/// `/admin/sizes`, and [goBack] returns to `/admin/templates`.
///
/// Wired by `_LegacyAdminTemplateCreatorRouteHost` in `app_router.dart` for
/// the `/admin/templates/create` GoRoute.
class LegacyAdminTemplateCreatorRouter implements AdminTemplateCreatorRouter {
  LegacyAdminTemplateCreatorRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.adminTemplates);

  @override
  void goToAdminSizes() => _navigator.go(AppRoutes.adminSizes);

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go(AppRoutes.adminTemplateEditor(menuId));
}
