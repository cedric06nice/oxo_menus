import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/reset_password_view_model.dart';

/// Stack entry for the reset-password screen.
///
/// Builds the use case → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and reused
/// across rebuilds; [disposeResources] tears it down when the page leaves the
/// stack for good.
///
/// Carries the [token] captured from the deep-link query parameter so the
/// view model can confirm the reset for the right account. A null token puts
/// the screen in the missing-token branch — the route page itself does not
/// gate on the token, since the screen surfaces the missing-token UI to the
/// user.
class ResetPasswordRoutePage extends RoutePage {
  ResetPasswordRoutePage({required this.router, required this.token});

  final ResetPasswordRouter router;
  final String? token;
  ResetPasswordViewModel? _viewModel;

  @override
  Object get identity => 'reset-password-${token ?? ''}';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= ResetPasswordViewModel(
      confirmPasswordReset: ConfirmPasswordResetUseCase(
        gateway: container.authGateway,
      ),
      router: router,
      token: token,
    );
    return ResetPasswordScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }
}
