import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/collaboration/data/mappers/presence_mapper.dart';
import 'package:oxo_menus/features/collaboration/data/models/presence_dto.dart';

void main() {
  group('PresenceMapper', () {
    group('toEntity', () {
      test(
        'should map all fields from a fully-populated DTO with expanded user map',
        () {
          // Arrange
          final dto = PresenceDto({
            'id': '10',
            'user': {
              'id': 'user-abc-123',
              'first_name': 'Alice',
              'last_name': 'Smith',
              'avatar': 'avatar-uuid',
            },
            'menu': 5,
            'last_seen': '2025-04-01T12:00:00Z',
          });

          // Act
          final entity = PresenceMapper.toEntity(dto);

          // Assert
          expect(entity.id, 10);
          expect(entity.userId, 'user-abc-123');
          expect(entity.menuId, 5);
          expect(entity.lastSeen, DateTime.parse('2025-04-01T12:00:00Z'));
          expect(entity.userName, 'Alice Smith');
          expect(entity.userAvatar, 'avatar-uuid');
        },
      );

      test('should parse string id to int', () {
        // Arrange
        final dto = PresenceDto({
          'id': '77',
          'user': 'user-id',
          'menu': 1,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.id, 77);
      });

      test('should parse a large id value correctly', () {
        // Arrange
        final dto = PresenceDto({
          'id': '12345',
          'user': 'user-id',
          'menu': 1,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.id, 12345);
      });

      test('should map userId from plain string user field', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': 'plain-user-id',
          'menu': 2,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.userId, 'plain-user-id');
      });

      test('should map userId from expanded user map', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': {
            'id': 'expanded-user-id',
            'first_name': 'Bob',
            'last_name': 'Jones',
          },
          'menu': 2,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.userId, 'expanded-user-id');
      });

      test('should default userId to empty string when user is null', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'menu': 2,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.userId, '');
      });

      test('should map menuId from int menu field', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': 'user-1',
          'menu': 99,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.menuId, 99);
      });

      test('should map menuId from expanded menu map', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': 'user-1',
          'menu': {'id': 7},
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.menuId, 7);
      });

      test('should default menuId to 0 when menu is null', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': 'user-1',
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.menuId, 0);
      });

      test(
        'should use a non-null DateTime when lastSeen is null (defaults to now)',
        () {
          // Arrange
          final before = DateTime.now().subtract(const Duration(seconds: 1));
          final dto = PresenceDto({'id': '1', 'user': 'user-1', 'menu': 1});

          // Act
          final entity = PresenceMapper.toEntity(dto);
          final after = DateTime.now().add(const Duration(seconds: 1));

          // Assert
          expect(entity.lastSeen.isAfter(before), true);
          expect(entity.lastSeen.isBefore(after), true);
        },
      );

      test('should build userName from first_name and last_name', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': {'id': 'u1', 'first_name': 'Jane', 'last_name': 'Doe'},
          'menu': 1,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.userName, 'Jane Doe');
      });

      test(
        'should build userName from first_name only when last_name is absent',
        () {
          // Arrange
          final dto = PresenceDto({
            'id': '1',
            'user': {'id': 'u1', 'first_name': 'Alice'},
            'menu': 1,
            'last_seen': '2025-04-01T12:00:00Z',
          });

          // Act
          final entity = PresenceMapper.toEntity(dto);

          // Assert
          expect(entity.userName, 'Alice');
        },
      );

      test('should map null userName when user map has no name fields', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': {'id': 'u1'},
          'menu': 1,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.userName, isNull);
      });

      test('should map userAvatar from expanded user map', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': {'id': 'u1', 'avatar': 'avatar-file-id'},
          'menu': 1,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.userAvatar, 'avatar-file-id');
      });

      test('should map null userAvatar when avatar is absent', () {
        // Arrange
        final dto = PresenceDto({
          'id': '1',
          'user': {'id': 'u1', 'first_name': 'Bob'},
          'menu': 1,
          'last_seen': '2025-04-01T12:00:00Z',
        });

        // Act
        final entity = PresenceMapper.toEntity(dto);

        // Assert
        expect(entity.userAvatar, isNull);
      });
    });
  });
}
