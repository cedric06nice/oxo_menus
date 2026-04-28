import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the admin template editor feature.
///
/// `LegacyAdminTemplateEditorRouter` implements this in production; the
/// [AdminTemplateEditorViewModel] depends on it so the view model never sees
/// `BuildContext` or any concrete router.
abstract class AdminTemplateEditorRouter implements FeatureRouter {
  /// Pop the screen — typically returns to the menu list.
  void goBack();

  /// Open the admin sizes management screen.
  void goToAdminSizes();

  /// Open the PDF preview for the given menu.
  void goToPdfPreview(int menuId);
}
