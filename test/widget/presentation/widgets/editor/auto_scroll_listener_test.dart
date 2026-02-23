import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/editor/auto_scroll_listener.dart';

void main() {
  group('AutoScrollListener', () {
    testWidgets('renders its child', (WidgetTester tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoScrollListener(
              scrollController: controller,
              child: SingleChildScrollView(
                controller: controller,
                child: const SizedBox(
                  height: 2000,
                  child: Text('Scrollable content'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Scrollable content'), findsOneWidget);
    });

    testWidgets('scrolls down when pointer is near bottom edge', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoScrollListener(
              scrollController: controller,
              edgeThreshold: 80,
              child: SingleChildScrollView(
                controller: controller,
                child: const SizedBox(height: 2000, width: 200),
              ),
            ),
          ),
        ),
      );

      expect(controller.offset, 0.0);

      // Get the bottom of the AutoScrollListener area
      final listenerBox = tester.getRect(find.byType(AutoScrollListener));
      final bottomEdge = Offset(
        listenerBox.center.dx,
        listenerBox.bottom - 20, // 20px from bottom, within threshold
      );

      // Simulate pointer down then move near bottom
      final gesture = await tester.startGesture(listenerBox.center);
      await tester.pump();
      await gesture.moveTo(bottomEdge);

      // Allow several timer ticks for scrolling
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(controller.offset, greaterThan(0));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('scrolls up when pointer is near top edge', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController(initialScrollOffset: 500);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoScrollListener(
              scrollController: controller,
              edgeThreshold: 80,
              // Use NeverScrollableScrollPhysics to prevent gesture-based scrolling
              // so only our auto-scroll timer moves the offset
              child: SingleChildScrollView(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                child: const SizedBox(height: 2000, width: 200),
              ),
            ),
          ),
        ),
      );

      expect(controller.offset, 500.0);

      // Get the top of the AutoScrollListener area
      final listenerBox = tester.getRect(find.byType(AutoScrollListener));
      final topEdge = Offset(
        listenerBox.center.dx,
        listenerBox.top + 20, // 20px from top, within threshold
      );

      // Simulate pointer down near top, then move slightly to trigger onPointerMove
      final gesture = await tester.startGesture(topEdge);
      await tester.pump();
      await gesture.moveTo(topEdge + const Offset(1, 0));

      // Allow several timer ticks for scrolling
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(controller.offset, lessThan(500));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('stops scrolling when pointer moves to center', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoScrollListener(
              scrollController: controller,
              edgeThreshold: 80,
              child: SingleChildScrollView(
                controller: controller,
                child: const SizedBox(height: 2000, width: 200),
              ),
            ),
          ),
        ),
      );

      final listenerBox = tester.getRect(find.byType(AutoScrollListener));
      final bottomEdge = Offset(listenerBox.center.dx, listenerBox.bottom - 20);

      // Start gesture, move to bottom edge
      final gesture = await tester.startGesture(listenerBox.center);
      await tester.pump();
      await gesture.moveTo(bottomEdge);

      // Let it scroll a bit
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final scrolledOffset = controller.offset;
      expect(scrolledOffset, greaterThan(0));

      // Move to center (outside threshold)
      await gesture.moveTo(listenerBox.center);
      await tester.pump();

      // Pump more frames - scroll should stop
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Offset should not have increased significantly after moving to center
      expect(controller.offset, closeTo(scrolledOffset, 1.0));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('stops scrolling on pointer up', (WidgetTester tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoScrollListener(
              scrollController: controller,
              edgeThreshold: 80,
              child: SingleChildScrollView(
                controller: controller,
                child: const SizedBox(height: 2000, width: 200),
              ),
            ),
          ),
        ),
      );

      final listenerBox = tester.getRect(find.byType(AutoScrollListener));
      final bottomEdge = Offset(listenerBox.center.dx, listenerBox.bottom - 20);

      final gesture = await tester.startGesture(listenerBox.center);
      await tester.pump();
      await gesture.moveTo(bottomEdge);

      // Let it scroll a bit
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final scrolledOffset = controller.offset;

      // Pointer up
      await gesture.up();
      await tester.pump();

      // Pump more frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Offset should not have increased after pointer up
      expect(controller.offset, closeTo(scrolledOffset, 1.0));

      await tester.pumpAndSettle();
    });

    testWidgets('does not scroll when pointer is in center area', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoScrollListener(
              scrollController: controller,
              edgeThreshold: 80,
              child: SingleChildScrollView(
                controller: controller,
                child: const SizedBox(height: 2000, width: 200),
              ),
            ),
          ),
        ),
      );

      final listenerBox = tester.getRect(find.byType(AutoScrollListener));

      // Start gesture and move within center
      final gesture = await tester.startGesture(listenerBox.center);
      await tester.pump();
      await gesture.moveTo(listenerBox.center + const Offset(10, 10));

      // Pump frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(controller.offset, 0.0);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'scrolls during active LongPressDraggable drag near bottom edge',
      (WidgetTester tester) async {
        final controller = ScrollController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutoScrollListener(
                scrollController: controller,
                edgeThreshold: 80,
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: List.generate(
                      20,
                      (i) => LongPressDraggable<int>(
                        data: i,
                        feedback: Material(
                          child: SizedBox(
                            width: 100,
                            height: 50,
                            child: Text('Dragging $i'),
                          ),
                        ),
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Text('Item $i'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(controller.offset, 0.0);

        // Long-press on the first item to start a drag
        final firstItem = tester.getCenter(find.text('Item 0'));
        final gesture = await tester.startGesture(firstItem);
        // Hold long enough to trigger LongPressDraggable
        await tester.pump(const Duration(milliseconds: 600));

        // Move to the bottom edge of the AutoScrollListener
        final listenerBox = tester.getRect(find.byType(AutoScrollListener));
        final bottomEdge = Offset(
          listenerBox.center.dx,
          listenerBox.bottom - 20,
        );
        await gesture.moveTo(bottomEdge);

        // Allow several timer ticks for scrolling
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(controller.offset, greaterThan(0));

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('ignores pointer events outside its bounds', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      // Place AutoScrollListener in the top half of the screen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: AutoScrollListener(
                    scrollController: controller,
                    edgeThreshold: 80,
                    child: SingleChildScrollView(
                      controller: controller,
                      child: const SizedBox(height: 2000, width: 200),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(controller.offset, 0.0);

      final listenerBox = tester.getRect(find.byType(AutoScrollListener));

      // Send pointer move events well below the AutoScrollListener's bounds.
      // With global pointer route, these events would reach our handler,
      // so bounds checking is required to ignore them.
      final outsidePosition = Offset(
        listenerBox.center.dx,
        listenerBox.bottom + 100, // 100px below the widget
      );

      // Dispatch a PointerMoveEvent via the global pointer route
      // to simulate what happens with the global route approach
      GestureBinding.instance.pointerRouter.route(
        PointerMoveEvent(pointer: 99, position: outsidePosition),
      );
      await tester.pump();

      // Allow several timer ticks
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Should not have scrolled since the event was outside bounds
      expect(controller.offset, 0.0);
    });
  });
}
