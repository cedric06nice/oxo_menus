import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';

void main() {
  group('MenuPresence', () {
    test('should store all fields', () {
      final now = DateTime(2025, 1, 15, 10, 30);
      final presence = MenuPresence(
        id: 1,
        userId: 'user-abc',
        menuId: 42,
        lastSeen: now,
        userName: 'John Doe',
      );

      expect(presence.id, 1);
      expect(presence.userId, 'user-abc');
      expect(presence.menuId, 42);
      expect(presence.lastSeen, now);
      expect(presence.userName, 'John Doe');
    });

    test('should support copyWith', () {
      final presence = MenuPresence(
        id: 1,
        userId: 'user-abc',
        menuId: 42,
        lastSeen: DateTime(2025, 1, 15),
      );

      final updated = presence.copyWith(lastSeen: DateTime(2025, 1, 15, 11, 0));

      expect(updated.lastSeen, DateTime(2025, 1, 15, 11, 0));
      expect(updated.userId, 'user-abc');
    });

    test('userName should default to null', () {
      final presence = MenuPresence(
        id: 1,
        userId: 'user-abc',
        menuId: 42,
        lastSeen: DateTime(2025, 1, 15),
      );

      expect(presence.userName, isNull);
    });
  });
}
