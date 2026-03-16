import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockSizeRepository extends Mock implements SizeRepository {}

void main() {
  group('adminSizesProvider', () {
    test('should create AdminSizesNotifier with SizeRepository', () {
      final mockSizeRepository = MockSizeRepository();

      final container = ProviderContainer(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
        ],
      );

      addTearDown(container.dispose);

      final notifier = container.read(adminSizesProvider.notifier);
      final state = container.read(adminSizesProvider);

      expect(notifier, isA<AdminSizesNotifier>());
      expect(state, const AdminSizesState());
    });

    test('build() returns default AdminSizesState', () {
      final mockSizeRepository = MockSizeRepository();

      final container = ProviderContainer(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
        ],
      );

      addTearDown(container.dispose);

      final state = container.read(adminSizesProvider);

      expect(state.sizes, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.statusFilter, 'all');
    });
  });
}
