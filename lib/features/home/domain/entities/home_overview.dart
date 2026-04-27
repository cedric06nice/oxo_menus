import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Snapshot of what the home screen needs to render: the signed-in user (or
/// `null` for anonymous sessions) and whether they are an admin.
///
/// Domain value object — owns no behaviour, equality is structural.
final class HomeOverview {
  const HomeOverview({required this.user, required this.isAdmin});

  final User? user;
  final bool isAdmin;

  @override
  bool operator ==(Object other) =>
      other is HomeOverview && other.user == user && other.isAdmin == isAdmin;

  @override
  int get hashCode => Object.hash(user, isAdmin);

  @override
  String toString() => 'HomeOverview(user: $user, isAdmin: $isAdmin)';
}
