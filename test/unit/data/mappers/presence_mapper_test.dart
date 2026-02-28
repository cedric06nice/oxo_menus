import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/presence_mapper.dart';
import 'package:oxo_menus/data/models/presence_dto.dart';

void main() {
  group('PresenceMapper', () {
    test('should map all fields from DTO to entity', () {
      final dto = PresenceDto({
        'id': 1,
        'user': 'user-abc',
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
        'user_name': 'John Doe',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.id, 1);
      expect(entity.userId, 'user-abc');
      expect(entity.menuId, 42);
      expect(entity.userName, 'John Doe');
      expect(entity.userAvatar, isNull);
    });

    test('should map userAvatar from expanded user Map', () {
      final dto = PresenceDto({
        'id': 2,
        'user': {'id': 'user-uuid-456', 'avatar': 'avatar-uuid-789'},
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
        'user_name': 'Alice',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.userId, 'user-uuid-456');
      expect(entity.userAvatar, 'avatar-uuid-789');
    });

    test('should map userAvatar as null when user is a plain string', () {
      final dto = PresenceDto({
        'id': 3,
        'user': 'user-abc',
        'menu': 42,
        'last_seen': '2025-01-15T10:30:00.000Z',
      });

      final entity = PresenceMapper.toEntity(dto);

      expect(entity.userAvatar, isNull);
    });
  });
}
