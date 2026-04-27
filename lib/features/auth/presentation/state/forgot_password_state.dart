/// Immutable state of the forgot-password form.
///
/// Defaults to "no error / not submitting / no email sent yet", which is the
/// state shown the first time the screen renders.
final class ForgotPasswordState {
  const ForgotPasswordState({
    this.emailError,
    this.isSubmitting = false,
    this.errorMessage,
    this.emailSent = false,
  });

  /// Field-level message for the email input, or `null` when valid.
  final String? emailError;

  /// `true` while a [RequestPasswordResetUseCase] call is in flight.
  final bool isSubmitting;

  /// Server-side error message from the gateway, or `null` when none.
  final String? errorMessage;

  /// `true` once the reset email has been requested successfully — the
  /// terminal success state of the screen.
  final bool emailSent;

  ForgotPasswordState copyWith({
    Object? emailError = _sentinel,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
    bool? emailSent,
  }) {
    return ForgotPasswordState(
      emailError: identical(emailError, _sentinel)
          ? this.emailError
          : emailError as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      emailSent: emailSent ?? this.emailSent,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is ForgotPasswordState &&
      other.emailError == emailError &&
      other.isSubmitting == isSubmitting &&
      other.errorMessage == errorMessage &&
      other.emailSent == emailSent;

  @override
  int get hashCode =>
      Object.hash(emailError, isSubmitting, errorMessage, emailSent);
}
