import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import '../../../../fakes/builders/user_builder.dart';

void main() {
  group('UserRole enum', () {
    group('values', () {
      test('should have exactly two cases', () {
        expect(UserRole.values.length, 2);
      });

      test('should include admin case', () {
        expect(UserRole.values, contains(UserRole.admin));
      });

      test('should include user case', () {
        expect(UserRole.values, contains(UserRole.user));
      });
    });

    group('name', () {
      test('should have name "admin" for admin case', () {
        expect(UserRole.admin.name, 'admin');
      });

      test('should have name "user" for user case', () {
        expect(UserRole.user.name, 'user');
      });
    });

    group('equality', () {
      test('should not be equal to a different case', () {
        expect(UserRole.admin, isNot(equals(UserRole.user)));
      });
    });
  });

  group('User', () {
    group('construction', () {
      test(
        'should create user with only required fields when id and email are provided',
        () {
          // Arrange & Act
          const user = User(id: 'u-1', email: 'test@example.com');

          // Assert
          expect(user.id, 'u-1');
          expect(user.email, 'test@example.com');
        },
      );

      test('should default firstName to null when not specified', () {
        // Arrange & Act
        const user = User(id: 'u-1', email: 'test@example.com');

        // Assert
        expect(user.firstName, isNull);
      });

      test('should default lastName to null when not specified', () {
        // Arrange & Act
        const user = User(id: 'u-1', email: 'test@example.com');

        // Assert
        expect(user.lastName, isNull);
      });

      test('should default role to null when not specified', () {
        // Arrange & Act
        const user = User(id: 'u-1', email: 'test@example.com');

        // Assert
        expect(user.role, isNull);
      });

      test('should default avatar to null when not specified', () {
        // Arrange & Act
        const user = User(id: 'u-1', email: 'test@example.com');

        // Assert
        expect(user.avatar, isNull);
      });

      test('should default areas to empty list when not specified', () {
        // Arrange & Act
        const user = User(id: 'u-1', email: 'test@example.com');

        // Assert
        expect(user.areas, isEmpty);
      });

      test('should store all optional fields when fully specified', () {
        // Arrange & Act
        const user = User(
          id: 'u-1',
          email: 'admin@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.admin,
          avatar: 'https://example.com/avatar.jpg',
          areas: [Area(id: 1, name: 'Dining')],
        );

        // Assert
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.role, UserRole.admin);
        expect(user.avatar, 'https://example.com/avatar.jpg');
        expect(user.areas, hasLength(1));
      });

      test('should store a non-empty areas list when areas are provided', () {
        // Arrange & Act
        const user = User(
          id: 'u-1',
          email: 'test@example.com',
          areas: [
            Area(id: 1, name: 'Dining'),
            Area(id: 2, name: 'Bar'),
          ],
        );

        // Assert
        expect(user.areas, hasLength(2));
        expect(user.areas[0].name, 'Dining');
        expect(user.areas[1].name, 'Bar');
      });

      test(
        'should store UserRole.user when role is explicitly set to user',
        () {
          // Arrange & Act
          const user = User(
            id: 'u-1',
            email: 'test@example.com',
            role: UserRole.user,
          );

          // Assert
          expect(user.role, UserRole.user);
        },
      );
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = User(id: 'u-1', email: 'test@example.com');
        const b = User(id: 'u-1', email: 'test@example.com');

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = User(id: 'u-1', email: 'test@example.com');
        const b = User(id: 'u-1', email: 'test@example.com');

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = User(id: 'u-1', email: 'test@example.com');
        const b = User(id: 'u-2', email: 'test@example.com');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when email differs', () {
        // Arrange
        const a = User(id: 'u-1', email: 'a@example.com');
        const b = User(id: 'u-1', email: 'b@example.com');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when role differs', () {
        // Arrange
        const a = User(
          id: 'u-1',
          email: 'test@example.com',
          role: UserRole.admin,
        );
        const b = User(
          id: 'u-1',
          email: 'test@example.com',
          role: UserRole.user,
        );

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test(
        'should update firstName when copyWith is called with a new firstName',
        () {
          // Arrange
          const user = User(id: 'u-1', email: 'test@example.com');

          // Act
          final updated = user.copyWith(firstName: 'Jane');

          // Assert
          expect(updated.firstName, 'Jane');
          expect(updated.id, 'u-1');
        },
      );

      test('should update role when copyWith is called with a new role', () {
        // Arrange
        const user = User(
          id: 'u-1',
          email: 'test@example.com',
          role: UserRole.user,
        );

        // Act
        final updated = user.copyWith(role: UserRole.admin);

        // Assert
        expect(updated.role, UserRole.admin);
      });

      test(
        'should update areas when copyWith is called with a new areas list',
        () {
          // Arrange
          const user = User(id: 'u-1', email: 'test@example.com');

          // Act
          final updated = user.copyWith(
            areas: [const Area(id: 5, name: 'Terrace')],
          );

          // Assert
          expect(updated.areas, hasLength(1));
          expect(updated.areas.first.name, 'Terrace');
        },
      );

      test(
        'should preserve unchanged fields when only firstName is updated',
        () {
          // Arrange
          final user = buildUser(id: 'u-42', email: 'keep@example.com');

          // Act
          final updated = user.copyWith(firstName: 'Updated');

          // Assert
          expect(updated.id, 'u-42');
          expect(updated.email, 'keep@example.com');
        },
      );
    });

    group('collection isolation', () {
      test(
        'should return a new areas list via copyWith so original is not affected',
        () {
          // Arrange
          const user = User(
            id: 'u-1',
            email: 'test@example.com',
            areas: [Area(id: 1, name: 'Dining')],
          );

          // Act
          final updated = user.copyWith(
            areas: [
              const Area(id: 1, name: 'Dining'),
              const Area(id: 2, name: 'Bar'),
            ],
          );

          // Assert
          expect(user.areas, hasLength(1));
          expect(updated.areas, hasLength(2));
        },
      );
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const user = User(id: 'u-1', email: 'test@example.com');

        // Act
        final result = user.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('JSON serialization', () {
      test('should serialize id, email and role to JSON', () {
        // Arrange
        const user = User(
          id: 'u-1',
          email: 'admin@example.com',
          firstName: 'John',
          role: UserRole.admin,
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], 'u-1');
        expect(json['email'], 'admin@example.com');
        expect(json['firstName'], 'John');
        expect(json['role'], 'admin');
      });

      test('should serialize role as "user" for user role', () {
        // Arrange
        const user = User(
          id: 'u-1',
          email: 'test@example.com',
          role: UserRole.user,
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['role'], 'user');
      });

      test('should deserialize user from JSON with correct field values', () {
        // Arrange
        final json = {
          'id': 'u-1',
          'email': 'admin@example.com',
          'firstName': 'John',
          'role': 'admin',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, 'u-1');
        expect(user.email, 'admin@example.com');
        expect(user.firstName, 'John');
        expect(user.role, UserRole.admin);
      });

      test(
        'should round-trip through JSON preserving equality for minimal user',
        () {
          // Arrange
          const original = User(id: 'u-1', email: 'minimal@example.com');

          // Act
          final restored = User.fromJson(original.toJson());

          // Assert
          expect(restored, equals(original));
        },
      );

      test('should serialize a non-empty areas list to JSON as a list', () {
        // Arrange
        const user = User(
          id: 'u-1',
          email: 'test@example.com',
          areas: [
            Area(id: 1, name: 'Dining'),
            Area(id: 2, name: 'Bar'),
          ],
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['areas'], isA<List>());
        expect((json['areas'] as List), hasLength(2));
      });
    });
  });
}
