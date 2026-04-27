import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the home feature.
///
/// `MainRouter` implements this; the [HomeViewModel] depends on it so the view
/// model never sees `BuildContext` or any concrete router.
abstract class HomeRouter implements FeatureRouter {
  /// Quick-action: jump to the menu list.
  void goToMenus();

  /// Quick-action (admin only): jump to the templates list.
  void goToAdminTemplates();

  /// Quick-action (admin only): jump to the new-template flow.
  void goToAdminTemplateCreate();

  /// Quick-action (admin only): jump to the exportable-menus dashboard.
  void goToAdminExportableMenus();
}
