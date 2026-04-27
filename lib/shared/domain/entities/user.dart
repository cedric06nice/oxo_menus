import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Represents a user (admin or regular).
@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? avatar,
    @Default([]) List<Area> areas,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// User role enumeration
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('user')
  user,
}
