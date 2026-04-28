import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the menu-list feature.
///
/// `LegacyMenuListRouter` implements this in production; the
/// [MenuListViewModel] depends on it so the view model never sees
/// `BuildContext` or any concrete router.
abstract class MenuListRouter implements FeatureRouter {
  /// Open the read-only menu editor for [menuId].
  void goToMenuEditor(int menuId);

  /// Open the admin template editor for [menuId].
  void goToAdminTemplateEditor(int menuId);

  /// Pop the menu list off the stack — typically returns to the home screen.
  void goBack();
}
