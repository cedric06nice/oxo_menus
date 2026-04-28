import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';

/// Adapter that fulfills [PdfPreviewRouter] by forwarding to the `go_router`
/// tree via a [RouteNavigator]. The screen is a leaf — its only navigation
/// is "back" — so the adapter exposes nothing more.
///
/// Wired by `_PdfPreviewRouteHost` in `app_router.dart` for the
/// `/menus/pdf/:id` GoRoute.
class PdfPreviewRouteAdapter implements PdfPreviewRouter {
  PdfPreviewRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.menus);
}
