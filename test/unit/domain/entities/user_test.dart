import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('should create User with required fields', () {
      const user = User(
        id: '1',
        email: 'test@example.com',
      );

      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.firstName, null);
      expect(user.lastName, null);
      expect(user.role, null);
      expect(user.avatar, null);
    });

    test('should create User with all fields', () {
      const user = User(
        id: '1',
        email: 'admin@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.admin,
        avatar: 'https://example.com/avatar.jpg',
      );

      expect(user.id, '1');
      expect(user.email, 'admin@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.role, UserRole.admin);
      expect(user.avatar, 'https://example.com/avatar.jpg');
    });

    test('should support copyWith', () {
      const user = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      final updated = user.copyWith(
        firstName: 'Jane',
        role: UserRole.admin,
      );

      expect(updated.id, '1');
      expect(updated.email, 'test@example.com');
      expect(updated.firstName, 'Jane');
      expect(updated.role, UserRole.admin);
    });

    test('should support equality', () {
      const user1 = User(
        id: '1',
        email: 'test@example.com',
      );

      const user2 = User(
        id: '1',
        email: 'test@example.com',
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should serialize to JSON', () {
      const user = User(
        id: '1',
        email: 'admin@example.com',
        firstName: 'John',
        role: UserRole.admin,
      );

      final json = user.toJson();

      expect(json['id'], '1');
      expect(json['email'], 'admin@example.com');
      expect(json['firstName'], 'John');
      expect(json['role'], 'admin');
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'email': 'admin@example.com',
        'firstName': 'John',
        'role': 'admin',
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.email, 'admin@example.com');
      expect(user.firstName, 'John');
      expect(user.role, UserRole.admin);
    });
  });

  group('UserRole', () {
    test('should have correct values', () {
      expect(UserRole.admin.name, 'admin');
      expect(UserRole.user.name, 'user');
    });
  });
}
