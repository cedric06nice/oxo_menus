import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/state/login_state.dart';

/// View model that owns the login screen's form state.
///
/// Performs local validation, drives the [LoginUseCase], and delegates
/// navigation to the injected [LoginRouter]. Knows nothing about widgets,
/// `BuildContext`, or Riverpod.
class LoginViewModel extends ViewModel<LoginState> {
  LoginViewModel({required LoginUseCase login, required LoginRouter router})
    : _login = login,
      _router = router,
      super(const LoginState());

  final LoginUseCase _login;
  final LoginRouter _router;

  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) {
      return;
    }
    final trimmedEmail = email.trim();
    final emailError = trimmedEmail.isEmpty ? 'Please enter your email' : null;
    final passwordError = password.isEmpty
        ? 'Please enter your password'
        : null;
    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
          errorMessage: null,
        ),
      );
      return;
    }
    emit(
      const LoginState(
        emailError: null,
        passwordError: null,
        isSubmitting: true,
      ),
    );
    final result = await _login.execute(
      LoginInput(email: trimmedEmail, password: password),
    );
    result.fold(
      onSuccess: (_) {
        emit(const LoginState());
        _router.goToHomeAfterLogin();
      },
      onFailure: (error) {
        emit(LoginState(errorMessage: error.message));
      },
    );
  }

  void goToForgotPassword() => _router.goToForgotPassword();
}
