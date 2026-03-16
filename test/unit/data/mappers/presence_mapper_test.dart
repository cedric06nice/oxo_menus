import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/presence_mapper.dart';
import 'package:oxo_menus/data/models/presence_dto.dart';

void main() {
  group('PresenceMapper', () {
    test('should map userName from expanded user with first and last name', () {
      final dto = PresenceDto({
        'id': 1,
        'user': {'id': 'user-abc', 'first_name': 'John', 'last_name': 'Doe'},
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.id, 1);
      expect(entity.userId, 'user-abc');
      expect(entity.menuId, 42);
      expect(entity.userName, 'John Doe');
      expect(entity.userAvatar, isNull);
    });

    test('should map userName from expanded user with first name only', () {
      final dto = PresenceDto({
        'id': 2,
        'user': {'id': 'user-abc', 'first_name': 'Alice'},
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.userName, 'Alice');
    });

    test('should map userName from expanded user with last name only', () {
      final dto = PresenceDto({
        'id': 3,
        'user': {'id': 'user-abc', 'last_name': 'Baker'},
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.userName, 'Baker');
    });

    test('should map userName as null when expanded user has no names', () {
      final dto = PresenceDto({
        'id': 4,
        'user': {'id': 'user-abc'},
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.userName, isNull);
    });

    test(
      'should map userName as null when user is a plain string and no user_name field',
      () {
        final dto = PresenceDto({
          'id': 5,
          'user': 'user-abc',
          'menu': 42,
          'last_seen': '2025-01-15T10:30:00.000Z',
        });

        final entity = PresenceMapper.toEntity(dto);

        expect(entity.userName, isNull);
      },
    );

    test('should fall back to user_name field when user is a plain string', () {
      final dto = PresenceDto({
        'id': 8,
        'user': 'user-abc',
        'user_name': 'John Doe',
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.userName, 'John Doe');
    });

    test('should map userAvatar from expanded user Map', () {
      final dto = PresenceDto({
        'id': 6,
        'user': {
          'id': 'user-uuid-456',
          'avatar': 'avatar-uuid-789',
          'first_name': 'Alice',
          'last_name': 'Baker',
        },
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.userId, 'user-uuid-456');
      expect(entity.userAvatar, 'avatar-uuid-789');
      expect(entity.userName, 'Alice Baker');
    });

    test(
      'should map userAvatar as null when user is a plain string and no user_avatar field',
      () {
        final dto = PresenceDto({
          'id': 7,
          'user': 'user-abc',
          'menu': 42,
          'last_seen': '2025-01-15T10:30:00.000Z',
        });

        final entity = PresenceMapper.toEntity(dto);

        expect(entity.userAvatar, isNull);
      },
    );

    test(
      'should fall back to user_avatar field when user is a plain string',
      () {
        final dto = PresenceDto({
          'id': 9,
          'user': 'user-abc',
          'user_avatar': 'avatar-uuid-123',
          'menu': 42,
          'last_seen': '2025-01-15T10:30:00.000Z',
        });

        final entity = PresenceMapper.toEntity(dto);

        expect(entity.userAvatar, 'avatar-uuid-123');
      },
    );
  });
}
