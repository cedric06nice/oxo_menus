import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';

void main() {
  group('WidgetInstance', () {
    test('should default isTemplate to false', () {
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'text',
        version: '1.0.0',
        index: 0,
        props: {'text': 'Hello'},
      );

      expect(widget.isTemplate, false);
    });

    test('should allow creating with isTemplate true', () {
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'text',
        version: '1.0.0',
        index: 0,
        props: {'text': 'Hello'},
        isTemplate: true,
      );

      expect(widget.isTemplate, true);
    });

    test('should support copyWith for isTemplate', () {
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'text',
        version: '1.0.0',
        index: 0,
        props: {'text': 'Hello'},
      );

      final updated = widget.copyWith(isTemplate: true);

      expect(updated.isTemplate, true);
      expect(updated.id, widget.id);
      expect(updated.type, widget.type);
    });
  });
}
