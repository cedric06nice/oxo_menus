import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';

/// Adapter that fulfills [LoginRouter], [ForgotPasswordRouter], and
/// [ResetPasswordRouter] by forwarding to the `go_router` tree via a
/// [RouteNavigator].
///
/// Wired by the `_LoginRouteHost`, `_ForgotPasswordRouteHost`, and
/// `_ResetPasswordRouteHost` in `app_router.dart` for the `/login`,
/// `/forgot-password`, and `/reset-password` GoRoutes.
class AuthRouteAdapter
    implements LoginRouter, ForgotPasswordRouter, ResetPasswordRouter {
  AuthRouteAdapter(this._navigator);

  final RouteNavigator _navigator;

  @override
  void goToHomeAfterLogin() => _navigator.go(AppRoutes.home);

  @override
  void goToForgotPassword() => _navigator.go(AppRoutes.forgotPassword);

  @override
  void goBackToLogin() => _navigator.go(AppRoutes.login);

  @override
  void goToLogin() => _navigator.go(AppRoutes.login);
}
