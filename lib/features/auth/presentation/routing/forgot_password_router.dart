import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the forgot-password feature.
///
/// `LegacyAuthRouter` implements this in production; the
/// [ForgotPasswordViewModel] depends on it so the view model never sees
/// `BuildContext` or any concrete router.
abstract class ForgotPasswordRouter implements FeatureRouter {
  /// Called when the user taps the "Back to login" affordance.
  ///
  /// Implementations pop back to an existing login page on the stack, or
  /// replace the stack with a fresh login page when forgot-password was
  /// reached via a deep link.
  void goBackToLogin();
}
