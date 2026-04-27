import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

import '../../../../../fakes/fake_connectivity_repository.dart';

void main() {
  group('connectivityProvider', () {
    late FakeConnectivityRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeConnectivityRepository();
      container = ProviderContainer(
        overrides: [connectivityRepositoryProvider.overrideWithValue(fakeRepo)],
      );
    });

    tearDown(() async {
      container.dispose();
      await fakeRepo.dispose();
    });

    test('should be a StreamProvider of ConnectivityStatus', () {
      expect(connectivityProvider, isA<StreamProvider<ConnectivityStatus>>());
    });

    test('should call watchConnectivity on the repository', () {
      container.listen(connectivityProvider, (_, _) {});
      expect(fakeRepo.watchCalls, hasLength(1));
    });

    test('should emit online status when repository emits online', () async {
      final values = <ConnectivityStatus?>[];
      container.listen<AsyncValue<ConnectivityStatus>>(
        connectivityProvider,
        (_, next) => values.add(next.value),
      );

      fakeRepo.statusController.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(values, contains(ConnectivityStatus.online));
    });

    test('should emit offline status when repository emits offline', () async {
      final values = <ConnectivityStatus?>[];
      container.listen<AsyncValue<ConnectivityStatus>>(
        connectivityProvider,
        (_, next) => values.add(next.value),
      );

      fakeRepo.statusController.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(values, contains(ConnectivityStatus.offline));
    });

    test('should track multiple status transitions in sequence', () async {
      final values = <ConnectivityStatus?>[];
      container.listen<AsyncValue<ConnectivityStatus>>(
        connectivityProvider,
        (_, next) => values.add(next.value),
      );

      fakeRepo.statusController.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);
      fakeRepo.statusController.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      fakeRepo.statusController.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(values, [
        ConnectivityStatus.online,
        ConnectivityStatus.offline,
        ConnectivityStatus.online,
      ]);
    });

    test('should start in loading state before first emission', () {
      final state = container.read(connectivityProvider);
      expect(state, const AsyncValue<ConnectivityStatus>.loading());
    });
  });
}
