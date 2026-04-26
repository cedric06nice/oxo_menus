import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

import '../../../../fakes/fake_size_repository.dart';

void main() {
  group('adminSizesProvider', () {
    test('should create an AdminSizesNotifier instance', () {
      final fakeSizeRepository = FakeSizeRepository();
      final container = ProviderContainer(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(adminSizesProvider.notifier);

      expect(notifier, isA<AdminSizesNotifier>());
    });

    test('should return default AdminSizesState on build', () {
      final fakeSizeRepository = FakeSizeRepository();
      final container = ProviderContainer(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(adminSizesProvider);

      expect(state, const AdminSizesState());
    });

    test('should have empty sizes in default state', () {
      final fakeSizeRepository = FakeSizeRepository();
      final container = ProviderContainer(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(adminSizesProvider);

      expect(state.sizes, isEmpty);
    });

    test('should have isLoading false in default state', () {
      final fakeSizeRepository = FakeSizeRepository();
      final container = ProviderContainer(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(adminSizesProvider);

      expect(state.isLoading, isFalse);
    });

    test('should have null errorMessage in default state', () {
      final fakeSizeRepository = FakeSizeRepository();
      final container = ProviderContainer(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(adminSizesProvider);

      expect(state.errorMessage, isNull);
    });

    test('should have statusFilter set to all in default state', () {
      final fakeSizeRepository = FakeSizeRepository();
      final container = ProviderContainer(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(adminSizesProvider);

      expect(state.statusFilter, 'all');
    });
  });
}
