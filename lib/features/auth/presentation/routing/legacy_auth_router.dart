import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';

/// Adapter that fulfills [LoginRouter], [ForgotPasswordRouter], and
/// [ResetPasswordRouter] by forwarding to the legacy `go_router` tree via a
/// [LegacyNavigator].
///
/// Used by the auth feature while it lives at the legacy `/login`,
/// `/forgot-password`, `/reset-password` paths inside `app_router.dart`. Once
/// `MainRouter` mounts the auth screens itself this adapter can be deleted.
class LegacyAuthRouter
    implements LoginRouter, ForgotPasswordRouter, ResetPasswordRouter {
  LegacyAuthRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goToHomeAfterLogin() => _navigator.go(AppRoutes.home);

  @override
  void goToForgotPassword() => _navigator.go(AppRoutes.forgotPassword);

  @override
  void goBackToLogin() => _navigator.go(AppRoutes.login);

  @override
  void goToLogin() => _navigator.go(AppRoutes.login);
}
