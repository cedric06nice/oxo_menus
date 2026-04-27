import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

void main() {
  group('connectivityRepositoryProvider', () {
    test('should provide a ConnectivityRepository instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(connectivityRepositoryProvider);

      expect(repo, isA<ConnectivityRepository>());
    });

    test('should return the same instance on multiple reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo1 = container.read(connectivityRepositoryProvider);
      final repo2 = container.read(connectivityRepositoryProvider);

      expect(identical(repo1, repo2), isTrue);
    });

    test('should allow overriding with a custom implementation', () {
      final container = ProviderContainer(
        overrides: [
          connectivityRepositoryProvider.overrideWithValue(
            _StubConnectivityRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(connectivityRepositoryProvider);

      expect(repo, isA<_StubConnectivityRepository>());
    });
  });
}

class _StubConnectivityRepository implements ConnectivityRepository {
  @override
  Stream<ConnectivityStatus> watchConnectivity() => const Stream.empty();

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}
