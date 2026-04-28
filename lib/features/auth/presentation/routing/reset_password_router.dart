import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the reset-password feature.
///
/// `AuthRouteAdapter` implements this in production; the
/// [ResetPasswordViewModel] depends on it so the view model never sees
/// `BuildContext` or any concrete router.
///
/// Reset-password is reached only via the deep-link emitted by the password
/// reset email. From there the user can either land back at login (after a
/// successful change, or by choice) or restart the flow by requesting a fresh
/// reset email.
abstract class ResetPasswordRouter implements FeatureRouter {
  /// Called from the success screen ("Go to Login") and any other affordance
  /// that should land the user on the login screen.
  void goToLogin();

  /// Called when the user wants to request a fresh reset email — typically
  /// after a missing/expired token error.
  void goToForgotPassword();
}
