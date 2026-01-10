import 'package:oxo_menus/data/models/user_dto.dart';
import 'package:oxo_menus/domain/entities/user.dart';

/// Mapper for converting between User entity and UserDto
class UserMapper {
  /// Convert UserDto to User entity
  static User toEntity(UserDto dto) {
    return User(
      id: dto.id,
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      role: dto.role != null ? _mapRoleToEnum(dto.role!) : null,
      avatar: dto.avatar,
    );
  }

  /// Convert User entity to UserDto
  static UserDto toDto(User entity) {
    return UserDto(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      role: entity.role != null ? _mapRoleToString(entity.role!) : null,
      avatar: entity.avatar,
    );
  }

  // ===== Private helper methods =====

  /// Map role string to UserRole enum
  static UserRole _mapRoleToEnum(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.user; // Default fallback
    }
  }

  /// Map UserRole enum to role string
  static String _mapRoleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
    }
  }
}
