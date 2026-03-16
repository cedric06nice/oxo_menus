import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

void main() {
  group('connectivityRepositoryProvider', () {
    test('provides a ConnectivityRepository instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(connectivityRepositoryProvider);

      expect(repo, isA<ConnectivityRepository>());
    });
  });
}
