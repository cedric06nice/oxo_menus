import 'package:flutter_test/flutter_test.dart';

import 'fake_directus_websocket_subscription.dart';

void main() {
  group('FakeDirectusWebSocketSubscription', () {
    late FakeDirectusWebSocketSubscription fake;

    setUp(() {
      fake = FakeDirectusWebSocketSubscription(uid: 'test-uid');
    });

    group('construction', () {
      test('should use the given uid', () {
        // Assert
        expect(fake.uid, equals('test-uid'));
      });

      test('should use default uid when none is provided', () {
        // Act
        final defaultFake = FakeDirectusWebSocketSubscription();

        // Assert
        expect(defaultFake.uid, equals('fake-subscription-uid'));
      });

      test('should start with all callbacks as null', () {
        // Assert
        expect(fake.onCreate, isNull);
        expect(fake.onUpdate, isNull);
        expect(fake.onDelete, isNull);
        expect(fake.onError, isNull);
        expect(fake.onDone, isNull);
      });
    });

    group('emitCreate()', () {
      test('should invoke the onCreate callback with the given data', () {
        // Arrange
        Map<String, dynamic>? received;
        fake.onCreate = (data) {
          received = data;
          return null;
        };

        // Act
        fake.emitCreate({'id': 1, 'type_key': 'dish'});

        // Assert
        expect(received, equals({'id': 1, 'type_key': 'dish'}));
      });

      test('should increment onCreateCallCount', () {
        // Arrange
        fake.onCreate = (_) => null;

        // Act
        fake.emitCreate({'id': 1});
        fake.emitCreate({'id': 2});

        // Assert
        expect(fake.onCreateCallCount, equals(2));
      });

      test('should not throw when onCreate is null', () {
        // No callback wired — should complete silently
        expect(() => fake.emitCreate({'id': 1}), returnsNormally);
      });

      test('should still increment onCreateCallCount even when onCreate is null', () {
        // Act
        fake.emitCreate({});

        // Assert
        expect(fake.onCreateCallCount, equals(1));
      });
    });

    group('emitUpdate()', () {
      test('should invoke the onUpdate callback with the given data', () {
        // Arrange
        Map<String, dynamic>? received;
        fake.onUpdate = (data) {
          received = data;
          return null;
        };

        // Act
        fake.emitUpdate({'id': 5, 'props': {}});

        // Assert
        expect(received, equals({'id': 5, 'props': {}}));
      });

      test('should increment onUpdateCallCount', () {
        // Arrange
        fake.onUpdate = (_) => null;

        // Act
        fake.emitUpdate({});

        // Assert
        expect(fake.onUpdateCallCount, equals(1));
      });
    });

    group('emitDelete()', () {
      test('should invoke the onDelete callback with the given data', () {
        // Arrange
        Map<String, dynamic>? received;
        fake.onDelete = (data) {
          received = data;
          return null;
        };

        // Act
        fake.emitDelete({'id': 99});

        // Assert
        expect(received, equals({'id': 99}));
      });

      test('should increment onDeleteCallCount', () {
        // Act
        fake.emitDelete({});

        // Assert
        expect(fake.onDeleteCallCount, equals(1));
      });
    });

    group('emitError()', () {
      test('should invoke the onError callback', () {
        // Arrange
        dynamic receivedError;
        fake.onError = (error) {
          receivedError = error;
        };

        // Act
        fake.emitError('socket closed');

        // Assert
        expect(receivedError, equals('socket closed'));
      });

      test('should increment onErrorCallCount', () {
        // Act
        fake.emitError('timeout');

        // Assert
        expect(fake.onErrorCallCount, equals(1));
      });
    });

    group('emitDone()', () {
      test('should invoke the onDone callback', () {
        // Arrange
        var doneCalled = false;
        fake.onDone = () {
          doneCalled = true;
        };

        // Act
        fake.emitDone();

        // Assert
        expect(doneCalled, isTrue);
      });

      test('should increment onDoneCallCount', () {
        // Act
        fake.emitDone();

        // Assert
        expect(fake.onDoneCallCount, equals(1));
      });
    });

    group('reflectable members throw UnimplementedError', () {
      test('should throw UnimplementedError when specificClass is accessed', () {
        // Act / Assert
        expect(() => fake.specificClass, throwsA(isA<UnimplementedError>()));
      });

      test('should throw UnimplementedError when collectionMetadata is accessed', () {
        // Act / Assert
        expect(() => fake.collectionMetadata, throwsA(isA<UnimplementedError>()));
      });
    });
  });
}
