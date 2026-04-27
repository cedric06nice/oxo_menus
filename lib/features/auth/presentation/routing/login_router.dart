import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the login feature.
///
/// `MainRouter` implements this; the [LoginViewModel] depends on it so the
/// view model never sees `BuildContext` or any concrete router.
abstract class LoginRouter implements FeatureRouter {
  /// Called after a successful authentication. Implementations route the user
  /// back into the post-login destination (typically `/home`).
  void goToHomeAfterLogin();

  /// Called when the user taps the "Forgot password?" affordance.
  void goToForgotPassword();
}
