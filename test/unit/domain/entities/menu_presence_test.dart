import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';

void main() {
  group('MenuPresence', () {
    group('construction', () {
      test('should create presence with correct required fields when all required fields are provided', () {
        // Arrange
        final lastSeen = DateTime(2025, 1, 15, 10, 30);

        // Act
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 42,
          lastSeen: lastSeen,
        );

        // Assert
        expect(presence.id, 1);
        expect(presence.userId, 'user-abc');
        expect(presence.menuId, 42);
        expect(presence.lastSeen, lastSeen);
      });

      test('should default userName to null when not specified', () {
        // Arrange & Act
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 1,
          lastSeen: DateTime(2025, 1, 15),
        );

        // Assert
        expect(presence.userName, isNull);
      });

      test('should default userAvatar to null when not specified', () {
        // Arrange & Act
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 1,
          lastSeen: DateTime(2025, 1, 15),
        );

        // Assert
        expect(presence.userAvatar, isNull);
      });

      test('should store userName when userName is provided', () {
        // Arrange & Act
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 42,
          lastSeen: DateTime(2025, 1, 15),
          userName: 'John Doe',
        );

        // Assert
        expect(presence.userName, 'John Doe');
      });

      test('should store userAvatar when userAvatar is provided', () {
        // Arrange & Act
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 42,
          lastSeen: DateTime(2025, 1, 15),
          userAvatar: 'avatar-uuid-123',
        );

        // Assert
        expect(presence.userAvatar, 'avatar-uuid-123');
      });

      test('should store all fields when fully specified', () {
        // Arrange
        final lastSeen = DateTime(2025, 6, 1, 12, 0);

        // Act
        final presence = MenuPresence(
          id: 7,
          userId: 'user-xyz',
          menuId: 99,
          lastSeen: lastSeen,
          userName: 'Jane Smith',
          userAvatar: 'avatar-abc',
        );

        // Assert
        expect(presence.id, 7);
        expect(presence.userId, 'user-xyz');
        expect(presence.menuId, 99);
        expect(presence.lastSeen, lastSeen);
        expect(presence.userName, 'Jane Smith');
        expect(presence.userAvatar, 'avatar-abc');
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        final date = DateTime(2025, 1, 15);
        final a = MenuPresence(id: 1, userId: 'u-1', menuId: 10, lastSeen: date);
        final b = MenuPresence(id: 1, userId: 'u-1', menuId: 10, lastSeen: date);

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        final date = DateTime(2025, 1, 15);
        final a = MenuPresence(id: 1, userId: 'u-1', menuId: 10, lastSeen: date);
        final b = MenuPresence(id: 1, userId: 'u-1', menuId: 10, lastSeen: date);

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when userId differs', () {
        // Arrange
        final date = DateTime(2025, 1, 15);
        final a = MenuPresence(id: 1, userId: 'u-1', menuId: 10, lastSeen: date);
        final b = MenuPresence(id: 1, userId: 'u-2', menuId: 10, lastSeen: date);

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when menuId differs', () {
        // Arrange
        final date = DateTime(2025, 1, 15);
        final a = MenuPresence(id: 1, userId: 'u-1', menuId: 10, lastSeen: date);
        final b = MenuPresence(id: 1, userId: 'u-1', menuId: 20, lastSeen: date);

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when lastSeen differs', () {
        // Arrange
        final a = MenuPresence(
          id: 1,
          userId: 'u-1',
          menuId: 10,
          lastSeen: DateTime(2025, 1, 15, 10, 0),
        );
        final b = MenuPresence(
          id: 1,
          userId: 'u-1',
          menuId: 10,
          lastSeen: DateTime(2025, 1, 15, 11, 0),
        );

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update lastSeen when copyWith is called with a new lastSeen value', () {
        // Arrange
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 42,
          lastSeen: DateTime(2025, 1, 15),
        );

        // Act
        final updated = presence.copyWith(lastSeen: DateTime(2025, 1, 15, 11, 0));

        // Assert
        expect(updated.lastSeen, DateTime(2025, 1, 15, 11, 0));
        expect(updated.userId, 'user-abc');
      });

      test('should update userName when copyWith is called with a new userName', () {
        // Arrange
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 42,
          lastSeen: DateTime(2025, 1, 15),
        );

        // Act
        final updated = presence.copyWith(userName: 'Alice');

        // Assert
        expect(updated.userName, 'Alice');
        expect(updated.userId, 'user-abc');
      });

      test('should update userAvatar when copyWith is called with a new userAvatar', () {
        // Arrange
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 42,
          lastSeen: DateTime(2025, 1, 15),
        );

        // Act
        final updated = presence.copyWith(userAvatar: 'new-avatar-id');

        // Assert
        expect(updated.userAvatar, 'new-avatar-id');
      });

      test('should preserve unchanged fields when only lastSeen is updated', () {
        // Arrange
        final presence = MenuPresence(
          id: 5,
          userId: 'u-xyz',
          menuId: 99,
          lastSeen: DateTime(2025, 1, 1),
          userName: 'Bob',
        );

        // Act
        final updated = presence.copyWith(lastSeen: DateTime(2025, 1, 2));

        // Assert
        expect(updated.id, 5);
        expect(updated.userId, 'u-xyz');
        expect(updated.menuId, 99);
        expect(updated.userName, 'Bob');
      });
    });

    group('JSON serialization', () {
      test('should serialize required fields to JSON', () {
        // Arrange
        final lastSeen = DateTime.utc(2025, 1, 15, 10, 30);
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 42,
          lastSeen: lastSeen,
        );

        // Act
        final json = presence.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['userId'], 'user-abc');
        expect(json['menuId'], 42);
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        final lastSeen = DateTime.utc(2025, 6, 1, 12, 0);
        final original = MenuPresence(
          id: 7,
          userId: 'user-xyz',
          menuId: 99,
          lastSeen: lastSeen,
          userName: 'Jane',
          userAvatar: 'avatar-1',
        );

        // Act
        final restored = MenuPresence.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        final presence = MenuPresence(
          id: 1,
          userId: 'user-abc',
          menuId: 1,
          lastSeen: DateTime(2025, 1, 15),
        );

        // Act
        final result = presence.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });
  });
}
