import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';

import 'fake_menu_subscription_repository.dart';

void main() {
  group('FakeMenuSubscriptionRepository', () {
    late FakeMenuSubscriptionRepository fake;

    setUp(() {
      fake = FakeMenuSubscriptionRepository();
    });

    tearDown(() {
      fake.dispose();
    });

    // -----------------------------------------------------------------------
    // Default state — unset method throws StateError
    // -----------------------------------------------------------------------

    group('default state', () {
      test(
        'should throw StateError when unsubscribe is called without prior subscription',
        () async {
          // Act / Assert — unsubscribe completes silently (no stub needed
          // because it only records the call; this verifies it does not throw)
          await expectLater(fake.unsubscribe(1), completes);
        },
      );

      test(
        'should record the call even when unsubscribe is called without prior subscribeToMenuChanges',
        () async {
          // Act
          await fake.unsubscribe(99);

          // Assert
          expect(fake.unsubscribeCalls, hasLength(1));
          expect(fake.unsubscribeCalls.first.menuId, equals(99));
        },
      );
    });

    // -----------------------------------------------------------------------
    // Call recording
    // -----------------------------------------------------------------------

    group('call recording', () {
      test(
        'should record a SubscribeToMenuChangesCall when subscribeToMenuChanges is called',
        () {
          // Act
          fake.subscribeToMenuChanges(42);

          // Assert
          expect(fake.subscribeCalls, hasLength(1));
          expect(fake.subscribeCalls.first.menuId, equals(42));
        },
      );

      test(
        'should record an UnsubscribeCall with the correct menuId when unsubscribe is called',
        () async {
          // Act
          await fake.unsubscribe(7);

          // Assert
          expect(fake.unsubscribeCalls, hasLength(1));
          expect(fake.unsubscribeCalls.first.menuId, equals(7));
        },
      );

      test(
        'should accumulate calls across multiple distinct menuIds',
        () async {
          // Act
          fake.subscribeToMenuChanges(1);
          fake.subscribeToMenuChanges(2);
          await fake.unsubscribe(1);

          // Assert
          expect(fake.subscribeCalls, hasLength(2));
          expect(fake.unsubscribeCalls, hasLength(1));
        },
      );
    });

    // -----------------------------------------------------------------------
    // Stream delivery via emitChange
    // -----------------------------------------------------------------------

    group('stream delivery', () {
      test('should deliver emitted event to a subscribed listener', () async {
        // Arrange
        final stream = fake.subscribeToMenuChanges(10);
        final event = WidgetChangedEvent(
          eventType: 'create',
          data: {'id': 1},
          ids: null,
        );

        // Act
        final future = stream.first;
        fake.emitChange(10, event);

        // Assert
        final received = await future;
        expect(received, same(event));
      });

      test('should deliver multiple events in emission order', () async {
        // Arrange
        final stream = fake.subscribeToMenuChanges(5);
        final first = WidgetChangedEvent(
          eventType: 'create',
          data: {'id': 1},
          ids: null,
        );
        final second = WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 1},
          ids: null,
        );
        final received = <MenuChangeEvent>[];

        // Act
        final subscription = stream.listen(received.add);
        fake.emitChange(5, first);
        fake.emitChange(5, second);

        // Allow microtasks to propagate
        await Future<void>.delayed(Duration.zero);
        await subscription.cancel();

        // Assert
        expect(received, hasLength(2));
        expect(received[0], same(first));
        expect(received[1], same(second));
      });

      test(
        'should not deliver events emitted for a different menuId',
        () async {
          // Arrange
          final stream = fake.subscribeToMenuChanges(1);
          final received = <MenuChangeEvent>[];
          final subscription = stream.listen(received.add);

          // Act — emit on menu 2, not menu 1
          fake.emitChange(
            2,
            WidgetChangedEvent(eventType: 'create', data: {'id': 9}, ids: null),
          );
          await Future<void>.delayed(Duration.zero);
          await subscription.cancel();

          // Assert
          expect(received, isEmpty);
        },
      );

      test(
        'should allow multiple listeners on the same broadcast stream',
        () async {
          // Arrange
          final stream = fake.subscribeToMenuChanges(3);
          final firstReceived = <MenuChangeEvent>[];
          final secondReceived = <MenuChangeEvent>[];
          final event = WidgetChangedEvent(
            eventType: 'delete',
            data: null,
            ids: [1, 2],
          );

          // Act
          final sub1 = stream.listen(firstReceived.add);
          final sub2 = stream.listen(secondReceived.add);
          fake.emitChange(3, event);
          await Future<void>.delayed(Duration.zero);
          await sub1.cancel();
          await sub2.cancel();

          // Assert
          expect(firstReceived, hasLength(1));
          expect(secondReceived, hasLength(1));
        },
      );

      test('should close the stream when closeStream is called', () async {
        // Arrange
        final stream = fake.subscribeToMenuChanges(6);

        // Act / Assert — stream completes after close
        final doneCompleter = stream.toList();
        fake.closeStream(6);
        final items = await doneCompleter;
        expect(items, isEmpty);
      });
    });
  });
}
