import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/collaboration/data/models/presence_dto.dart';

void main() {
  group('PresenceDto', () {
    group('userId', () {
      test('should return UUID when user is a plain string', () {
        final dto = PresenceDto({'id': 1, 'user': 'user-uuid-123'});
        expect(dto.userId, 'user-uuid-123');
      });

      test('should return UUID when user is an expanded Map', () {
        final dto = PresenceDto({
          'id': 2,
          'user': {'id': 'user-uuid-456', 'avatar': 'avatar-uuid-789'},
        });
        expect(dto.userId, 'user-uuid-456');
      });
    });

    group('userAvatar', () {
      test('should return avatar UUID from expanded Map', () {
        final dto = PresenceDto({
          'id': 3,
          'user': {'id': 'user-uuid-456', 'avatar': 'avatar-uuid-789'},
        });
        expect(dto.userAvatar, 'avatar-uuid-789');
      });

      test('should return null when user is a plain string', () {
        final dto = PresenceDto({'id': 4, 'user': 'user-uuid-123'});
        expect(dto.userAvatar, isNull);
      });

      test('should return null when avatar is null in expanded Map', () {
        final dto = PresenceDto({
          'id': 5,
          'user': {'id': 'user-uuid-456', 'avatar': null},
        });
        expect(dto.userAvatar, isNull);
      });
    });

    group('menuId', () {
      test('should return int when menu is a raw int', () {
        final dto = PresenceDto({'id': 6, 'menu': 42});
        expect(dto.menuId, 42);
      });

      test('should return id when menu is an expanded Map', () {
        final dto = PresenceDto({
          'id': 7,
          'menu': {'id': 99},
        });
        expect(dto.menuId, 99);
      });
    });
  });
}
