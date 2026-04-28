import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the PDF-preview feature.
///
/// `PdfPreviewRouteAdapter` implements this in production so the
/// [PdfPreviewViewModel] can navigate without ever touching `BuildContext`.
/// The PDF preview is a leaf screen — it only knows how to walk the user
/// back.
abstract class PdfPreviewRouter implements FeatureRouter {
  /// Pop the preview — typically returns to the editor or the menu list.
  void goBack();
}
