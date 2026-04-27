import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the admin-templates feature.
///
/// `MainRouter` implements this; the [AdminTemplatesViewModel] depends on it
/// so the view model never sees `BuildContext` or any concrete router. While
/// the template-create and template-editor screens remain on the legacy
/// stack, the matching methods bridge through `LegacyNavigator`.
abstract class AdminTemplatesRouter implements FeatureRouter {
  /// Open the create-template flow.
  void goToAdminTemplateCreate();

  /// Open the admin template editor for [menuId].
  void goToAdminTemplateEditor(int menuId);

  /// Pop the admin templates page off the stack — typically returns to the
  /// home screen.
  void goBack();
}
