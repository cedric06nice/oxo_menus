import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';

/// Adapter that fulfills [AdminTemplateCreatorRouter] by forwarding to the
/// legacy `go_router` tree via a [LegacyNavigator].
///
/// Used while the admin-template-creator screen lives at the legacy
/// `/admin/templates/create` path inside `app_router.dart`. The downstream
/// admin template editor already lives on the migrated `MainRouter` stack
/// (Phase 11), so [goToAdminTemplateEditor] deep-links directly into
/// `/app/admin/templates/{id}/edit`. [goToAdminSizes] forwards to the legacy
/// admin sizes path (still served by `app_router.dart`), and [goBack] returns
/// to the admin templates list. Once `MainRouter` mounts the create screen
/// itself this adapter can be deleted.
class LegacyAdminTemplateCreatorRouter implements AdminTemplateCreatorRouter {
  LegacyAdminTemplateCreatorRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.adminTemplates);

  @override
  void goToAdminSizes() => _navigator.go(AppRoutes.adminSizes);

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go('/app/admin/templates/$menuId/edit');
}
