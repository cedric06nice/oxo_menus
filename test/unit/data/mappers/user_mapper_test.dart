import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/user_mapper.dart';
import 'package:oxo_menus/data/models/user_dto.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/user.dart';

void main() {
  group('UserMapper', () {
    group('toEntity', () {
      test('should map all core user fields from a fully-populated DTO', () {
        // Arrange
        final dto = UserDto(
          id: 'user-uuid-001',
          email: 'alice@example.com',
          firstName: 'Alice',
          lastName: 'Smith',
          role: 'admin',
          avatar: 'avatar-uuid',
        );

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.id, 'user-uuid-001');
        expect(entity.email, 'alice@example.com');
        expect(entity.firstName, 'Alice');
        expect(entity.lastName, 'Smith');
        expect(entity.role, UserRole.admin);
        expect(entity.avatar, 'avatar-uuid');
      });

      test('should map null firstName to null', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'user');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.firstName, isNull);
      });

      test('should map null lastName to null', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'user');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.lastName, isNull);
      });

      test('should map null avatar to null', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.avatar, isNull);
      });

      test('should map null role to null', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, isNull);
      });

      // ----- Role mapping: admin variants -----
      test('should map role "admin" to UserRole.admin', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'admin');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.admin);
      });

      test('should map role "Admin" (mixed-case) to UserRole.admin', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'Admin');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.admin);
      });

      test('should map role "Administrator" to UserRole.admin', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'Administrator');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.admin);
      });

      test('should map role "ADMINISTRATOR" (all-caps) to UserRole.admin', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'ADMINISTRATOR');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.admin);
      });

      // ----- Role mapping: user variants -----
      test('should map role "user" to UserRole.user', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'user');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.user);
      });

      test('should map role "standard" to UserRole.user', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'standard');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.user);
      });

      test('should map role "regular" to UserRole.user', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'regular');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.user);
      });

      test('should map a UUID role string (unexpanded relation) to UserRole.user', () {
        // Arrange — Directus returns the role UUID when not expanding
        final dto = UserDto(
          id: 'u1',
          email: 'a@b.com',
          role: 'f8205fcc-3816-4a93-9010-76df1a1f4a90',
        );

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.user);
      });

      test('should default unknown role string to UserRole.user', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com', role: 'mystery_role');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.role, UserRole.user);
      });

      // ----- Areas (M2M junction) -----
      test('should map areas from junction table items', () {
        // Arrange
        final dto = UserDto(
          id: 'u1',
          email: 'a@b.com',
          areas: [
            {
              'area_id': {'id': 1, 'name': 'Dining Room'},
            },
            {
              'area_id': {'id': 2, 'name': 'Terrace'},
            },
          ],
        );

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.areas, hasLength(2));
        expect(entity.areas[0].id, 1);
        expect(entity.areas[0].name, 'Dining Room');
        expect(entity.areas[1].id, 2);
        expect(entity.areas[1].name, 'Terrace');
      });

      test('should default areas to empty list when areas field is empty', () {
        // Arrange
        final dto = UserDto(id: 'u1', email: 'a@b.com');

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.areas, isEmpty);
      });

      test('should ignore junction items that have no area_id map', () {
        // Arrange
        final dto = UserDto(
          id: 'u1',
          email: 'a@b.com',
          areas: [
            {'other_key': 'ignored'},
            {
              'area_id': {'id': 5, 'name': 'Bar'},
            },
          ],
        );

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert — only the valid item is mapped
        expect(entity.areas, hasLength(1));
        expect(entity.areas[0].id, 5);
        expect(entity.areas[0].name, 'Bar');
      });

      test('should parse area id as int when stored as int', () {
        // Arrange
        final dto = UserDto(
          id: 'u1',
          email: 'a@b.com',
          areas: [
            {
              'area_id': {'id': 99, 'name': 'VIP'},
            },
          ],
        );

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.areas[0].id, 99);
      });

      test('should parse area id as int when stored as string', () {
        // Arrange
        final dto = UserDto(
          id: 'u1',
          email: 'a@b.com',
          areas: [
            {
              'area_id': {'id': '7', 'name': 'Garden'},
            },
          ],
        );

        // Act
        final entity = UserMapper.toEntity(dto);

        // Assert
        expect(entity.areas[0].id, 7);
      });
    });

    group('toDto', () {
      test('should map all core fields from a User entity', () {
        // Arrange
        const user = User(
          id: 'user-001',
          email: 'bob@example.com',
          firstName: 'Bob',
          lastName: 'Jones',
          role: UserRole.user,
          avatar: 'avatar-id',
        );

        // Act
        final dto = UserMapper.toDto(user);

        // Assert
        expect(dto.id, 'user-001');
        expect(dto.email, 'bob@example.com');
        expect(dto.firstName, 'Bob');
        expect(dto.lastName, 'Jones');
        expect(dto.role, 'user');
        expect(dto.avatar, 'avatar-id');
      });

      test('should serialize UserRole.admin as "admin"', () {
        // Arrange
        const user = User(id: 'u1', email: 'a@b.com', role: UserRole.admin);

        // Act
        final dto = UserMapper.toDto(user);

        // Assert
        expect(dto.role, 'admin');
      });

      test('should serialize UserRole.user as "user"', () {
        // Arrange
        const user = User(id: 'u1', email: 'a@b.com', role: UserRole.user);

        // Act
        final dto = UserMapper.toDto(user);

        // Assert
        expect(dto.role, 'user');
      });

      test('should serialize null role as null', () {
        // Arrange
        const user = User(id: 'u1', email: 'a@b.com');

        // Act
        final dto = UserMapper.toDto(user);

        // Assert
        expect(dto.role, isNull);
      });

      test('should serialize null avatar as null', () {
        // Arrange
        const user = User(id: 'u1', email: 'a@b.com');

        // Act
        final dto = UserMapper.toDto(user);

        // Assert
        expect(dto.avatar, isNull);
      });

      test('should not include areas in the serialized DTO', () {
        // Arrange — areas are read-only (M2M) and not round-tripped
        const user = User(
          id: 'u1',
          email: 'a@b.com',
          areas: [Area(id: 1, name: 'Dining')],
        );

        // Act
        final dto = UserMapper.toDto(user);

        // Assert — areas defaults to empty in the DTO constructor
        expect(dto.areas, isEmpty);
      });
    });
  });
}
