/// Immutable state of the reset-password form.
///
/// Defaults to "no error / not submitting / not changed yet / online" — the
/// state shown the first time the screen renders for a user who just clicked
/// the email link on a working connection.
final class ResetPasswordState {
  const ResetPasswordState({
    this.passwordError,
    this.confirmError,
    this.isSubmitting = false,
    this.errorMessage,
    this.passwordChanged = false,
    this.isOffline = false,
  });

  /// Field-level message for the new-password input, or `null` when valid.
  final String? passwordError;

  /// Field-level message for the confirm-password input, or `null` when valid.
  final String? confirmError;

  /// `true` while a [ConfirmPasswordResetUseCase] call is in flight.
  final bool isSubmitting;

  /// Server-side error message from the gateway, or `null` when none.
  final String? errorMessage;

  /// `true` once the password has been changed successfully — the terminal
  /// success state of the screen.
  final bool passwordChanged;

  /// `true` when the device is currently offline. Drives the offline banner
  /// at the top of the screen.
  final bool isOffline;

  ResetPasswordState copyWith({
    Object? passwordError = _sentinel,
    Object? confirmError = _sentinel,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
    bool? passwordChanged,
    bool? isOffline,
  }) {
    return ResetPasswordState(
      passwordError: identical(passwordError, _sentinel)
          ? this.passwordError
          : passwordError as String?,
      confirmError: identical(confirmError, _sentinel)
          ? this.confirmError
          : confirmError as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      passwordChanged: passwordChanged ?? this.passwordChanged,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is ResetPasswordState &&
      other.passwordError == passwordError &&
      other.confirmError == confirmError &&
      other.isSubmitting == isSubmitting &&
      other.errorMessage == errorMessage &&
      other.passwordChanged == passwordChanged &&
      other.isOffline == isOffline;

  @override
  int get hashCode => Object.hash(
    passwordError,
    confirmError,
    isSubmitting,
    errorMessage,
    passwordChanged,
    isOffline,
  );
}
