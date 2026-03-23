import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/presence_dto.dart';
import 'package:oxo_menus/data/repositories/presence_repository_impl.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/main.reflectable.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

class _FakeSubscription extends Fake
    implements DirectusWebSocketSubscription<DirectusItem> {}

void main() {
  late PresenceRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUpAll(() {
    initializeReflectable();
  });

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = PresenceRepositoryImpl(dataSource: mockDataSource);
    registerFallbackValue(PresenceDto({'id': 1}));
    registerFallbackValue(_FakeSubscription());
  });

  group('PresenceRepositoryImpl', () {
    group('joinMenu', () {
      test('should create a presence entry', () async {
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => []);
        when(() => mockDataSource.createItem<PresenceDto>(any())).thenAnswer(
          (_) async => {
            'id': 1,
            'user': 'user-abc',
            'menu': 42,
            'last_seen': '2025-01-15T10:30:00.000Z',
          },
        );

        final result = await repository.joinMenu(42, 'user-abc');

        expect(result.isSuccess, isTrue);
        verify(() => mockDataSource.createItem<PresenceDto>(any())).called(1);
      });

      test(
        'should delete all existing entries for the user before creating',
        () async {
          // Two stale entries on different menus
          when(
            () => mockDataSource.getItems<PresenceDto>(
              filter: any(named: 'filter'),
              fields: any(named: 'fields'),
            ),
          ).thenAnswer(
            (_) async => [
              {'id': 10, 'user': 'user-abc', 'menu': 42},
              {'id': 20, 'user': 'user-abc', 'menu': 99},
            ],
          );
          when(
            () => mockDataSource.deleteItem<PresenceDto>(any()),
          ).thenAnswer((_) async {});
          when(() => mockDataSource.createItem<PresenceDto>(any())).thenAnswer(
            (_) async => {
              'id': 1,
              'user': 'user-abc',
              'menu': 42,
              'last_seen': '2025-01-15T10:30:00.000Z',
            },
          );

          final result = await repository.joinMenu(42, 'user-abc');

          expect(result.isSuccess, isTrue);

          // Verify getItems was called with user-only filter
          final captured =
              verify(
                    () => mockDataSource.getItems<PresenceDto>(
                      filter: captureAny(named: 'filter'),
                      fields: any(named: 'fields'),
                    ),
                  ).captured.single
                  as Map<String, dynamic>;
          expect(
            captured,
            equals({
              'user': {'_eq': 'user-abc'},
            }),
          );

          // Verify both stale entries were deleted
          verify(() => mockDataSource.deleteItem<PresenceDto>(10)).called(1);
          verify(() => mockDataSource.deleteItem<PresenceDto>(20)).called(1);

          // Verify createItem was called once
          verify(() => mockDataSource.createItem<PresenceDto>(any())).called(1);
        },
      );

      test('should store user_name and user_avatar when provided', () async {
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => []);
        PresenceDto? capturedDto;
        when(() => mockDataSource.createItem<PresenceDto>(any())).thenAnswer((
          inv,
        ) {
          capturedDto = inv.positionalArguments[0] as PresenceDto;
          return Future.value({
            'id': 1,
            'user': 'user-abc',
            'menu': 42,
            'last_seen': '2025-01-15T10:30:00.000Z',
            'user_name': 'John Doe',
            'user_avatar': 'avatar-123',
          });
        });

        await repository.joinMenu(
          42,
          'user-abc',
          userName: 'John Doe',
          userAvatar: 'avatar-123',
        );

        expect(capturedDto, isNotNull);
        expect(capturedDto!.userName, 'John Doe');
        expect(capturedDto!.userAvatar, 'avatar-123');
      });
    });

    group('leaveMenu', () {
      test('should delete the matching presence entry', () async {
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 5,
              'user': 'user-abc',
              'menu': 42,
              'last_seen': '2025-01-15T10:30:00.000Z',
            },
          ],
        );
        when(
          () => mockDataSource.deleteItem<PresenceDto>(5),
        ).thenAnswer((_) async {});

        final result = await repository.leaveMenu(42, 'user-abc');

        expect(result.isSuccess, isTrue);
        verify(() => mockDataSource.deleteItem<PresenceDto>(5)).called(1);
      });
    });

    group('heartbeat', () {
      test('should update the last_seen timestamp', () async {
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 5,
              'user': 'user-abc',
              'menu': 42,
              'last_seen': '2025-01-15T10:30:00.000Z',
            },
          ],
        );
        when(() => mockDataSource.updateItem<PresenceDto>(any())).thenAnswer(
          (_) async => {
            'id': 5,
            'user': 'user-abc',
            'menu': 42,
            'last_seen': '2025-01-15T10:31:00.000Z',
          },
        );

        final result = await repository.heartbeat(42, 'user-abc');

        expect(result.isSuccess, isTrue);
        verify(() => mockDataSource.updateItem<PresenceDto>(any())).called(1);
      });
    });

    group('getActiveUsers', () {
      test('should return list of active presences for a menu', () async {
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 1,
              'user': 'user-abc',
              'menu': 42,
              'last_seen': '2025-01-15T10:30:00.000Z',
            },
            {
              'id': 2,
              'user': 'user-xyz',
              'menu': 42,
              'last_seen': '2025-01-15T10:29:00.000Z',
            },
          ],
        );

        final result = await repository.getActiveUsers(42);

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, hasLength(2));
        expect(result.valueOrNull?.first.userId, 'user-abc');
        expect(result.valueOrNull?.last.userId, 'user-xyz');
      });

      test('should request user and denormalized display fields', () async {
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => []);

        await repository.getActiveUsers(42);

        final captured =
            verify(
                  () => mockDataSource.getItems<PresenceDto>(
                    filter: any(named: 'filter'),
                    fields: captureAny(named: 'fields'),
                  ),
                ).captured.single
                as List<String>;

        expect(captured, contains('user'));
        expect(captured, contains('user_name'));
        expect(captured, contains('user_avatar'));
        expect(captured, isNot(contains('user.id')));
        expect(captured, isNot(contains('user.first_name')));
        expect(captured, isNot(contains('user.last_name')));
        expect(captured, isNot(contains('user.avatar')));
      });
    });

    group('watchActiveUsers', () {
      test('should start a WebSocket subscription via data source', () async {
        when(
          () => mockDataSource.startSubscription(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => []);

        final stream = repository.watchActiveUsers(42);
        final sub = stream.listen((_) {});

        await Future<void>.delayed(Duration.zero);

        verify(() => mockDataSource.startSubscription(any())).called(1);

        await sub.cancel();
      });

      test('should re-query and emit presences on create event', () async {
        DirectusWebSocketSubscription? capturedSubscription;

        when(() => mockDataSource.startSubscription(any())).thenAnswer((inv) {
          capturedSubscription =
              inv.positionalArguments[0] as DirectusWebSocketSubscription;
          return Future.value();
        });
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer(
          (_) async => [
            {
              'id': 1,
              'user': 'user-abc',
              'user_name': 'John Doe',
              'menu': 42,
              'last_seen': '2025-01-15T10:30:00.000Z',
            },
          ],
        );

        final stream = repository.watchActiveUsers(42);
        final emissions = <List<MenuPresence>>[];
        final sub = stream.listen(emissions.add);

        await Future<void>.delayed(Duration.zero);

        // Simulate a create event
        capturedSubscription!.onCreate!({'id': 1});

        await Future<void>.delayed(Duration.zero);

        expect(emissions, hasLength(1));
        expect(emissions.first, hasLength(1));
        expect(emissions.first.first.userName, 'John Doe');

        await sub.cancel();
      });

      test('should re-query and emit presences on update event', () async {
        DirectusWebSocketSubscription? capturedSubscription;

        when(() => mockDataSource.startSubscription(any())).thenAnswer((inv) {
          capturedSubscription =
              inv.positionalArguments[0] as DirectusWebSocketSubscription;
          return Future.value();
        });
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => []);

        final stream = repository.watchActiveUsers(42);
        final emissions = <List<MenuPresence>>[];
        final sub = stream.listen(emissions.add);

        await Future<void>.delayed(Duration.zero);

        capturedSubscription!.onUpdate!({'id': 1});

        await Future<void>.delayed(Duration.zero);

        expect(emissions, hasLength(1));

        await sub.cancel();
      });

      test('should re-query and emit presences on delete event', () async {
        DirectusWebSocketSubscription? capturedSubscription;

        when(() => mockDataSource.startSubscription(any())).thenAnswer((inv) {
          capturedSubscription =
              inv.positionalArguments[0] as DirectusWebSocketSubscription;
          return Future.value();
        });
        when(
          () => mockDataSource.getItems<PresenceDto>(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
          ),
        ).thenAnswer((_) async => []);

        final stream = repository.watchActiveUsers(42);
        final emissions = <List<MenuPresence>>[];
        final sub = stream.listen(emissions.add);

        await Future<void>.delayed(Duration.zero);

        capturedSubscription!.onDelete!({
          'ids': [1],
        });

        await Future<void>.delayed(Duration.zero);

        expect(emissions, hasLength(1));

        await sub.cancel();
      });

      test('should use PropertyFilter targeting the given menuId', () async {
        DirectusWebSocketSubscription? capturedSubscription;

        when(() => mockDataSource.startSubscription(any())).thenAnswer((inv) {
          capturedSubscription =
              inv.positionalArguments[0] as DirectusWebSocketSubscription;
          return Future.value();
        });

        final stream = repository.watchActiveUsers(42);
        final sub = stream.listen((_) {});

        await Future<void>.delayed(Duration.zero);

        expect(capturedSubscription, isNotNull);
        final filter = capturedSubscription!.filter;
        expect(filter, isNotNull);
        final filterMap = filter!.asMap;
        expect(filterMap, containsPair('menu', {'_eq': 42}));

        await sub.cancel();
      });
    });

    group('unsubscribePresence', () {
      test(
        'should stop the WebSocket subscription for the given menuId',
        () async {
          when(
            () => mockDataSource.startSubscription(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockDataSource.stopSubscription(any()),
          ).thenAnswer((_) async {});

          final stream = repository.watchActiveUsers(42);
          final sub = stream.listen((_) {});

          await Future<void>.delayed(Duration.zero);

          await repository.unsubscribePresence(42);

          verify(() => mockDataSource.stopSubscription(any())).called(1);

          await sub.cancel();
        },
      );

      test(
        'should not throw when stopSubscription throws StateError',
        () async {
          when(
            () => mockDataSource.startSubscription(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockDataSource.stopSubscription(any()),
          ).thenThrow(StateError('Cannot add event after closing'));

          final stream = repository.watchActiveUsers(42);
          final sub = stream.listen((_) {});

          await Future<void>.delayed(Duration.zero);

          await expectLater(repository.unsubscribePresence(42), completes);

          await sub.cancel();
        },
      );

      test(
        'should do nothing if no subscription exists for the menuId',
        () async {
          when(
            () => mockDataSource.stopSubscription(any()),
          ).thenAnswer((_) async {});

          await repository.unsubscribePresence(999);

          verifyNever(() => mockDataSource.stopSubscription(any()));
        },
      );
    });
  });
}
