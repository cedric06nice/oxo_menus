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
  });
}
