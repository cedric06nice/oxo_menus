import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';

/// Adapter that fulfills [AdminTemplateCreatorRouter] by forwarding to the
/// legacy `go_router` tree via a [LegacyNavigator].
///
/// Used while the admin-template-creator screen lives at the legacy
/// `/admin/templates/create` path inside `app_router.dart`. As of Phase 24
/// the downstream admin template editor is also served by the legacy
/// go_router tree (at `/admin/templates/:id`), so [goToAdminTemplateEditor]
/// deep-links directly into that path. [goToAdminSizes] forwards to the
/// legacy admin sizes path, and [goBack] returns to the admin templates list.
/// Once `MainRouter` mounts the create screen itself this adapter can be
/// deleted.
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
