import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';

/// Adapter that fulfills [AdminTemplatesRouter] by forwarding to the legacy
/// `go_router` tree via a [LegacyNavigator].
///
/// Used while the admin-templates list lives at the legacy `/admin/templates`
/// path inside `app_router.dart`. The downstream admin template editor already
/// lives on the migrated `MainRouter` stack (Phase 11), so the editor method
/// deep-links directly into `/app/admin/templates/{id}/edit`. The
/// template-create route is still served by the legacy go_router tree at
/// [AppRoutes.adminTemplateCreate]. Once `MainRouter` mounts the admin
/// templates list itself this adapter can be deleted.
class LegacyAdminTemplatesRouter implements AdminTemplatesRouter {
  LegacyAdminTemplatesRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goToAdminTemplateCreate() =>
      _navigator.go(AppRoutes.adminTemplateCreate);

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go('/app/admin/templates/$menuId/edit');

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
