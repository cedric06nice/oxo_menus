import 'package:oxo_menus/shared/data/models/user_dto.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

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
      areas: _mapAreas(dto.areas),
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

  /// Map junction table items to Area entities
  ///
  /// Each item has shape: {'area_id': {'id': 1, 'name': 'Dining'}}
  static List<Area> _mapAreas(List<Map<String, dynamic>> junctionItems) {
    final areas = <Area>[];
    for (final item in junctionItems) {
      final areaData = item['area_id'];
      if (areaData is Map<String, dynamic> &&
          areaData.containsKey('id') &&
          areaData.containsKey('name')) {
        areas.add(
          Area(
            id: areaData['id'] is int
                ? areaData['id'] as int
                : int.parse(areaData['id'].toString()),
            name: areaData['name'] as String,
          ),
        );
      }
    }
    return areas;
  }

  // ===== Private helper methods =====

  /// Map role string to UserRole enum
  ///
  /// Handles various role name formats from Directus:
  /// - Direct role names: 'admin', 'user'
  /// - Directus role names: 'Administrator', 'Admin'
  /// - UUID strings (unexpanded relations) - defaults to user
  static UserRole _mapRoleToEnum(String role) {
    final normalized = role.toLowerCase().trim();

    // Check if role name contains 'admin' (handles 'admin', 'administrator', etc.)
    if (normalized.contains('admin')) {
      return UserRole.admin;
    }

    // Standard role mappings
    switch (normalized) {
      case 'user':
      case 'standard':
      case 'regular':
        return UserRole.user;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      default:
        // If it looks like a UUID (unexpanded relation), default to user
        // UUIDs are typically 36 characters with hyphens
        if (normalized.length >= 32 && normalized.contains('-')) {
          return UserRole.user;
        }
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
