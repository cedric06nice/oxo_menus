import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/features/collaboration/data/repositories/menu_subscription_repository_impl.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';

import '../../../../../fakes/fake_directus_websocket_subscription.dart';
import '../../../../../fakes/reflectable_bootstrap.dart';

void main() {
  late _FakeMenuSubDataSource fakeDataSource;
  late MenuSubscriptionRepositoryImpl repository;

  setUpAll(initializeReflectableForTests);

  setUp(() {
    fakeDataSource = _FakeMenuSubDataSource();
    repository = MenuSubscriptionRepositoryImpl(dataSource: fakeDataSource);
  });

  // ---------------------------------------------------------------------------
  // subscribeToMenuChanges — call-through to data source
  // ---------------------------------------------------------------------------

  group('MenuSubscriptionRepositoryImpl', () {
    group('subscribeToMenuChanges', () {
      test(
        'should call startSubscription on the data source when subscribing',
        () async {
          // Arrange — nothing extra needed

          // Act
          final stream = repository.subscribeToMenuChanges(42);
          final sub = stream.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(fakeDataSource.startSubscriptionCallCount, equals(1));

          await sub.cancel();
        },
      );

      test(
        'should use a UID that encodes the menuId so two menus get distinct UIDs',
        () async {
          // Arrange & Act
          final streamA = repository.subscribeToMenuChanges(1);
          final subA = streamA.listen((_) {});
          final streamB = repository.subscribeToMenuChanges(2);
          final subB = streamB.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Assert — two distinct subscription UIDs were registered
          expect(fakeDataSource.capturedSubscriptions, hasLength(2));
          final uid1 = fakeDataSource.capturedSubscriptions[0].uid;
          final uid2 = fakeDataSource.capturedSubscriptions[1].uid;
          expect(uid1, isNot(equals(uid2)));

          await subA.cancel();
          await subB.cancel();
        },
      );

      test(
        'should emit a WidgetChangedEvent with eventType "create" on a create callback',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub = stream.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitCreate({'id': 1, 'type_key': 'dish', 'index': 0});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(events, hasLength(1));
          final event = events.first as WidgetChangedEvent;
          expect(event.eventType, equals('create'));

          await sub.cancel();
        },
      );

      test(
        'should include the payload data in the WidgetChangedEvent for a create',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub = stream.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitCreate({'id': 7, 'type_key': 'section', 'index': 2});
          await Future<void>.delayed(Duration.zero);

          // Assert
          final event = events.first as WidgetChangedEvent;
          expect(event.data, isNotNull);
          expect(event.data!['id'], equals(7));

          await sub.cancel();
        },
      );

      test(
        'should emit a WidgetChangedEvent with eventType "update" on an update callback',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub = stream.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitUpdate({'id': 1, 'type_key': 'dish', 'index': 2});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(events, hasLength(1));
          final event = events.first as WidgetChangedEvent;
          expect(event.eventType, equals('update'));

          await sub.cancel();
        },
      );

      test(
        'should include the payload data in the WidgetChangedEvent for an update',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub = stream.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitUpdate({'id': 3, 'type_key': 'text', 'index': 1});
          await Future<void>.delayed(Duration.zero);

          // Assert
          final event = events.first as WidgetChangedEvent;
          expect(event.data, isNotNull);
          expect(event.data!['id'], equals(3));

          await sub.cancel();
        },
      );

      test(
        'should emit a WidgetChangedEvent with eventType "delete" on a delete callback',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub = stream.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitDelete({
            'ids': <dynamic>[1, 2],
          });
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(events, hasLength(1));
          final event = events.first as WidgetChangedEvent;
          expect(event.eventType, equals('delete'));

          await sub.cancel();
        },
      );

      test(
        'should include the ids list in the WidgetChangedEvent for a delete',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub = stream.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitDelete({
            'ids': <dynamic>[10, 20, 30],
          });
          await Future<void>.delayed(Duration.zero);

          // Assert
          final event = events.first as WidgetChangedEvent;
          expect(event.ids, equals([10, 20, 30]));

          await sub.cancel();
        },
      );

      test(
        'should set ids to null in WidgetChangedEvent when delete payload has no ids key',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub = stream.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitDelete(<String, dynamic>{});
          await Future<void>.delayed(Duration.zero);

          // Assert
          final event = events.first as WidgetChangedEvent;
          expect(event.ids, isNull);

          await sub.cancel();
        },
      );

      test(
        'should return a broadcast stream that supports multiple simultaneous listeners',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final eventsA = <MenuChangeEvent>[];
          final eventsB = <MenuChangeEvent>[];
          final subA = stream.listen(eventsA.add);
          final subB = stream.listen(eventsB.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitCreate({'id': 1, 'type_key': 'dish', 'index': 0});
          await Future<void>.delayed(Duration.zero);

          // Assert — both listeners received the event
          expect(eventsA, hasLength(1));
          expect(eventsB, hasLength(1));

          await subA.cancel();
          await subB.cancel();
        },
      );

      test(
        'should deliver events from menu 1 only to the stream for menu 1',
        () async {
          // Arrange — subscribe to two different menus
          final stream1 = repository.subscribeToMenuChanges(1);
          final stream2 = repository.subscribeToMenuChanges(2);
          final events1 = <MenuChangeEvent>[];
          final events2 = <MenuChangeEvent>[];
          final sub1 = stream1.listen(events1.add);
          final sub2 = stream2.listen(events2.add);
          await Future<void>.delayed(Duration.zero);

          // The first captured subscription belongs to menu 1
          final fake1 = fakeDataSource.capturedSubscriptions[0];
          final fake2 = fakeDataSource.capturedSubscriptions[1];

          // Act — emit only through the menu-1 subscription
          fake1.emitCreate({'id': 5, 'type_key': 'dish', 'index': 0});
          await Future<void>.delayed(Duration.zero);

          // Assert — menu-2 stream received nothing
          expect(events1, hasLength(1));
          expect(events2, isEmpty);

          // Suppress the unused variable hint for fake2
          expect(fake2, isNotNull);

          await sub1.cancel();
          await sub2.cancel();
        },
      );

      test(
        'should deliver events from menu 2 only to the stream for menu 2',
        () async {
          // Arrange
          final stream1 = repository.subscribeToMenuChanges(1);
          final stream2 = repository.subscribeToMenuChanges(2);
          final events1 = <MenuChangeEvent>[];
          final events2 = <MenuChangeEvent>[];
          final sub1 = stream1.listen(events1.add);
          final sub2 = stream2.listen(events2.add);
          await Future<void>.delayed(Duration.zero);

          final fake2 = fakeDataSource.capturedSubscriptions[1];

          // Act — emit only through the menu-2 subscription
          fake2.emitUpdate({'id': 9, 'type_key': 'text', 'index': 1});
          await Future<void>.delayed(Duration.zero);

          // Assert — menu-1 stream received nothing
          expect(events1, isEmpty);
          expect(events2, hasLength(1));

          await sub1.cancel();
          await sub2.cancel();
        },
      );

      test(
        'should emit multiple events in order when multiple callbacks fire',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <WidgetChangedEvent>[];
          final sub = stream.listen((e) => events.add(e as WidgetChangedEvent));
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act
          fake.emitCreate({'id': 1, 'type_key': 'dish', 'index': 0});
          fake.emitUpdate({'id': 1, 'type_key': 'dish', 'index': 1});
          fake.emitDelete({
            'ids': <dynamic>[1],
          });
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(events, hasLength(3));
          expect(events[0].eventType, equals('create'));
          expect(events[1].eventType, equals('update'));
          expect(events[2].eventType, equals('delete'));

          await sub.cancel();
        },
      );
    });

    // =========================================================================
    // unsubscribe
    // =========================================================================

    group('unsubscribe', () {
      test(
        'should call stopSubscription on the data source after unsubscribing',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final sub = stream.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Act
          await repository.unsubscribe(42);

          // Assert
          expect(fakeDataSource.stopSubscriptionCallCount, equals(1));

          await sub.cancel();
        },
      );

      test(
        'should pass the correct subscription UID when calling stopSubscription',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final sub = stream.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Act
          await repository.unsubscribe(42);

          // Assert — UID encodes the menuId
          expect(fakeDataSource.lastStoppedUid, contains('42'));

          await sub.cancel();
        },
      );

      test(
        'should not call stopSubscription when no subscription exists for menuId',
        () async {
          // Arrange — no subscription was started

          // Act
          await repository.unsubscribe(999);

          // Assert
          expect(fakeDataSource.stopSubscriptionCallCount, equals(0));
        },
      );

      test(
        'should not throw when stopSubscription throws a StateError',
        () async {
          // Arrange
          final throwingDs = _ThrowingStopMenuSubDataSource();
          final repo = MenuSubscriptionRepositoryImpl(dataSource: throwingDs);
          final stream = repo.subscribeToMenuChanges(42);
          final sub = stream.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Act & Assert — must complete without error
          await expectLater(repo.unsubscribe(42), completes);

          await sub.cancel();
        },
      );

      test(
        'should stop delivering events after unsubscribe closes the stream',
        () async {
          // Arrange
          final stream = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub = stream.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          final fake = fakeDataSource.lastCaptured!;

          // Act — emit one event, then unsubscribe, then emit another
          fake.emitCreate({'id': 1, 'type_key': 'dish', 'index': 0});
          await Future<void>.delayed(Duration.zero);
          await repository.unsubscribe(42);
          await Future<void>.delayed(Duration.zero);

          // Assert — only the pre-unsubscribe event was recorded
          expect(events, hasLength(1));

          await sub.cancel();
        },
      );

      test(
        'should only stop the subscription for the given menuId and not other menus',
        () async {
          // Arrange — subscribe two menus
          final stream1 = repository.subscribeToMenuChanges(1);
          final stream2 = repository.subscribeToMenuChanges(2);
          final events2 = <MenuChangeEvent>[];
          final sub1 = stream1.listen((_) {});
          final sub2 = stream2.listen(events2.add);
          await Future<void>.delayed(Duration.zero);

          final fake2 = fakeDataSource.capturedSubscriptions[1];

          // Act — unsubscribe menu 1 only
          await repository.unsubscribe(1);
          await Future<void>.delayed(Duration.zero);

          // Menu 2 stream still works
          fake2.emitCreate({'id': 99, 'type_key': 'dish', 'index': 0});
          await Future<void>.delayed(Duration.zero);

          // Assert — exactly one stopSubscription (for menu 1), menu 2 still active
          expect(fakeDataSource.stopSubscriptionCallCount, equals(1));
          expect(events2, hasLength(1));

          await sub1.cancel();
          await sub2.cancel();
        },
      );

      test(
        'should allow re-subscribe after unsubscribe and receive new events',
        () async {
          // Arrange — subscribe, unsubscribe, then subscribe again
          final stream1 = repository.subscribeToMenuChanges(42);
          final sub1 = stream1.listen((_) {});
          await Future<void>.delayed(Duration.zero);
          await repository.unsubscribe(42);
          await sub1.cancel();

          final stream2 = repository.subscribeToMenuChanges(42);
          final events = <MenuChangeEvent>[];
          final sub2 = stream2.listen(events.add);
          await Future<void>.delayed(Duration.zero);

          // Act — emit via the second subscription's fake
          final fake2 = fakeDataSource.lastCaptured!;
          fake2.emitCreate({'id': 5, 'type_key': 'dish', 'index': 0});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(events, hasLength(1));

          await sub2.cancel();
        },
      );
    });
  });
}

