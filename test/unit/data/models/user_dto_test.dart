import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/user_dto.dart';

void main() {
  group('UserDto', () {
    group('fromJson', () {
      test('should deserialize from JSON with snake_case field names', () {
        // Arrange
        final json = {
          'id': 'user-1',
          'email': 'test@example.com',
          'first_name': 'John',
          'last_name': 'Doe',
          'role': 'admin',
          'avatar': 'avatar-url',
        };

        // Act
        final dto = UserDto.fromJson(json);

        // Assert
        expect(dto.id, 'user-1');
        expect(dto.email, 'test@example.com');
        expect(dto.firstName, 'John');
        expect(dto.lastName, 'Doe');
        expect(dto.role, 'admin');
        expect(dto.avatar, 'avatar-url');
      });

      test('should deserialize with only required fields', () {
        // Arrange
        final json = {
          'id': 'user-2',
          'email': 'user@example.com',
        };

        // Act
        final dto = UserDto.fromJson(json);

        // Assert
        expect(dto.id, 'user-2');
        expect(dto.email, 'user@example.com');
        expect(dto.firstName, isNull);
        expect(dto.lastName, isNull);
        expect(dto.role, isNull);
        expect(dto.avatar, isNull);
      });

      test('should handle role as expanded relation object', () {
        // Arrange - role is a Directus relation object
        final json = {
          'id': 'user-3',
          'email': 'admin@example.com',
          'first_name': 'Admin',
          'last_name': 'User',
          'role': {
            'id': 'role-uuid-abc',
            'name': 'Administrator',
          },
        };

        // Act
        final dto = UserDto.fromJson(json);

        // Assert
        expect(dto.id, 'user-3');
        expect(dto.email, 'admin@example.com');
        expect(dto.firstName, 'Admin');
        expect(dto.lastName, 'User');
        expect(dto.role, 'Administrator'); // Should extract name from object
      });

      test('should handle role as UUID string (unexpanded relation)', () {
        // Arrange - role is just a UUID (unexpanded relation)
        final json = {
          'id': 'user-4',
          'email': 'user@example.com',
          'role': 'uuid-1234-5678-90ab-cdef',
        };

        // Act
        final dto = UserDto.fromJson(json);

        // Assert
        expect(dto.id, 'user-4');
        expect(dto.email, 'user@example.com');
        expect(dto.role, 'uuid-1234-5678-90ab-cdef'); // UUID string passed through
      });
    });

    group('toJson', () {
      test('should serialize to JSON with snake_case field names', () {
        // Arrange
        const dto = UserDto(
          id: 'user-1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: 'admin',
          avatar: 'avatar-url',
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['id'], 'user-1');
        expect(json['email'], 'test@example.com');
        expect(json['first_name'], 'John');
        expect(json['last_name'], 'Doe');
        expect(json['role'], 'admin');
        expect(json['avatar'], 'avatar-url');
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange
        const dto = UserDto(
          id: 'user-1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
        );

        // Act
        final updated = dto.copyWith(
          firstName: 'Jane',
          role: 'user',
        );

        // Assert
        expect(updated.id, dto.id);
        expect(updated.email, dto.email);
        expect(updated.firstName, 'Jane');
        expect(updated.lastName, dto.lastName);
        expect(updated.role, 'user');
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        // Arrange
        const dto1 = UserDto(
          id: 'user-1',
          email: 'test@example.com',
        );

        const dto2 = UserDto(
          id: 'user-1',
          email: 'test@example.com',
        );

        // Assert
        expect(dto1, equals(dto2));
        expect(dto1.hashCode, equals(dto2.hashCode));
      });
    });
  });
}
