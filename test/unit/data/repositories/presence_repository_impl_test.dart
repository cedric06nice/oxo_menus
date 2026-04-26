import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/presence_dto.dart';
import 'package:oxo_menus/data/repositories/presence_repository_impl.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';

import '../../../fakes/fake_directus_websocket_subscription.dart';
import '../../../fakes/reflectable_bootstrap.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal presence JSON for a given [id] and [userId], joined to [menuId].
Map<String, dynamic> _presenceJson({
  required int id,
  required String userId,
  required int menuId,
  String lastSeen = '2025-01-15T10:30:00.000Z',
  String? userName,
  String? userAvatar,
}) {
  final json = <String, dynamic>{
    'id': id,
    'user': userId,
    'menu': menuId,
    'last_seen': lastSeen,
  };
  if (userName != null) json['user_name'] = userName;
  if (userAvatar != null) json['user_avatar'] = userAvatar;
  return json;
}

void main() {
  late _FakePresenceDataSource fakeDataSource;
  late PresenceRepositoryImpl repository;

  setUpAll(initializeReflectableForTests);

  setUp(() {
    fakeDataSource = _FakePresenceDataSource();
    repository = PresenceRepositoryImpl(dataSource: fakeDataSource);
  });

  FakeDirectusWebSocketSubscription capturedSubscription() =>
      fakeDataSource.capturedSubscriptions.last;

  // ==========================================================================
  // joinMenu
  // ==========================================================================

  group('PresenceRepositoryImpl', () {
    group('joinMenu', () {
      test(
        'should return Success when the data source creates the entry successfully',
        () async {
          // Arrange
          fakeDataSource
            ..getItemsResult = []
            ..createItemResult = _presenceJson(
              id: 1,
              userId: 'user-abc',
              menuId: 42,
            );

          // Act
          final result = await repository.joinMenu(42, 'user-abc');

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test('should call createItem exactly once when joining a menu', () async {
        // Arrange
        fakeDataSource
          ..getItemsResult = []
          ..createItemResult = _presenceJson(
            id: 1,
            userId: 'user-abc',
            menuId: 42,
          );

        // Act
        await repository.joinMenu(42, 'user-abc');

        // Assert
        expect(fakeDataSource.createItemCallCount, equals(1));
      });

      test(
        'should delete all existing entries for the user before creating a new one',
        () async {
          // Arrange — user already has two entries on different menus
          fakeDataSource
            ..getItemsResult = [
              _presenceJson(id: 10, userId: 'user-abc', menuId: 1),
              _presenceJson(id: 20, userId: 'user-abc', menuId: 99),
            ]
            ..createItemResult = _presenceJson(
              id: 1,
              userId: 'user-abc',
              menuId: 42,
            );

          // Act
          await repository.joinMenu(42, 'user-abc');

          // Assert — both stale entries were deleted
          expect(fakeDataSource.deletedIds, containsAll([10, 20]));
        },
      );

      test(
        'should query with a user-only filter when looking up existing entries',
        () async {
          // Arrange
          fakeDataSource
            ..getItemsResult = []
            ..createItemResult = _presenceJson(
              id: 1,
              userId: 'user-abc',
              menuId: 42,
            );

          // Act
          await repository.joinMenu(42, 'user-abc');

          // Assert — filter is user-scoped, not menu-scoped
          final filter = fakeDataSource.lastGetItemsFilter!;
          expect(filter, containsPair('user', {'_eq': 'user-abc'}));
          expect(filter.containsKey('menu'), isFalse);
        },
      );

      test('should store userName in the created DTO when provided', () async {
        // Arrange
        fakeDataSource
          ..getItemsResult = []
          ..createItemResult = _presenceJson(
            id: 1,
            userId: 'user-abc',
            menuId: 42,
            userName: 'Alice',
          );

        // Act
        await repository.joinMenu(42, 'user-abc', userName: 'Alice');

        // Assert
        final dto = fakeDataSource.lastCreatedItem as PresenceDto;
        expect(dto.userName, equals('Alice'));
      });

      test(
        'should store userAvatar in the created DTO when provided',
        () async {
          // Arrange
          fakeDataSource
            ..getItemsResult = []
            ..createItemResult = _presenceJson(
              id: 1,
              userId: 'user-abc',
              menuId: 42,
              userAvatar: 'avatar-xyz',
            );

          // Act
          await repository.joinMenu(42, 'user-abc', userAvatar: 'avatar-xyz');

          // Assert
          final dto = fakeDataSource.lastCreatedItem as PresenceDto;
          expect(dto.userAvatar, equals('avatar-xyz'));
        },
      );

      test(
        'should return Failure wrapping a DomainError when getItems throws',
        () async {
          // Arrange
          fakeDataSource.getItemsError = Exception('network failure');

          // Act
          final result = await repository.joinMenu(42, 'user-abc');

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.errorOrNull, isA<DomainError>());
        },
      );

      test(
        'should return Failure when createItem throws after successfully fetching',
        () async {
          // Arrange
          fakeDataSource
            ..getItemsResult = []
            ..createItemError = Exception('write failed');

          // Act
          final result = await repository.joinMenu(42, 'user-abc');

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.errorOrNull, isA<DomainError>());
        },
      );
    });

    // ========================================================================
    // leaveMenu
    // ========================================================================

    group('leaveMenu', () {
      test(
        'should return Success when the presence entry is deleted',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(id: 5, userId: 'user-abc', menuId: 42),
          ];

          // Act
          final result = await repository.leaveMenu(42, 'user-abc');

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test(
        'should call deleteItem with the id of the matching presence entry',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(id: 5, userId: 'user-abc', menuId: 42),
          ];

          // Act
          await repository.leaveMenu(42, 'user-abc');

          // Assert
          expect(fakeDataSource.deletedIds, equals([5]));
        },
      );

      test(
        'should query with both menuId and userId filters when looking up the entry',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];

          // Act
          await repository.leaveMenu(42, 'user-abc');

          // Assert
          final filter = fakeDataSource.lastGetItemsFilter!;
          expect(filter, containsPair('menu', {'_eq': 42}));
          expect(filter, containsPair('user', {'_eq': 'user-abc'}));
        },
      );

      test(
        'should return Success with no delete call when no presence entry exists',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];

          // Act
          final result = await repository.leaveMenu(42, 'user-abc');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(fakeDataSource.deletedIds, isEmpty);
        },
      );

      test(
        'should delete all matching entries when multiple presence rows exist for the same user-menu pair',
        () async {
          // Arrange — two duplicate rows (shouldn't happen normally, but must handle)
          fakeDataSource.getItemsResult = [
            _presenceJson(id: 5, userId: 'user-abc', menuId: 42),
            _presenceJson(id: 6, userId: 'user-abc', menuId: 42),
          ];

          // Act
          await repository.leaveMenu(42, 'user-abc');

          // Assert
          expect(fakeDataSource.deletedIds, hasLength(2));
        },
      );

      test('should return Failure when the data source throws', () async {
        // Arrange
        fakeDataSource.getItemsError = Exception('server error');

        // Act
        final result = await repository.leaveMenu(42, 'user-abc');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.errorOrNull, isA<DomainError>());
      });
    });

    // ========================================================================
    // heartbeat
    // ========================================================================

    group('heartbeat', () {
      test(
        'should return Success when the presence entry is updated',
        () async {
          // Arrange
          fakeDataSource
            ..getItemsResult = [
              _presenceJson(id: 5, userId: 'user-abc', menuId: 42),
            ]
            ..updateItemResult = _presenceJson(
              id: 5,
              userId: 'user-abc',
              menuId: 42,
            );

          // Act
          final result = await repository.heartbeat(42, 'user-abc');

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test(
        'should call updateItem exactly once when a presence entry exists',
        () async {
          // Arrange
          fakeDataSource
            ..getItemsResult = [
              _presenceJson(id: 5, userId: 'user-abc', menuId: 42),
            ]
            ..updateItemResult = _presenceJson(
              id: 5,
              userId: 'user-abc',
              menuId: 42,
            );

          // Act
          await repository.heartbeat(42, 'user-abc');

          // Assert
          expect(fakeDataSource.updateItemCallCount, equals(1));
        },
      );

      test(
        'should not call updateItem when no presence entry exists for the user-menu pair',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];

          // Act
          final result = await repository.heartbeat(42, 'user-abc');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(fakeDataSource.updateItemCallCount, equals(0));
        },
      );

      test(
        'should update only the first entry when multiple rows exist for the user-menu pair',
        () async {
          // Arrange
          fakeDataSource
            ..getItemsResult = [
              _presenceJson(id: 5, userId: 'user-abc', menuId: 42),
              _presenceJson(id: 6, userId: 'user-abc', menuId: 42),
            ]
            ..updateItemResult = _presenceJson(
              id: 5,
              userId: 'user-abc',
              menuId: 42,
            );

          // Act
          await repository.heartbeat(42, 'user-abc');

          // Assert — only the first entry is updated (impl uses entries.first)
          expect(fakeDataSource.updateItemCallCount, equals(1));
        },
      );

      test('should return Failure when getItems throws', () async {
        // Arrange
        fakeDataSource.getItemsError = Exception('connection reset');

        // Act
        final result = await repository.heartbeat(42, 'user-abc');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.errorOrNull, isA<DomainError>());
      });

      test('should return Failure when updateItem throws', () async {
        // Arrange
        fakeDataSource
          ..getItemsResult = [
            _presenceJson(id: 5, userId: 'user-abc', menuId: 42),
          ]
          ..updateItemError = Exception('write failed');

        // Act
        final result = await repository.heartbeat(42, 'user-abc');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.errorOrNull, isA<DomainError>());
      });
    });

    // ========================================================================
    // getActiveUsers
    // ========================================================================

    group('getActiveUsers', () {
      test(
        'should return an empty list when no presence entries exist for the menu',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];

          // Act
          final result = await repository.getActiveUsers(42);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
        },
      );

      test(
        'should return a list of MenuPresence entities mapped from DTO data',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(id: 1, userId: 'user-abc', menuId: 42),
            _presenceJson(id: 2, userId: 'user-xyz', menuId: 42),
          ];

          // Act
          final result = await repository.getActiveUsers(42);

          // Assert
          expect(result.isSuccess, isTrue);
          final presences = result.valueOrNull!;
          expect(presences, hasLength(2));
          expect(
            presences.map((p) => p.userId),
            containsAll(['user-abc', 'user-xyz']),
          );
        },
      );

      test('should preserve userId from the presence JSON', () async {
        // Arrange
        fakeDataSource.getItemsResult = [
          _presenceJson(id: 1, userId: 'user-abc', menuId: 42),
        ];

        // Act
        final result = await repository.getActiveUsers(42);

        // Assert
        expect(result.valueOrNull!.first.userId, equals('user-abc'));
      });

      test('should preserve menuId from the presence JSON', () async {
        // Arrange
        fakeDataSource.getItemsResult = [
          _presenceJson(id: 1, userId: 'user-abc', menuId: 42),
        ];

        // Act
        final result = await repository.getActiveUsers(42);

        // Assert
        expect(result.valueOrNull!.first.menuId, equals(42));
      });

      test(
        'should include userName when present in the presence JSON',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(
              id: 1,
              userId: 'user-abc',
              menuId: 42,
              userName: 'John Doe',
            ),
          ];

          // Act
          final result = await repository.getActiveUsers(42);

          // Assert
          expect(result.valueOrNull!.first.userName, equals('John Doe'));
        },
      );

      test(
        'should include userAvatar when present in the presence JSON',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(
              id: 1,
              userId: 'user-abc',
              menuId: 42,
              userAvatar: 'avatar-123',
            ),
          ];

          // Act
          final result = await repository.getActiveUsers(42);

          // Assert
          expect(result.valueOrNull!.first.userAvatar, equals('avatar-123'));
        },
      );

      test(
        'should request the denormalized display fields in the getItems call',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];

          // Act
          await repository.getActiveUsers(42);

          // Assert
          final fields = fakeDataSource.lastGetItemsFields!;
          expect(
            fields,
            containsAll([
              'user',
              'user_name',
              'user_avatar',
              'menu',
              'last_seen',
            ]),
          );
        },
      );

      test('should filter getItems by the requested menuId', () async {
        // Arrange
        fakeDataSource.getItemsResult = [];

        // Act
        await repository.getActiveUsers(42);

        // Assert
        final filter = fakeDataSource.lastGetItemsFilter!;
        expect(filter, containsPair('menu', {'_eq': 42}));
      });

      test('should return Failure when getItems throws', () async {
        // Arrange
        fakeDataSource.getItemsError = Exception('server error');

        // Act
        final result = await repository.getActiveUsers(42);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.errorOrNull, isA<DomainError>());
      });

      test(
        'should return Failure wrapping an UnknownError when a generic exception is thrown',
        () async {
          // Arrange
          fakeDataSource.getItemsError = Exception('unexpected');

          // Act
          final result = await repository.getActiveUsers(42);

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });

    // ========================================================================
    // watchActiveUsers
    // ========================================================================

    group('watchActiveUsers', () {
      test(
        'should call startSubscription on the data source when watchActiveUsers is called',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];

          // Act
          final stream = repository.watchActiveUsers(42);
          final sub = stream.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(fakeDataSource.startSubscriptionCallCount, equals(1));

          await sub.cancel();
        },
      );

      test(
        'should re-query and emit presences on a WebSocket create event',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(
              id: 1,
              userId: 'user-abc',
              menuId: 42,
              userName: 'Alice',
            ),
          ];

          final stream = repository.watchActiveUsers(42);
          final emissions = <List<MenuPresence>>[];
          final sub = stream.listen(emissions.add);
          await Future<void>.delayed(Duration.zero);
          final fake = capturedSubscription();

          // Act
          fake.emitCreate({'id': 1});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(emissions, hasLength(1));
          expect(emissions.first, hasLength(1));
          expect(emissions.first.first.userName, equals('Alice'));

          await sub.cancel();
        },
      );

      test(
        'should re-query and emit presences on a WebSocket update event',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(id: 1, userId: 'user-abc', menuId: 42),
          ];

          final stream = repository.watchActiveUsers(42);
          final emissions = <List<MenuPresence>>[];
          final sub = stream.listen(emissions.add);
          await Future<void>.delayed(Duration.zero);
          final fake = capturedSubscription();

          // Act
          fake.emitUpdate({'id': 1});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(emissions, hasLength(1));

          await sub.cancel();
        },
      );

      test(
        'should re-query and emit an empty list on a WebSocket delete event',
        () async {
          // Arrange — after delete the user list is empty
          fakeDataSource.getItemsResult = [];

          final stream = repository.watchActiveUsers(42);
          final emissions = <List<MenuPresence>>[];
          final sub = stream.listen(emissions.add);
          await Future<void>.delayed(Duration.zero);
          final fake = capturedSubscription();

          // Act
          fake.emitDelete({
            'ids': <dynamic>[1],
          });
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(emissions, hasLength(1));
          expect(emissions.first, isEmpty);

          await sub.cancel();
        },
      );

      test(
        'should emit an updated list after each of three successive WebSocket events',
        () async {
          // Arrange — sequential responses: 1 user, then 2 users, then 1 user
          final sequentialDs = _SequentialPresenceDataSource([
            [_presenceJson(id: 1, userId: 'user-a', menuId: 42)],
            [
              _presenceJson(id: 1, userId: 'user-a', menuId: 42),
              _presenceJson(id: 2, userId: 'user-b', menuId: 42),
            ],
            [_presenceJson(id: 2, userId: 'user-b', menuId: 42)],
          ]);
          final repo = PresenceRepositoryImpl(dataSource: sequentialDs);

          final stream = repo.watchActiveUsers(42);
          final emissions = <List<MenuPresence>>[];
          final sub = stream.listen(emissions.add);
          await Future<void>.delayed(Duration.zero);

          final fake = sequentialDs.capturedSubscriptions.last;

          // Act
          fake.emitCreate({'id': 1});
          await Future<void>.delayed(Duration.zero);
          fake.emitCreate({'id': 2});
          await Future<void>.delayed(Duration.zero);
          fake.emitDelete({
            'ids': <dynamic>[1],
          });
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(emissions, hasLength(3));
          expect(emissions[0], hasLength(1));
          expect(emissions[1], hasLength(2));
          expect(emissions[2], hasLength(1));

          await sub.cancel();
        },
      );

      test(
        'should use a UID that encodes the menuId for the WebSocket subscription',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];

          // Act
          final stream = repository.watchActiveUsers(99);
          final sub = stream.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(fakeDataSource.capturedSubscriptions.last.uid, contains('99'));

          await sub.cancel();
        },
      );

      test(
        'should use distinct UIDs for two different menus being watched',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];

          // Act
          final streamA = repository.watchActiveUsers(1);
          final streamB = repository.watchActiveUsers(2);
          final subA = streamA.listen((_) {});
          final subB = streamB.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Assert
          final subs = fakeDataSource.capturedSubscriptions;
          expect(subs, hasLength(2));
          expect(subs[0].uid, isNot(equals(subs[1].uid)));

          await subA.cancel();
          await subB.cancel();
        },
      );

      test(
        'should return a broadcast stream that supports multiple concurrent listeners',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(id: 1, userId: 'user-abc', menuId: 42),
          ];

          final stream = repository.watchActiveUsers(42);
          final emissionsA = <List<MenuPresence>>[];
          final emissionsB = <List<MenuPresence>>[];
          final subA = stream.listen(emissionsA.add);
          final subB = stream.listen(emissionsB.add);
          await Future<void>.delayed(Duration.zero);
          final fake = capturedSubscription();

          // Act
          fake.emitCreate({'id': 1});
          await Future<void>.delayed(Duration.zero);

          // Assert — both listeners received the emission
          expect(emissionsA, hasLength(1));
          expect(emissionsB, hasLength(1));

          await subA.cancel();
          await subB.cancel();
        },
      );
    });

    // ========================================================================
    // unsubscribePresence
    // ========================================================================

    group('unsubscribePresence', () {
      test(
        'should call stopSubscription on the data source after unsubscribing',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];
          final stream = repository.watchActiveUsers(42);
          final sub = stream.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Act
          await repository.unsubscribePresence(42);

          // Assert
          expect(fakeDataSource.stopSubscriptionCallCount, equals(1));

          await sub.cancel();
        },
      );

      test('should pass the correct UID to stopSubscription', () async {
        // Arrange
        fakeDataSource.getItemsResult = [];
        final stream = repository.watchActiveUsers(42);
        final sub = stream.listen((_) {});
        await Future<void>.delayed(Duration.zero);

        // Act
        await repository.unsubscribePresence(42);

        // Assert
        expect(fakeDataSource.lastStoppedUid, contains('42'));

        await sub.cancel();
      });

      test(
        'should not call stopSubscription when no subscription exists for menuId',
        () async {
          // Arrange — no watchActiveUsers called

          // Act
          await repository.unsubscribePresence(999);

          // Assert
          expect(fakeDataSource.stopSubscriptionCallCount, equals(0));
        },
      );

      test(
        'should not throw when stopSubscription throws a StateError',
        () async {
          // Arrange
          final throwingDs = _ThrowingStopPresenceDataSource();
          final repo = PresenceRepositoryImpl(dataSource: throwingDs);
          final stream = repo.watchActiveUsers(42);
          final sub = stream.listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Act & Assert — must complete without error
          await expectLater(repo.unsubscribePresence(42), completes);

          await sub.cancel();
        },
      );

      test(
        'should stop delivering events after unsubscribePresence closes the stream',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [];
          final stream = repository.watchActiveUsers(42);
          final emissions = <List<MenuPresence>>[];
          final sub = stream.listen(emissions.add);
          await Future<void>.delayed(Duration.zero);
          final fake = capturedSubscription();

          // Act — emit one event, then unsubscribe, then emit another
          fake.emitCreate({'id': 1});
          await Future<void>.delayed(Duration.zero);
          await repository.unsubscribePresence(42);
          await Future<void>.delayed(Duration.zero);

          // Assert — only the pre-unsubscribe emission was recorded
          expect(emissions, hasLength(1));

          await sub.cancel();
        },
      );

      test(
        'should allow re-subscribe after unsubscribePresence with a fresh stream',
        () async {
          // Arrange
          fakeDataSource.getItemsResult = [
            _presenceJson(id: 1, userId: 'user-abc', menuId: 42),
          ];
          final stream1 = repository.watchActiveUsers(42);
          final sub1 = stream1.listen((_) {});
          await Future<void>.delayed(Duration.zero);
          await repository.unsubscribePresence(42);
          await sub1.cancel();

          final stream2 = repository.watchActiveUsers(42);
          final emissions = <List<MenuPresence>>[];
          final sub2 = stream2.listen(emissions.add);
          await Future<void>.delayed(Duration.zero);

          // Act — emit through the second subscription's fake
          final fake2 = fakeDataSource.capturedSubscriptions.last;
          fake2.emitCreate({'id': 1});
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(emissions, hasLength(1));

          await sub2.cancel();
        },
      );
    });
  });
}

