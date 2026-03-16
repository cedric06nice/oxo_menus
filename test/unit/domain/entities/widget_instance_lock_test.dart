import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';

void main() {
  group('WidgetInstance lock fields', () {
    test('should support editingBy field', () {
      final widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: const {},
        editingBy: 'user-abc-123',
      );

      expect(widget.editingBy, 'user-abc-123');
    });

    test('should support editingSince field', () {
      final now = DateTime(2025, 1, 15, 10, 30);
      final widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: const {},
        editingSince: now,
      );

      expect(widget.editingSince, now);
    });

    test('editingBy and editingSince should default to null', () {
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {},
      );

      expect(widget.editingBy, isNull);
      expect(widget.editingSince, isNull);
    });

    test('copyWith should update lock fields', () {
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {},
      );

      final locked = widget.copyWith(
        editingBy: 'user-xyz',
        editingSince: DateTime(2025, 1, 15),
      );

      expect(locked.editingBy, 'user-xyz');
      expect(locked.editingSince, DateTime(2025, 1, 15));
      expect(locked.id, 1); // Other fields unchanged
    });
  });
}
