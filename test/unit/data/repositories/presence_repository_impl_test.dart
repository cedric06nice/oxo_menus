import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/presence_dto.dart';
import 'package:oxo_menus/data/repositories/presence_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late PresenceRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = PresenceRepositoryImpl(dataSource: mockDataSource);
    registerFallbackValue(PresenceDto({'id': 1}));
  });

  group('PresenceRepositoryImpl', () {
    group('joinMenu', () {
      test('should create a presence entry', () async {
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
    });

    group('leaveMenu', () {
      test('should delete the matching presence entry', () async {
        // First find the entry
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
    });
  });
}
