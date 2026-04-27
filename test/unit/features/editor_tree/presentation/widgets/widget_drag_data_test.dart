import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/widget_drag_data.dart';

void main() {
  group('WidgetDragData', () {
    group('newWidget factory', () {
      test('sets isNewWidget to true', () {
        final dragData = WidgetDragData.newWidget('dish');

        expect(dragData.isNewWidget, isTrue);
      });

      test('sets isExistingWidget to false', () {
        final dragData = WidgetDragData.newWidget('dish');

        expect(dragData.isExistingWidget, isFalse);
      });

      test('sets newWidgetType correctly', () {
        final dragData = WidgetDragData.newWidget('dish');

        expect(dragData.newWidgetType, 'dish');
      });

      test('sets existingWidget to null', () {
        final dragData = WidgetDragData.newWidget('dish');

        expect(dragData.existingWidget, isNull);
      });

      test('sets sourceColumnId to null', () {
        final dragData = WidgetDragData.newWidget('dish');

        expect(dragData.sourceColumnId, isNull);
      });
    });

    group('existing factory', () {
      final mockWidget = WidgetInstance(
        id: 1,
        columnId: 5,
        type: 'text',
        version: '1',
        index: 2,
        props: {},
        isTemplate: false,
      );

      test('sets isExistingWidget to true', () {
        final dragData = WidgetDragData.existing(mockWidget, 5);

        expect(dragData.isExistingWidget, isTrue);
      });

      test('sets isNewWidget to false', () {
        final dragData = WidgetDragData.existing(mockWidget, 5);

        expect(dragData.isNewWidget, isFalse);
      });

      test('sets existingWidget correctly', () {
        final dragData = WidgetDragData.existing(mockWidget, 5);

        expect(dragData.existingWidget, equals(mockWidget));
      });

      test('sets sourceColumnId correctly', () {
        final dragData = WidgetDragData.existing(mockWidget, 5);

        expect(dragData.sourceColumnId, 5);
      });

      test('sets newWidgetType to null', () {
        final dragData = WidgetDragData.existing(mockWidget, 5);

        expect(dragData.newWidgetType, isNull);
      });
    });
  });
}