// =============================================================================
// Local fakes implementing DirectusDataSource
// =============================================================================

/// Configurable fake [DirectusDataSource] for presence-related tests.
///
/// Tests configure responses via the `*Result` / `*Error` fields before acting.
class _FakePresenceDataSource implements DirectusDataSource {
  // --- getItems ---
  List<Map<String, dynamic>>? getItemsResult;
  Object? getItemsError;
  Map<String, dynamic>? lastGetItemsFilter;
  List<String>? lastGetItemsFields;

  // --- createItem ---
  Map<String, dynamic>? createItemResult;
  Object? createItemError;
  int createItemCallCount = 0;
  DirectusItem? lastCreatedItem;

  // --- updateItem ---
  Map<String, dynamic>? updateItemResult;
  Object? updateItemError;
  int updateItemCallCount = 0;

  // --- deleteItem ---
  final List<int> deletedIds = [];

  // --- startSubscription ---
  final List<FakeDirectusWebSocketSubscription> capturedSubscriptions = [];
  int startSubscriptionCallCount = 0;

  // --- stopSubscription ---
  int stopSubscriptionCallCount = 0;
  String? lastStoppedUid;

  @override
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    lastGetItemsFilter = filter;
    lastGetItemsFields = fields;
    if (getItemsError != null) throw getItemsError!;
    if (getItemsResult != null) return getItemsResult!;
    throw StateError('No getItemsResult configured');
  }

  @override
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async {
    createItemCallCount++;
    lastCreatedItem = newItem;
    if (createItemError != null) throw createItemError!;
    if (createItemResult != null) return createItemResult!;
    throw StateError('No createItemResult configured');
  }

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async {
    updateItemCallCount++;
    if (updateItemError != null) throw updateItemError!;
    if (updateItemResult != null) return updateItemResult!;
    throw StateError('No updateItemResult configured');
  }

  @override
  Future<void> deleteItem<T extends DirectusItem>(int id) async {
    deletedIds.add(id);
  }

  @override
  Future<void> startSubscription(
    DirectusWebSocketSubscription subscription,
  ) async {
    startSubscriptionCallCount++;
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

  // ---- Unused surface ----
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

/// Data source variant that serves successive [getItemsResult] responses,
/// one per call.  Used for multi-event watchActiveUsers tests.
class _SequentialPresenceDataSource extends _FakePresenceDataSource {
  final List<List<Map<String, dynamic>>> _responses;
  int _index = 0;

  _SequentialPresenceDataSource(this._responses);

  @override
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    lastGetItemsFilter = filter;
    lastGetItemsFields = fields;
    if (_index < _responses.length) {
      final result = _responses[_index];
      _index++;
      return result;
    }
    return <Map<String, dynamic>>[];
  }
}

/// Variant that throws [StateError] from [stopSubscription], used to verify
/// that [PresenceRepositoryImpl.unsubscribePresence] swallows it gracefully.
class _ThrowingStopPresenceDataSource extends _FakePresenceDataSource {
  @override
  Future<void> stopSubscription(String subscriptionUid) async {
    stopSubscriptionCallCount++;
    lastStoppedUid = subscriptionUid;
    throw StateError('Cannot add event after closing');
  }
}
