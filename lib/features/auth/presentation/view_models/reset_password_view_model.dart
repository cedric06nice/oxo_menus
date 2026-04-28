import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/confirm_password_reset_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/reset_password_state.dart';

/// View model that owns the reset-password screen's form state.
///
/// Performs local validation, drives the [ConfirmPasswordResetUseCase], and
/// delegates navigation to the injected [ResetPasswordRouter]. Knows nothing
/// about widgets, `BuildContext`, or Riverpod.
///
/// The reset [token] is captured at construction time from the deep-link query
/// parameter. A null or empty token leaves the screen in a "missing token"
/// state — the screen surfaces this via [hasToken] and submit is rejected
/// before reaching the use case.
class ResetPasswordViewModel extends ViewModel<ResetPasswordState> {
  ResetPasswordViewModel({
    required ConfirmPasswordResetUseCase confirmPasswordReset,
    required ResetPasswordRouter router,
    required String? token,
  })  : _confirmPasswordReset = confirmPasswordReset,
        _router = router,
        _token = token,
        super(const ResetPasswordState());

  final ConfirmPasswordResetUseCase _confirmPasswordReset;
  final ResetPasswordRouter _router;
  final String? _token;

  /// The reset token captured at construction time, or `null` when the deep
  /// link was opened without one.
  String? get token => _token;

  /// `true` when the screen has a usable token. The screen renders the
  /// missing-token branch when this is `false`.
  bool get hasToken => _token != null && _token.isNotEmpty;

  Future<void> submit({
    required String password,
    required String confirm,
  }) async {
    if (state.isSubmitting) {
      return;
    }
    final passwordError = _validatePassword(password);
    final confirmError = passwordError == null
        ? _validateConfirm(password: password, confirm: confirm)
        : null;
    if (passwordError != null || confirmError != null) {
      emit(
        state.copyWith(
          passwordError: passwordError,
          confirmError: confirmError,
          errorMessage: null,
        ),
      );
      return;
    }
    if (!hasToken) {
      emit(
        state.copyWith(
          passwordError: null,
          confirmError: null,
          errorMessage: 'Invalid or missing reset token',
        ),
      );
      return;
    }
    emit(
      const ResetPasswordState(
        passwordError: null,
        confirmError: null,
        isSubmitting: true,
        errorMessage: null,
      ),
    );
    final result = await _confirmPasswordReset.execute(
      ConfirmPasswordResetInput(token: _token!, password: password),
    );
    result.fold(
      onSuccess: (_) {
        emit(
          const ResetPasswordState(
            passwordError: null,
            confirmError: null,
            isSubmitting: false,
            errorMessage: null,
            passwordChanged: true,
          ),
        );
      },
      onFailure: (error) {
        emit(ResetPasswordState(errorMessage: error.message));
      },
    );
  }

  void goToLogin() => _router.goToLogin();

  void goToForgotPassword() => _router.goToForgotPassword();

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a new password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirm({
    required String password,
    required String confirm,
  }) {
    if (confirm != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
