import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/user_mapper.dart';
import 'package:oxo_menus/data/models/user_dto.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/user.dart';

void main() {
  group('UserMapper', () {
    group('toEntity', () {
      test('should map all fields correctly', () {
        const dto = UserDto(
          id: 'usr-1',
          email: 'chef@oxo.uk',
          firstName: 'Gordon',
          lastName: 'Ramsay',
          role: 'admin',
          avatar: 'avatar-url',
        );

        final user = UserMapper.toEntity(dto);

        expect(user.id, 'usr-1');
        expect(user.email, 'chef@oxo.uk');
        expect(user.firstName, 'Gordon');
        expect(user.lastName, 'Ramsay');
        expect(user.role, UserRole.admin);
        expect(user.avatar, 'avatar-url');
      });

      test('should map null role to null', () {
        const dto = UserDto(id: 'usr-2', email: 'guest@oxo.uk', role: null);

        final user = UserMapper.toEntity(dto);

        expect(user.role, isNull);
      });

      test('should map null optional fields', () {
        const dto = UserDto(id: 'usr-3', email: 'min@oxo.uk');

        final user = UserMapper.toEntity(dto);

        expect(user.firstName, isNull);
        expect(user.lastName, isNull);
        expect(user.avatar, isNull);
        expect(user.role, isNull);
      });

      test('should map areas from M2M junction shape', () {
        final dto = UserDto.fromJson({
          'id': 'usr-1',
          'email': 'chef@oxo.uk',
          'areas': [
            {
              'area_id': {'id': 1, 'name': 'Dining'},
            },
            {
              'area_id': {'id': 2, 'name': 'Bar'},
            },
          ],
        });

        final user = UserMapper.toEntity(dto);

        expect(user.areas, hasLength(2));
        expect(user.areas[0], const Area(id: 1, name: 'Dining'));
        expect(user.areas[1], const Area(id: 2, name: 'Bar'));
      });

      test('should default areas to empty list when not present', () {
        final dto = UserDto.fromJson({'id': 'usr-1', 'email': 'chef@oxo.uk'});

        final user = UserMapper.toEntity(dto);

        expect(user.areas, isEmpty);
      });

      test('should handle null areas field', () {
        final dto = UserDto.fromJson({
          'id': 'usr-1',
          'email': 'chef@oxo.uk',
          'areas': null,
        });

        final user = UserMapper.toEntity(dto);

        expect(user.areas, isEmpty);
      });
    });

    group('toEntity role mapping — prevents admin privilege escalation', () {
      test('should map "admin" to UserRole.admin', () {
        const dto = UserDto(id: '1', email: 'a@b.c', role: 'admin');
        expect(UserMapper.toEntity(dto).role, UserRole.admin);
      });

      test(
        'should map "Administrator" to UserRole.admin (case-insensitive)',
        () {
          const dto = UserDto(id: '1', email: 'a@b.c', role: 'Administrator');
          expect(UserMapper.toEntity(dto).role, UserRole.admin);
        },
      );

      test('should map "ADMIN" to UserRole.admin (uppercase)', () {
        const dto = UserDto(id: '1', email: 'a@b.c', role: 'ADMIN');
        expect(UserMapper.toEntity(dto).role, UserRole.admin);
      });

      test('should map "superadmin" to UserRole.admin (contains admin)', () {
        const dto = UserDto(id: '1', email: 'a@b.c', role: 'superadmin');
        expect(UserMapper.toEntity(dto).role, UserRole.admin);
      });

      test('should map "user" to UserRole.user', () {
        const dto = UserDto(id: '1', email: 'a@b.c', role: 'user');
        expect(UserMapper.toEntity(dto).role, UserRole.user);
      });

      test('should map "standard" to UserRole.user', () {
        const dto = UserDto(id: '1', email: 'a@b.c', role: 'standard');
        expect(UserMapper.toEntity(dto).role, UserRole.user);
      });

      test('should map "regular" to UserRole.user', () {
        const dto = UserDto(id: '1', email: 'a@b.c', role: 'regular');
        expect(UserMapper.toEntity(dto).role, UserRole.user);
      });

      test('should map UUID string (unexpanded relation) to UserRole.user', () {
        const dto = UserDto(
          id: '1',
          email: 'a@b.c',
          role: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        );
        expect(UserMapper.toEntity(dto).role, UserRole.user);
      });

      test(
        'should map unknown role string to UserRole.user (safe default)',
        () {
          const dto = UserDto(id: '1', email: 'a@b.c', role: 'chef');
          expect(UserMapper.toEntity(dto).role, UserRole.user);
        },
      );

      test('should handle whitespace in role string', () {
        const dto = UserDto(id: '1', email: 'a@b.c', role: '  admin  ');
        expect(UserMapper.toEntity(dto).role, UserRole.admin);
      });
    });

    group('toDto', () {
      test('should map admin role to "admin" string', () {
        const user = User(id: '1', email: 'a@b.c', role: UserRole.admin);
        final dto = UserMapper.toDto(user);
        expect(dto.role, 'admin');
      });

      test('should map user role to "user" string', () {
        const user = User(id: '1', email: 'a@b.c', role: UserRole.user);
        final dto = UserMapper.toDto(user);
        expect(dto.role, 'user');
      });

      test('should map null role to null', () {
        const user = User(id: '1', email: 'a@b.c');
        final dto = UserMapper.toDto(user);
        expect(dto.role, isNull);
      });

      test('should map all fields correctly', () {
        const user = User(
          id: 'usr-1',
          email: 'chef@oxo.uk',
          firstName: 'Gordon',
          lastName: 'Ramsay',
          role: UserRole.admin,
          avatar: 'avatar-url',
        );

        final dto = UserMapper.toDto(user);

        expect(dto.id, 'usr-1');
        expect(dto.email, 'chef@oxo.uk');
        expect(dto.firstName, 'Gordon');
        expect(dto.lastName, 'Ramsay');
        expect(dto.role, 'admin');
        expect(dto.avatar, 'avatar-url');
      });
    });

    group('round-trip', () {
      test('should preserve all fields through toEntity then toDto', () {
        const original = UserDto(
          id: 'usr-1',
          email: 'chef@oxo.uk',
          firstName: 'Gordon',
          lastName: 'Ramsay',
          role: 'admin',
          avatar: 'avatar-url',
        );

        final entity = UserMapper.toEntity(original);
        final result = UserMapper.toDto(entity);

        expect(result.id, original.id);
        expect(result.email, original.email);
        expect(result.firstName, original.firstName);
        expect(result.lastName, original.lastName);
        expect(result.role, original.role);
        expect(result.avatar, original.avatar);
      });

      test('should preserve fields through toDto then toEntity', () {
        const original = User(
          id: 'usr-1',
          email: 'chef@oxo.uk',
          firstName: 'Gordon',
          lastName: 'Ramsay',
          role: UserRole.admin,
          avatar: 'avatar-url',
        );

        final dto = UserMapper.toDto(original);
        final result = UserMapper.toEntity(dto);

        expect(result, original);
      });
    });
  });
}
