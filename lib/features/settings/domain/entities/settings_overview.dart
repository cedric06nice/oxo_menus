import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Snapshot consumed by the Settings screen.
///
/// Built by `GetSettingsOverviewUseCase` from `AuthGateway` and
/// `AdminViewAsUserGateway`. Carries only what the screen renders:
/// - [user]: the signed-in user, or `null` while auth is initial.
/// - [isAdmin]: whether the user has the `admin` role (raw, ignores
///   the [viewAsUser] toggle so the Settings page can still show the debug
///   section to admins regardless of the toggle).
/// - [viewAsUser]: current value of the admin "view as user" toggle.
final class SettingsOverview {
  const SettingsOverview({
    required this.user,
    required this.isAdmin,
    required this.viewAsUser,
  });

  final User? user;
  final bool isAdmin;
  final bool viewAsUser;

  @override
  bool operator ==(Object other) =>
      other is SettingsOverview &&
      other.user == user &&
      other.isAdmin == isAdmin &&
      other.viewAsUser == viewAsUser;

  @override
  int get hashCode => Object.hash(user, isAdmin, viewAsUser);

  @override
  String toString() =>
      'SettingsOverview(user: $user, isAdmin: $isAdmin, viewAsUser: $viewAsUser)';
}
