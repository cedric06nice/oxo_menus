import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Outcome of a password-reset request, surfaced to the screen so it can
/// show a snackbar/alert and reset the field afterwards.
enum PasswordResetOutcome { idle, sent, failed }

/// Immutable state of the Settings screen.
///
/// Defaults to "no user, not admin, viewAsUser=false, version null, idle
/// password reset, no error" — the initial value owned by
/// [SettingsViewModel] before the eager loads resolve.
final class SettingsState {
  const SettingsState({
    this.user,
    this.isAdmin = false,
    this.viewAsUser = false,
    this.version,
    this.passwordResetInFlight = false,
    this.passwordResetOutcome = PasswordResetOutcome.idle,
    this.passwordResetMessage,
  });

  /// The signed-in user. `null` when nobody is authenticated.
  final User? user;

  /// Raw admin role check — independent of the [viewAsUser] toggle so the
  /// settings screen can keep showing the debug section even when the toggle
  /// is on.
  final bool isAdmin;

  /// Current value of the admin "view as user" debug toggle.
  final bool viewAsUser;

  /// App version string from `package_info_plus`. `null` until the eager
  /// load resolves.
  final String? version;

  /// True while a `requestPasswordReset` call is in flight.
  final bool passwordResetInFlight;

  /// Outcome of the most recent password-reset request.
  final PasswordResetOutcome passwordResetOutcome;

  /// Human-readable message that accompanies [passwordResetOutcome] — the
  /// success email or the error description.
  final String? passwordResetMessage;

  SettingsState copyWith({
    Object? user = _sentinel,
    bool? isAdmin,
    bool? viewAsUser,
    Object? version = _sentinel,
    bool? passwordResetInFlight,
    PasswordResetOutcome? passwordResetOutcome,
    Object? passwordResetMessage = _sentinel,
  }) {
    return SettingsState(
      user: identical(user, _sentinel) ? this.user : user as User?,
      isAdmin: isAdmin ?? this.isAdmin,
      viewAsUser: viewAsUser ?? this.viewAsUser,
      version: identical(version, _sentinel)
          ? this.version
          : version as String?,
      passwordResetInFlight:
          passwordResetInFlight ?? this.passwordResetInFlight,
      passwordResetOutcome: passwordResetOutcome ?? this.passwordResetOutcome,
      passwordResetMessage: identical(passwordResetMessage, _sentinel)
          ? this.passwordResetMessage
          : passwordResetMessage as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is SettingsState &&
      other.user == user &&
      other.isAdmin == isAdmin &&
      other.viewAsUser == viewAsUser &&
      other.version == version &&
      other.passwordResetInFlight == passwordResetInFlight &&
      other.passwordResetOutcome == passwordResetOutcome &&
      other.passwordResetMessage == passwordResetMessage;

  @override
  int get hashCode => Object.hash(
    user,
    isAdmin,
    viewAsUser,
    version,
    passwordResetInFlight,
    passwordResetOutcome,
    passwordResetMessage,
  );
}
