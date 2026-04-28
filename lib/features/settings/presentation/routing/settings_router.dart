import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the settings feature.
///
/// `SettingsRouteAdapter` implements this in production; the
/// [SettingsViewModel] depends on it so the view model never sees
/// `BuildContext` or any concrete router.
abstract class SettingsRouter implements FeatureRouter {
  /// Pop the settings screen off the stack — typically returns to home.
  void goBack();
}
