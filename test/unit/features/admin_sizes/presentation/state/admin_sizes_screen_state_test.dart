import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/state/admin_sizes_screen_state.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

const _a4 = Size(
  id: 1,
  name: 'A4',
  width: 210,
  height: 297,
  status: Status.draft,
  direction: 'portrait',
);

const _a3 = Size(
  id: 2,
  name: 'A3',
  width: 297,
  height: 420,
  status: Status.published,
  direction: 'portrait',
);

void main() {
  group('AdminSizesScreenState', () {
    test('default state is loading=true, no error, empty list, all filter, '
        'not admin', () {
      const state = AdminSizesScreenState();

      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.sizes, isEmpty);
      expect(state.statusFilter, 'all');
      expect(state.isAdmin, isFalse);
    });

    test('value equality compares all fields', () {
      const a = AdminSizesScreenState(
        isLoading: false,
        sizes: [_a4],
        statusFilter: 'draft',
        isAdmin: true,
      );
      const b = AdminSizesScreenState(
        isLoading: false,
        sizes: [_a4],
        statusFilter: 'draft',
        isAdmin: true,
      );
      const c = AdminSizesScreenState(
        isLoading: false,
        sizes: [_a3],
        statusFilter: 'draft',
        isAdmin: true,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('inequality across each field independently', () {
      const base = AdminSizesScreenState(
        isLoading: false,
        sizes: [_a4],
        statusFilter: 'draft',
        isAdmin: true,
      );

      expect(base, isNot(base.copyWith(isLoading: true)));
      expect(base, isNot(base.copyWith(errorMessage: 'boom')));
      expect(base, isNot(base.copyWith(statusFilter: 'all')));
      expect(base, isNot(base.copyWith(isAdmin: false)));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = AdminSizesScreenState(
        isLoading: false,
        sizes: [_a4],
        statusFilter: 'draft',
        isAdmin: true,
      );

      expect(source.copyWith(), source);
    });

    test('copyWith can null-out errorMessage via the sentinel', () {
      const source = AdminSizesScreenState(
        errorMessage: 'boom',
        isLoading: false,
      );

      final cleared = source.copyWith(errorMessage: null);

      expect(cleared.errorMessage, isNull);
      expect(cleared.isLoading, isFalse);
    });

    test('copyWith leaves errorMessage untouched when sentinel is omitted', () {
      const source = AdminSizesScreenState(
        errorMessage: 'boom',
        isLoading: false,
      );

      final next = source.copyWith(isLoading: true);

      expect(next.errorMessage, 'boom');
      expect(next.isLoading, isTrue);
    });
  });
}
