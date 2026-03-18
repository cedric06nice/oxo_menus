import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_drop_zone.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_drag_data.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

void main() {
  group('EditorDropZone', () {
    late PresentableWidgetRegistry registry;

    setUp(() {
      registry = PresentableWidgetRegistry();
      registry.register(dishWidgetDefinition);
      registry.register(sectionWidgetDefinition);
      registry.register(textWidgetDefinition);
    });

    Widget createTestWidget({
      required int columnId,
      required int index,
      void Function(WidgetDragData)? onAccept,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: EditorDropZone(
            columnId: columnId,
            index: index,
            registry: registry,
            onAccept: onAccept ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders with correct key', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(columnId: 1, index: 0));

      expect(find.byKey(const Key('drop_zone_1_0')), findsOneWidget);
    });

    testWidgets('renders DragTarget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(columnId: 1, index: 0));

      expect(find.byType(DragTarget<WidgetDragData>), findsOneWidget);
    });

    testWidgets('shows "Drop widgets here" text when idle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(columnId: 1, index: 0));
      await tester.pumpAndSettle();

      expect(find.text('Drop widgets here'), findsOneWidget);
    });

    testWidgets('idle text is styled italic with 10px font', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(columnId: 1, index: 0));
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Drop widgets here'));
      expect(text.style?.fontStyle, FontStyle.italic);
      expect(text.style?.fontSize, 10);
    });

    testWidgets('idle drop zone has correct height and margin', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(columnId: 1, index: 0));
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(container.margin, const EdgeInsets.symmetric(vertical: 4));
    });

    testWidgets('custom idleHeight overrides default height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorDropZone(
              columnId: 1,
              index: 0,
              registry: registry,
              onAccept: (_) {},
              idleHeight: 50,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Total rendered height = 50 (content) + 4*2 (margin) = 58
      final size = tester.getSize(find.byType(AnimatedContainer));
      expect(size.height, 58.0);
    });

    group('isNoOpDrop static method', () {
      final existingWidget = WidgetInstance(
        id: 1,
        columnId: 5,
        type: 'dish',
        version: '1.0.0',
        index: 2,
        props: {},
        isTemplate: false,
      );

      test('returns true when dropping at current position', () {
        final dragData = WidgetDragData.existing(existingWidget, 5);
        expect(EditorDropZone.isNoOpDrop(dragData, 5, 2), isTrue);
      });

      test('returns true when dropping at position right after current', () {
        final dragData = WidgetDragData.existing(existingWidget, 5);
        expect(EditorDropZone.isNoOpDrop(dragData, 5, 3), isTrue);
      });

      test('returns false when dropping in different column', () {
        final dragData = WidgetDragData.existing(existingWidget, 5);
        expect(EditorDropZone.isNoOpDrop(dragData, 6, 2), isFalse);
      });

      test('returns false when dropping at different index', () {
        final dragData = WidgetDragData.existing(existingWidget, 5);
        expect(EditorDropZone.isNoOpDrop(dragData, 5, 0), isFalse);
      });

      test('returns false for new widgets', () {
        final dragData = WidgetDragData.newWidget('dish');
        expect(EditorDropZone.isNoOpDrop(dragData, 5, 0), isFalse);
      });
    });
  });
}
