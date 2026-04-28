import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Immutable state of the home screen.
///
/// Defaults to "no user / not admin / no greeting" — the state shown before
/// the [HomeViewModel] has resolved the current session.
final class HomeState {
  const HomeState({this.user, this.isAdmin = false, this.greeting = ''});

  /// The signed-in user, or `null` for anonymous sessions.
  final User? user;

  /// `true` when the signed-in user has the admin role. Mirrors the
  /// `HomeOverview` snapshot.
  final bool isAdmin;

  /// Human-readable greeting line shown at the top of the screen — derived
  /// from the user's name (or email local-part) and the time of day.
  final String greeting;

  HomeState copyWith({
    Object? user = _sentinel,
    bool? isAdmin,
    String? greeting,
  }) {
    return HomeState(
      user: identical(user, _sentinel) ? this.user : user as User?,
      isAdmin: isAdmin ?? this.isAdmin,
      greeting: greeting ?? this.greeting,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is HomeState &&
      other.user == user &&
      other.isAdmin == isAdmin &&
      other.greeting == greeting;

  @override
  int get hashCode => Object.hash(user, isAdmin, greeting);
}
