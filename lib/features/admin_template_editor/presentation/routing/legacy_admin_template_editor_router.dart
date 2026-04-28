import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_router.dart';

/// Adapter that fulfills [AdminTemplateEditorRouter] by forwarding to the
/// legacy `go_router` tree via a [LegacyNavigator].
///
/// Used while the admin template editor lives at the legacy
/// `/admin/templates/:id` path inside `app_router.dart`. [goBack] returns to
/// the admin templates list, [goToAdminSizes] forwards to the legacy admin
/// sizes path, and [goToPdfPreview] deep-links to the legacy PDF-preview path
/// served by the same go_router tree. Once `MainRouter` mounts the admin
/// templates list and the PDF preview itself this adapter can be deleted.
class LegacyAdminTemplateEditorRouter implements AdminTemplateEditorRouter {
  LegacyAdminTemplateEditorRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.adminTemplates);

  @override
  void goToAdminSizes() => _navigator.go(AppRoutes.adminSizes);

  @override
  void goToPdfPreview(int menuId) => _navigator.go(AppRoutes.menuPdf(menuId));
}
