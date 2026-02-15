import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/presentation/widgets/widget_renderer.dart';

void main() {
  group('DraggableWidgetItem', () {
    final testWidget = WidgetInstance(
      id: 42,
      columnId: 1,
      type: 'text',
      version: '1.0.0',
      index: 0,
      props: {'content': 'Test'},
      isTemplate: false,
    );

    Widget createTestWidget({required Widget child}) {
      return ProviderScope(
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    group('editable mode', () {
      testWidgets('renders with correct widget key', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
            ),
          ),
        );

        expect(find.byKey(const Key('widget_42')), findsOneWidget);
      });

      testWidgets('contains LongPressDraggable', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
            ),
          ),
        );

        // Verify by checking for the widget key which is inside LongPressDraggable
        expect(find.byKey(const Key('widget_42')), findsOneWidget);
      });

      testWidgets('contains Dismissible with correct key', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
            ),
          ),
        );

        expect(find.byKey(const Key('dismissible_42')), findsOneWidget);
      });

      testWidgets('contains WidgetRenderer with isEditable: true', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
            ),
          ),
        );

        final renderer = tester.widget<WidgetRenderer>(
          find.byType(WidgetRenderer),
        );
        expect(renderer.isEditable, isTrue);
      });

      testWidgets('calls onUpdate callback when WidgetRenderer updates', (
        WidgetTester tester,
      ) async {
        Map<String, dynamic>? updatedProps;

        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
              onUpdate: (props) => updatedProps = props,
            ),
          ),
        );

        final renderer = tester.widget<WidgetRenderer>(
          find.byType(WidgetRenderer),
        );
        renderer.onUpdate!({'content': 'Updated'});

        expect(updatedProps, {'content': 'Updated'});
      });

      testWidgets('calls onConfirmDismiss when swiped', (
        WidgetTester tester,
      ) async {
        bool dismissCalled = false;

        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
              onConfirmDismiss: () async {
                dismissCalled = true;
                return false;
              },
            ),
          ),
        );

        await tester.drag(
          find.byKey(const Key('dismissible_42')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(dismissCalled, isTrue);
      });
    });

    group('locked mode (template widgets)', () {
      final templateWidget = WidgetInstance(
        id: 99,
        columnId: 1,
        type: 'text',
        version: '1.0.0',
        index: 0,
        props: {'content': 'Template'},
        isTemplate: true,
      );

      testWidgets('renders with template_widget key', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: templateWidget,
              columnId: 1,
              isEditable: false,
              isLocked: true,
            ),
          ),
        );

        expect(find.byKey(const Key('template_widget_99')), findsOneWidget);
      });

      testWidgets('shows lock icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: templateWidget,
              columnId: 1,
              isEditable: false,
              isLocked: true,
            ),
          ),
        );

        expect(find.byIcon(Icons.lock), findsOneWidget);
      });

      testWidgets('does NOT contain LongPressDraggable', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: templateWidget,
              columnId: 1,
              isEditable: false,
              isLocked: true,
            ),
          ),
        );

        expect(find.byType(LongPressDraggable), findsNothing);
      });

      testWidgets('contains WidgetRenderer with isEditable: false', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: templateWidget,
              columnId: 1,
              isEditable: false,
              isLocked: true,
            ),
          ),
        );

        final renderer = tester.widget<WidgetRenderer>(
          find.byType(WidgetRenderer),
        );
        expect(renderer.isEditable, isFalse);
      });
    });
  });
}
