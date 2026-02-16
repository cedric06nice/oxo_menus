import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_state.dart';

void main() {
  group('AdminTemplatesState', () {
    test('should have correct defaults', () {
      const state = AdminTemplatesState();

      expect(state.templates, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.statusFilter, 'all');
    });

    test('should support copyWith for all fields', () {
      const template = Menu(
        id: 1,
        name: 'Template',
        status: Status.draft,
        version: '1.0.0',
      );

      const state = AdminTemplatesState();
      final updated = state.copyWith(
        templates: [template],
        isLoading: true,
        errorMessage: 'Error',
        statusFilter: 'draft',
      );

      expect(updated.templates, hasLength(1));
      expect(updated.isLoading, true);
      expect(updated.errorMessage, 'Error');
      expect(updated.statusFilter, 'draft');
    });

    test('should support equality', () {
      const state1 = AdminTemplatesState();
      const state2 = AdminTemplatesState();

      expect(state1, equals(state2));
    });

    test('should not be equal when fields differ', () {
      const state1 = AdminTemplatesState();
      final state2 = state1.copyWith(isLoading: true);

      expect(state1, isNot(equals(state2)));
    });
  });
}
