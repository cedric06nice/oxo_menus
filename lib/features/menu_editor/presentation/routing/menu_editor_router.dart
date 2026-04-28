import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the consumer-facing menu editor feature.
///
/// `MenuEditorRouteAdapter` implements this in production; the
/// [MenuEditorViewModel] depends on it so the view model never sees
/// `BuildContext` or any concrete router.
abstract class MenuEditorRouter implements FeatureRouter {
  /// Pop the screen — typically returns to the menu list.
  void goBack();

  /// Open the PDF preview for the given menu.
  void goToPdfPreview(int menuId);
}
