import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/widgets/editor/draggable_widget_item.dart';
import 'package:oxo_menus/presentation/widgets/canvas/widget_renderer.dart';

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

    Widget createTestWidget({
      required Widget child,
      TargetPlatform platform = TargetPlatform.android,
    }) {
      return ProviderScope(
        child: MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(body: child),
        ),
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

    group('feedback widget', () {
      testWidgets(
        'feedback container uses maxWidth constraint instead of fixed width',
        (WidgetTester tester) async {
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

          // Start a long press drag to trigger the feedback widget
          final gesture = await tester.startGesture(
            tester.getCenter(find.byKey(const Key('widget_42'))),
          );
          await tester.pump(const Duration(seconds: 1));
          await gesture.moveBy(const Offset(0, 50));
          await tester.pump();

          // Find the feedback Container (it's in an overlay)
          // The feedback should use constraints instead of fixed width
          bool foundMaxWidthContainer = false;
          for (final element in tester.widgetList<Container>(
            find.byType(Container),
          )) {
            if (element.constraints?.maxWidth == 200 &&
                element.constraints?.minWidth == 0) {
              foundMaxWidthContainer = true;
            }
          }
          expect(foundMaxWidthContainer, isTrue);

          await gesture.up();
          await tester.pumpAndSettle();
        },
      );
    });

    group('theme colors', () {
      testWidgets('dismiss background uses theme error color during swipe', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
              onConfirmDismiss: () async => false,
              onDismissed: (_) {},
            ),
          ),
        );

        // Start a swipe to reveal the dismiss background
        await tester.drag(
          find.byKey(const Key('dismissible_42')),
          const Offset(-200, 0),
        );
        await tester.pump();

        // Now the dismiss background should be visible
        final theme = Theme.of(
          tester.element(find.byKey(const Key('dismissible_42'))),
        );
        bool foundErrorColor = false;
        for (final element in tester.widgetList<Container>(
          find.byType(Container),
        )) {
          final decoration = element.decoration;
          if (decoration is BoxDecoration &&
              element.alignment == Alignment.centerRight &&
              decoration.color == theme.colorScheme.error) {
            foundErrorColor = true;
          }
        }
        expect(foundErrorColor, isTrue);

        await tester.pumpAndSettle();
      });

      testWidgets('dismiss icon uses theme onError color during swipe', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
              onConfirmDismiss: () async => false,
              onDismissed: (_) {},
            ),
          ),
        );

        // Start a swipe to reveal the dismiss background
        await tester.drag(
          find.byKey(const Key('dismissible_42')),
          const Offset(-200, 0),
        );
        await tester.pump();

        final theme = Theme.of(
          tester.element(find.byKey(const Key('dismissible_42'))),
        );
        bool foundOnErrorIcon = false;
        for (final element in tester.widgetList<Icon>(
          find.byIcon(Icons.delete),
        )) {
          if (element.color == theme.colorScheme.onError) {
            foundOnErrorIcon = true;
          }
        }
        expect(foundOnErrorIcon, isTrue);

        await tester.pumpAndSettle();
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

      testWidgets('lock icon uses theme onSurfaceVariant color', (
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

        final icon = tester.widget<Icon>(find.byIcon(Icons.lock));
        final theme = Theme.of(
          tester.element(find.byKey(const Key('template_widget_99'))),
        );
        expect(icon.color, theme.colorScheme.onSurfaceVariant);
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

      testWidgets('shows CupertinoIcons.lock on iOS', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            platform: TargetPlatform.iOS,
            child: DraggableWidgetItem(
              widgetInstance: templateWidget,
              columnId: 1,
              isEditable: false,
              isLocked: true,
            ),
          ),
        );

        expect(find.byIcon(CupertinoIcons.lock), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsNothing);
      });
    });

    group('iOS icons', () {
      testWidgets('dismiss background uses CupertinoIcons.delete on iOS', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            platform: TargetPlatform.iOS,
            child: DraggableWidgetItem(
              widgetInstance: testWidget,
              columnId: 1,
              isEditable: true,
              isLocked: false,
              onConfirmDismiss: () async => false,
              onDismissed: (_) {},
            ),
          ),
        );

        await tester.drag(
          find.byKey(const Key('dismissible_42')),
          const Offset(-200, 0),
        );
        await tester.pump();

        expect(find.byIcon(CupertinoIcons.delete), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsNothing);

        await tester.pumpAndSettle();
      });
    });
  });
}
