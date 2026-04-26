import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_state.dart';

void main() {
  group('AdminTemplatesState', () {
    group('default factory', () {
      test('should have empty templates list', () {
        const state = AdminTemplatesState();
        expect(state.templates, isEmpty);
      });

      test('should have isLoading false', () {
        const state = AdminTemplatesState();
        expect(state.isLoading, isFalse);
      });

      test('should have null errorMessage', () {
        const state = AdminTemplatesState();
        expect(state.errorMessage, isNull);
      });

      test('should have statusFilter set to all', () {
        const state = AdminTemplatesState();
        expect(state.statusFilter, 'all');
      });
    });

    group('copyWith', () {
      test('should update templates when provided', () {
        const state = AdminTemplatesState();
        const template = Menu(
          id: 1,
          name: 'Template',
          status: Status.draft,
          version: '1.0.0',
        );

        final updated = state.copyWith(templates: [template]);

        expect(updated.templates, hasLength(1));
        expect(updated.templates.first.name, 'Template');
      });

      test('should update isLoading when provided', () {
        const state = AdminTemplatesState();

        final updated = state.copyWith(isLoading: true);

        expect(updated.isLoading, isTrue);
      });

      test('should update errorMessage when provided', () {
        const state = AdminTemplatesState();

        final updated = state.copyWith(errorMessage: 'Something went wrong');

        expect(updated.errorMessage, 'Something went wrong');
      });

      test('should update statusFilter when provided', () {
        const state = AdminTemplatesState();

        final updated = state.copyWith(statusFilter: 'published');

        expect(updated.statusFilter, 'published');
      });

      test('should preserve unchanged fields', () {
        const template = Menu(
          id: 1,
          name: 'T',
          status: Status.draft,
          version: '1',
        );
        final state = const AdminTemplatesState().copyWith(
          templates: [template],
          statusFilter: 'draft',
        );

        final updated = state.copyWith(isLoading: true);

        expect(updated.templates, hasLength(1));
        expect(updated.statusFilter, 'draft');
        expect(updated.isLoading, isTrue);
      });

      test('should allow clearing errorMessage via copyWith with null', () {
        final state = const AdminTemplatesState().copyWith(
          errorMessage: 'Error',
        );

        final cleared = state.copyWith(errorMessage: null);

        expect(cleared.errorMessage, isNull);
      });
    });

    group('equality', () {
      test('should be equal when all fields are default', () {
        const state1 = AdminTemplatesState();
        const state2 = AdminTemplatesState();

        expect(state1, equals(state2));
      });

      test('should not be equal when isLoading differs', () {
        const state1 = AdminTemplatesState();
        final state2 = state1.copyWith(isLoading: true);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when templates differ', () {
        const state1 = AdminTemplatesState();
        final state2 = state1.copyWith(
          templates: [
            const Menu(id: 1, name: 'T', status: Status.draft, version: '1'),
          ],
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when errorMessage differs', () {
        const state1 = AdminTemplatesState();
        final state2 = state1.copyWith(errorMessage: 'error');

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when statusFilter differs', () {
        const state1 = AdminTemplatesState();
        final state2 = state1.copyWith(statusFilter: 'draft');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('hashCode', () {
      test('should be equal for two identical default instances', () {
        const state1 = AdminTemplatesState();
        const state2 = AdminTemplatesState();

        expect(state1.hashCode, equals(state2.hashCode));
      });
    });
  });
}
