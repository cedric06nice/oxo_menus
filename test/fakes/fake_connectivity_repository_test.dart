import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';

import 'fake_connectivity_repository.dart';

void main() {
  group('FakeConnectivityRepository', () {
    late FakeConnectivityRepository repo;

    setUp(() {
      repo = FakeConnectivityRepository();
    });

    tearDown(() async {
      await repo.dispose();
    });

    // -----------------------------------------------------------------------
    // watchConnectivity
    // -----------------------------------------------------------------------

    group('watchConnectivity', () {
      test(
        'should return stream that emits online when controller adds online',
        () async {
          final stream = repo.watchConnectivity();
          final future = expectLater(stream, emits(ConnectivityStatus.online));

          repo.statusController.add(ConnectivityStatus.online);

          await future;
        },
      );

      test(
        'should return stream that emits offline when controller adds offline',
        () async {
          final stream = repo.watchConnectivity();
          final future = expectLater(stream, emits(ConnectivityStatus.offline));

          repo.statusController.add(ConnectivityStatus.offline);

          await future;
        },
      );

      test('should emit multiple status changes in order', () async {
        final stream = repo.watchConnectivity();
        final future = expectLater(
          stream,
          emitsInOrder([
            ConnectivityStatus.online,
            ConnectivityStatus.offline,
            ConnectivityStatus.online,
          ]),
        );

        repo.statusController.add(ConnectivityStatus.online);
        repo.statusController.add(ConnectivityStatus.offline);
        repo.statusController.add(ConnectivityStatus.online);

        await future;
      });

      test('should record watchConnectivity call', () {
        repo.watchConnectivity();

        expect(repo.watchCalls.length, equals(1));
      });
    });

    // -----------------------------------------------------------------------
    // checkConnectivity
    // -----------------------------------------------------------------------

    group('checkConnectivity', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.checkConnectivity(), throwsA(isA<StateError>()));
      });

      test('should return online when configured with online', () async {
        repo.whenCheckConnectivity(ConnectivityStatus.online);

        final result = await repo.checkConnectivity();

        expect(result, equals(ConnectivityStatus.online));
      });

      test('should return offline when configured with offline', () async {
        repo.whenCheckConnectivity(ConnectivityStatus.offline);

        final result = await repo.checkConnectivity();

        expect(result, equals(ConnectivityStatus.offline));
      });

      test('should record checkConnectivity call', () async {
        repo.whenCheckConnectivity(ConnectivityStatus.online);

        await repo.checkConnectivity();

        expect(repo.checkCalls.length, equals(1));
      });
    });
  });
}
