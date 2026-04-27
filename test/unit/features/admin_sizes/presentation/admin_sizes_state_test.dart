import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/admin_sizes_state.dart';

void main() {
  group('AdminSizesState', () {
    group('default factory', () {
      test('should have empty sizes list', () {
        const state = AdminSizesState();
        expect(state.sizes, isEmpty);
      });

      test('should have isLoading false', () {
        const state = AdminSizesState();
        expect(state.isLoading, isFalse);
      });

      test('should have null errorMessage', () {
        const state = AdminSizesState();
        expect(state.errorMessage, isNull);
      });

      test('should have statusFilter set to all', () {
        const state = AdminSizesState();
        expect(state.statusFilter, 'all');
      });
    });

    group('copyWith', () {
      test('should update sizes when provided', () {
        const state = AdminSizesState();
        const size = Size(
          id: 1,
          name: 'A4',
          width: 210,
          height: 297,
          status: Status.published,
          direction: 'portrait',
        );

        final updated = state.copyWith(sizes: [size]);

        expect(updated.sizes, hasLength(1));
        expect(updated.sizes.first.name, 'A4');
      });

      test('should update isLoading when provided', () {
        const state = AdminSizesState();

        final updated = state.copyWith(isLoading: true);

        expect(updated.isLoading, isTrue);
      });

      test('should update errorMessage when provided', () {
        const state = AdminSizesState();

        final updated = state.copyWith(errorMessage: 'Something went wrong');

        expect(updated.errorMessage, 'Something went wrong');
      });

      test('should update statusFilter when provided', () {
        const state = AdminSizesState();

        final updated = state.copyWith(statusFilter: 'published');

        expect(updated.statusFilter, 'published');
      });

      test('should preserve unchanged fields', () {
        const size = Size(
          id: 1,
          name: 'A4',
          width: 210,
          height: 297,
          status: Status.published,
          direction: 'portrait',
        );
        final state = const AdminSizesState().copyWith(
          sizes: [size],
          statusFilter: 'published',
        );

        final updated = state.copyWith(isLoading: true);

        expect(updated.sizes, hasLength(1));
        expect(updated.statusFilter, 'published');
        expect(updated.isLoading, isTrue);
      });

      test('should allow clearing errorMessage via copyWith with null', () {
        final state = const AdminSizesState().copyWith(errorMessage: 'Error');

        final cleared = state.copyWith(errorMessage: null);

        expect(cleared.errorMessage, isNull);
      });
    });

    group('equality', () {
      test('should be equal when all fields are default', () {
        const state1 = AdminSizesState();
        const state2 = AdminSizesState();

        expect(state1, equals(state2));
      });

      test('should not be equal when isLoading differs', () {
        const state1 = AdminSizesState();
        final state2 = state1.copyWith(isLoading: true);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when sizes differ', () {
        const state1 = AdminSizesState();
        final state2 = state1.copyWith(
          sizes: [
            const Size(
              id: 1,
              name: 'A4',
              width: 210,
              height: 297,
              status: Status.published,
              direction: 'portrait',
            ),
          ],
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when errorMessage differs', () {
        const state1 = AdminSizesState();
        final state2 = state1.copyWith(errorMessage: 'error');

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when statusFilter differs', () {
        const state1 = AdminSizesState();
        final state2 = state1.copyWith(statusFilter: 'draft');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('hashCode', () {
      test('should be equal for two identical default instances', () {
        const state1 = AdminSizesState();
        const state2 = AdminSizesState();

        expect(state1.hashCode, equals(state2.hashCode));
      });
    });
  });
}
