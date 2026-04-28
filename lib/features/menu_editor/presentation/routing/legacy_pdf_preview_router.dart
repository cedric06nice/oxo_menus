import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';

/// Adapter that fulfills [PdfPreviewRouter] by forwarding to the legacy
/// `go_router` tree via a [LegacyNavigator].
///
/// Used while the PDF-preview screen lives at the legacy `/menus/pdf/:id`
/// path inside `app_router.dart`. The screen is a leaf — its only navigation
/// is "back" — so the adapter exposes nothing more. Once `MainRouter` mounts
/// the entire menu list flow, the PDF preview deep-link will be served from
/// `MainRouter` directly and this adapter can be deleted.
class LegacyPdfPreviewRouter implements PdfPreviewRouter {
  LegacyPdfPreviewRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.menus);
}
