import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';

/// Data Transfer Object for User matching Directus users
@freezed
abstract class UserDto with _$UserDto {
  const UserDto._();
  const factory UserDto({
    required String id,
    required String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? role,
    String? avatar,
    @Default([]) List<Map<String, dynamic>> areas,
  }) = _UserDto;

  /// Custom fromJson to handle role field which can be either:
  /// - A string (direct role name)
  /// - A Map (relation to directus_roles table with expanded fields)
  /// - A UUID string (unexpanded relation - just the ID)
  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Extract role name from various formats
    final roleData = json['role'];
    String? roleName;

    if (roleData is String) {
      // Could be role name directly or a UUID
      roleName = roleData;
    } else if (roleData is Map<String, dynamic>) {
      // Role is an expanded relation object
      roleName = roleData['name'] as String?;
    }

    // Parse areas from M2M junction shape: [{'area_id': {'id': 1, 'name': 'Dining'}}, ...]
    final rawAreas = json['areas'];
    final areas = <Map<String, dynamic>>[];
    if (rawAreas is List) {
      for (final item in rawAreas) {
        if (item is Map<String, dynamic>) {
          areas.add(item);
        }
      }
    }

    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: roleName,
      avatar: json['avatar'] as String?,
      areas: areas,
    );
  }

  /// Custom toJson to serialize with snake_case field names
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (role != null) 'role': role,
      if (avatar != null) 'avatar': avatar,
    };
  }
}
