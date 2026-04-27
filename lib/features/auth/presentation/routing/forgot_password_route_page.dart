import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/forgot_password_view_model.dart';

/// Stack entry for the forgot-password screen.
///
/// Builds the use case → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and reused
/// across rebuilds; [disposeResources] tears it down when the page leaves the
/// stack for good.
///
/// The deep-link [resetUrl] embedded in the reset email is resolved per
/// platform here so the view model itself stays platform-agnostic. On web it
/// derives from the current origin; on mobile it falls back to the
/// `RESET_URL_BASE` dart-define (or `null` to use the Directus default).
class ForgotPasswordRoutePage extends RoutePage {
  ForgotPasswordRoutePage({
    required this.router,
    String? Function()? resolveResetUrl,
  }) : _resolveResetUrl = resolveResetUrl ?? _defaultResolveResetUrl;

  final ForgotPasswordRouter router;
  final String? Function() _resolveResetUrl;
  ForgotPasswordViewModel? _viewModel;

  @override
  Object get identity => 'forgot-password';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= ForgotPasswordViewModel(
      requestPasswordReset: RequestPasswordResetUseCase(
        gateway: container.authGateway,
      ),
      router: router,
      resetUrl: _resolveResetUrl(),
    );
    return ForgotPasswordScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }
}

String? _defaultResolveResetUrl() {
  if (kIsWeb) {
    return Uri.base.resolve(AppRoutes.resetPassword).toString();
  }
  const resetUrlBase = String.fromEnvironment('RESET_URL_BASE');
  if (resetUrlBase.isNotEmpty) {
    return '$resetUrlBase${AppRoutes.resetPassword}';
  }
  return null;
}
