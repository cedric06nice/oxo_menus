import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_state.dart';

void main() {
  group('AdminSizesState', () {
    test('should have correct default values', () {
      const state = AdminSizesState();

      expect(state.sizes, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.statusFilter, 'all');
    });

    test('should support copyWith', () {
      const state = AdminSizesState();
      const size = Size(
        id: 1,
        name: 'A4',
        width: 210,
        height: 297,
        status: Status.published,
        direction: 'portrait',
      );

      final updated = state.copyWith(
        sizes: [size],
        isLoading: true,
        errorMessage: 'Something went wrong',
        statusFilter: 'draft',
      );

      expect(updated.sizes, hasLength(1));
      expect(updated.sizes.first.name, 'A4');
      expect(updated.isLoading, true);
      expect(updated.errorMessage, 'Something went wrong');
      expect(updated.statusFilter, 'draft');
    });

    test('should support equality', () {
      const state1 = AdminSizesState();
      const state2 = AdminSizesState();

      expect(state1, equals(state2));
    });
  });
}
