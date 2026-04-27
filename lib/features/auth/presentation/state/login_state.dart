/// Immutable state of the login form.
///
/// All four fields default to "no error / not submitting", which is the state
/// shown the first time the screen renders.
final class LoginState {
  const LoginState({
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Field-level message for the email input, or `null` when valid.
  final String? emailError;

  /// Field-level message for the password input, or `null` when valid.
  final String? passwordError;

  /// `true` while a [LoginUseCase.execute] call is in flight.
  final bool isSubmitting;

  /// Server-side error message from the gateway, or `null` when none.
  final String? errorMessage;

  LoginState copyWith({
    Object? emailError = _sentinel,
    Object? passwordError = _sentinel,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
  }) {
    return LoginState(
      emailError: identical(emailError, _sentinel)
          ? this.emailError
          : emailError as String?,
      passwordError: identical(passwordError, _sentinel)
          ? this.passwordError
          : passwordError as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is LoginState &&
      other.emailError == emailError &&
      other.passwordError == passwordError &&
      other.isSubmitting == isSubmitting &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      Object.hash(emailError, passwordError, isSubmitting, errorMessage);
}