// =============================================================================
// Local fakes
// =============================================================================

/// A minimal fake [DirectusDataSource] that records startSubscription calls
/// and wires up [FakeDirectusWebSocketSubscription] objects so tests can
/// drive WebSocket events.
class _FakeMenuSubDataSource implements DirectusDataSource {
  final List<FakeDirectusWebSocketSubscription> capturedSubscriptions = [];
  int startSubscriptionCallCount = 0;
  int stopSubscriptionCallCount = 0;
  String? lastStoppedUid;
  bool stopShouldThrow = false;

  FakeDirectusWebSocketSubscription? get lastCaptured =>
      capturedSubscriptions.isEmpty ? null : capturedSubscriptions.last;

  @override
  Future<void> startSubscription(
    DirectusWebSocketSubscription subscription,
  ) async {
    startSubscriptionCallCount++;
    // Register a fake sub that re-uses the uid and callbacks the repo wired in.
    final fake = FakeDirectusWebSocketSubscription(uid: subscription.uid);
    fake.onCreate = subscription.onCreate;
    fake.onUpdate = subscription.onUpdate;
    fake.onDelete = subscription.onDelete;
    fake.onError = subscription.onError;
    fake.onDone = subscription.onDone;
    capturedSubscriptions.add(fake);
  }

  @override
  Future<void> stopSubscription(String subscriptionUid) async {
    stopSubscriptionCallCount++;
    lastStoppedUid = subscriptionUid;
  }

