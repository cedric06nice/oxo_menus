import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/user.dart';

/// Builds a [User] with sensible test defaults.
///
/// Defaults to a non-admin user.  For admin tests, pass `role: UserRole.admin`:
/// ```dart
/// final admin = buildUser(role: UserRole.admin, email: 'admin@example.com');
/// ```
User buildUser({
  String id = 'user-1',
  String email = 'test@example.com',
  String? firstName = 'Test',
  String? lastName = 'User',
  UserRole? role = UserRole.user,
  String? avatar,
  List<Area>? areas,
}) {
  return User(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    role: role,
    avatar: avatar,
    areas: areas ?? [],
  );
}

/// Builds an admin [User].
User buildAdminUser({
  String id = 'admin-1',
  String email = 'admin@example.com',
  String? firstName = 'Admin',
  String? lastName = 'User',
  String? avatar,
  List<Area>? areas,
}) {
  return buildUser(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    role: UserRole.admin,
    avatar: avatar,
    areas: areas,
  );
}
