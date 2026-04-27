import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the admin-exportable-menus feature.
///
/// `MainRouter` implements this; the [AdminExportableMenusViewModel] depends
/// on it so the view model never sees `BuildContext` or any concrete router.
abstract class AdminExportableMenusRouter implements FeatureRouter {
  /// Pop the screen — typically returns to the home dashboard.
  void goBack();
}
