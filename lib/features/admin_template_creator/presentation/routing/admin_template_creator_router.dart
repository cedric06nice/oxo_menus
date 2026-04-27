import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the admin-template-creator feature.
///
/// `MainRouter` implements this; the [AdminTemplateCreatorViewModel] depends
/// on it so the view model never sees `BuildContext` or any concrete router.
/// While the admin template editor remains on the legacy stack,
/// [goToAdminTemplateEditor] bridges through `LegacyNavigator`. Once the
/// editor migrates the legacy hop disappears here automatically.
abstract class AdminTemplateCreatorRouter implements FeatureRouter {
  /// Pop the create screen — typically returns to the admin templates list.
  void goBack();

  /// Push the migrated admin sizes screen so the admin can manage page sizes
  /// inline (used from the empty-state CTA when no sizes exist yet).
  void goToAdminSizes();

  /// Open the admin template editor for [menuId] — invoked after a successful
  /// create so the admin lands directly in the freshly created template.
  void goToAdminTemplateEditor(int menuId);
}