  // ---- All other surface methods — never called in these tests ----
  @override
  String? get currentAccessToken => null;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => _notUsed();

  @override
  Future<void> logout() => _notUsed();

  @override
  Future<void> refreshSession() => _notUsed();

  @override
  Future<bool> tryRestoreSession() => _notUsed();

  @override
  Future<Map<String, dynamic>> getCurrentUser() => _notUsed();

  @override
  Future<bool> requestPasswordReset({
    required String email,
    String? resetUrl,
  }) => _notUsed();

  @override
  Future<bool> confirmPasswordReset({
    required String token,
    required String password,
  }) => _notUsed();

  @override
  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) => _notUsed();

  @override
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) => _notUsed();

  @override
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(T newItem) =>
      _notUsed();

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) => _notUsed();

  @override
  Future<void> deleteItem<T extends DirectusItem>(int id) => _notUsed();

  @override
  Future<String> uploadFile(Uint8List bytes, String filename) => _notUsed();

  @override
  Future<String> replaceFile(String fileId, Uint8List bytes, String filename) =>
      _notUsed();

  @override
  Future<List<Map<String, dynamic>>> listFiles({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
  }) => _notUsed();

  @override
  Future<Uint8List> downloadFileBytes(String fileId) => _notUsed();

  Never _notUsed() => throw UnimplementedError('Method not used in this test');
}

/// Variant that throws [StateError] from [stopSubscription] to verify the
/// repository swallows it.
class _ThrowingStopMenuSubDataSource extends _FakeMenuSubDataSource {
  @override
  Future<void> stopSubscription(String subscriptionUid) async {
    stopSubscriptionCallCount++;
    lastStoppedUid = subscriptionUid;
    throw StateError('Cannot add event after closing');
  }
}
