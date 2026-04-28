/// Immutable state of the forgot-password form.
///
/// All field-level errors default to "no error", `isSubmitting` to `false`,
/// `emailSent` to `false`, and `isOffline` to `false` — the state shown the
/// first time the screen renders for a user with a working connection.
final class ForgotPasswordState {
  const ForgotPasswordState({
    this.emailError,
    this.isSubmitting = false,
    this.errorMessage,
    this.emailSent = false,
    this.isOffline = false,
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

  /// `true` when the device is currently offline. Drives the offline banner
  /// at the top of the screen.
  final bool isOffline;

  ForgotPasswordState copyWith({
    Object? emailError = _sentinel,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
    bool? emailSent,
    bool? isOffline,
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
      isOffline: isOffline ?? this.isOffline,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is ForgotPasswordState &&
      other.emailError == emailError &&
      other.isSubmitting == isSubmitting &&
      other.errorMessage == errorMessage &&
      other.emailSent == emailSent &&
      other.isOffline == isOffline;

  @override
  int get hashCode =>
      Object.hash(emailError, isSubmitting, errorMessage, emailSent, isOffline);
}
