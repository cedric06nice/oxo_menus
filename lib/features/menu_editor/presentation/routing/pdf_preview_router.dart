import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the migrated PDF-preview feature.
///
/// `MainRouter` implements this so the [PdfPreviewViewModel] can navigate
/// without ever touching `BuildContext`. The PDF preview is a leaf screen —
/// it only knows how to walk the user back. Other features push it onto the
/// stack via `MainRouter.push(PdfPreviewRoutePage(...))`.
abstract class PdfPreviewRouter implements FeatureRouter {
  /// Pop the preview — typically returns to the editor or the menu list.
  void goBack();
}
