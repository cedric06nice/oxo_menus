import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/forgot_password_state.dart';

/// View model that owns the forgot-password screen's form state.
///
/// Performs local validation, drives the [RequestPasswordResetUseCase], and
/// delegates navigation to the injected [ForgotPasswordRouter]. Knows nothing
/// about widgets, `BuildContext`, or Riverpod.
///
/// [resetUrl] is the platform-resolved deep-link target embedded in the
/// reset email. The route page builds it (handling `kIsWeb` / dart-define)
/// and passes it in at construction time so the view model stays
/// platform-agnostic.
class ForgotPasswordViewModel extends ViewModel<ForgotPasswordState> {
  ForgotPasswordViewModel({
    required RequestPasswordResetUseCase requestPasswordReset,
    required ForgotPasswordRouter router,
    String? resetUrl,
  }) : _requestPasswordReset = requestPasswordReset,
       _router = router,
       _resetUrl = resetUrl,
       super(const ForgotPasswordState());

  final RequestPasswordResetUseCase _requestPasswordReset;
  final ForgotPasswordRouter _router;
  final String? _resetUrl;

  Future<void> submit({required String email}) async {
    if (state.isSubmitting) {
      return;
    }
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      emit(
        state.copyWith(
          emailError: 'Please enter your email',
          errorMessage: null,
        ),
      );
      return;
    }
    emit(const ForgotPasswordState(emailError: null, isSubmitting: true));
    final result = await _requestPasswordReset.execute(
      RequestPasswordResetInput(email: trimmedEmail, resetUrl: _resetUrl),
    );
    result.fold(
      onSuccess: (_) {
        emit(
          const ForgotPasswordState(
            emailError: null,
            isSubmitting: false,
            errorMessage: null,
            emailSent: true,
          ),
        );
      },
      onFailure: (error) {
        emit(ForgotPasswordState(errorMessage: error.message));
      },
    );
  }

  void goBackToLogin() => _router.goBackToLogin();
}
