import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';

void main() {
  group('WidgetContext', () {
    test('stores onEditStarted callback', () {
      var called = false;
      final context = WidgetContext(
        isEditable: true,
        onEditStarted: () => called = true,
      );

      context.onEditStarted?.call();
      expect(called, isTrue);
    });

    test('stores onEditEnded callback', () {
      var called = false;
      final context = WidgetContext(
        isEditable: true,
        onEditEnded: () => called = true,
      );

      context.onEditEnded?.call();
      expect(called, isTrue);
    });

    test('onEditStarted defaults to null', () {
      const context = WidgetContext(isEditable: false);
      expect(context.onEditStarted, isNull);
    });

    test('onEditEnded defaults to null', () {
      const context = WidgetContext(isEditable: false);
      expect(context.onEditEnded, isNull);
    });
  });
}
