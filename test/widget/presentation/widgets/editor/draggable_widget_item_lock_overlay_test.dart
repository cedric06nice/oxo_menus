import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/editor/draggable_widget_item.dart';

void main() {
  late WidgetRegistry registry;

  setUp(() {
    registry = WidgetRegistry();
    registry.register(dishWidgetDefinition);
  });

  Widget createTestWidget(
    WidgetInstance widgetInstance, {
    String? currentUserId,
  }) {
    return ProviderScope(
      overrides: [widgetRegistryProvider.overrideWithValue(registry)],
      child: MaterialApp(
        home: Scaffold(
          body: DraggableWidgetItem(
            widgetInstance: widgetInstance,
            columnId: 1,
            isEditable: true,
            currentUserId: currentUserId,
          ),
        ),
      ),
    );
  }

  group('DraggableWidgetItem editing lock overlay', () {
    testWidgets('should show lock overlay when editingBy is another user', (
      tester,
    ) async {
      final widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: const {'name': 'Pasta', 'price': 12.50},
        editingBy: 'other-user-456',
        editingSince: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(widget, currentUserId: 'user-123'),
      );
      await tester.pumpAndSettle();

      // Should show lock overlay with editing indicator
      expect(find.byKey(const Key('editing_lock_overlay_1')), findsOneWidget);
    });

    testWidgets('should NOT show lock overlay when editingBy is current user', (
      tester,
    ) async {
      final widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: const {'name': 'Pasta', 'price': 12.50},
        editingBy: 'user-123',
        editingSince: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(widget, currentUserId: 'user-123'),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('editing_lock_overlay_1')), findsNothing);
    });

    testWidgets('should NOT show lock overlay when editingBy is null', (
      tester,
    ) async {
      const widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: {'name': 'Pasta', 'price': 12.50},
      );

      await tester.pumpWidget(
        createTestWidget(widget, currentUserId: 'user-123'),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('editing_lock_overlay_1')), findsNothing);
    });

    testWidgets('should NOT show lock overlay for stale locks (>2 min)', (
      tester,
    ) async {
      final widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: const {'name': 'Pasta', 'price': 12.50},
        editingBy: 'other-user-456',
        editingSince: DateTime.now().subtract(const Duration(minutes: 3)),
      );

      await tester.pumpWidget(
        createTestWidget(widget, currentUserId: 'user-123'),
      );
      await tester.pumpAndSettle();

      // Stale lock should be ignored
      expect(find.byKey(const Key('editing_lock_overlay_1')), findsNothing);
    });

    testWidgets('should disable drag for editing-locked widgets', (
      tester,
    ) async {
      final widget = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'dish',
        version: '1.0.0',
        index: 0,
        props: const {'name': 'Pasta', 'price': 12.50},
        editingBy: 'other-user-456',
        editingSince: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(widget, currentUserId: 'user-123'),
      );
      await tester.pumpAndSettle();

      // Should not find LongPressDraggable (drag disabled)
      expect(find.byType(LongPressDraggable), findsNothing);
    });
  });
}
