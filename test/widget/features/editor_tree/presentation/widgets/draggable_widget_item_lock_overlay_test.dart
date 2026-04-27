import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/draggable_widget_item.dart';

void main() {
  late PresentableWidgetRegistry registry;

  setUp(() {
    registry = PresentableWidgetRegistry();
    registry.register(dishWidgetDefinition);
  });

  Widget createTestWidget(
    WidgetInstance widgetInstance, {
    String? currentUserId,
    String? editingUserName,
    String? editingUserAvatar,
  }) {
    return ProviderScope(
      overrides: [
        widgetRegistryProvider.overrideWithValue(registry),
        directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
        directusAccessTokenProvider.overrideWithValue('test-token'),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: DraggableWidgetItem(
            widgetInstance: widgetInstance,
            columnId: 1,
            isEditable: true,
            currentUserId: currentUserId,
            editingUserName: editingUserName,
            editingUserAvatar: editingUserAvatar,
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

    testWidgets('should display editing user initials in lock overlay badge', (
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
        createTestWidget(
          widget,
          currentUserId: 'user-123',
          editingUserName: 'Alice Baker',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('should show Tooltip with editing user name', (tester) async {
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
        createTestWidget(
          widget,
          currentUserId: 'user-123',
          editingUserName: 'Alice Baker',
        ),
      );
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Alice Baker');
    });

    testWidgets('editing-lock path fills full column width', (tester) async {
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

      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == double.infinity,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('should display "?" when editingUserName is null', (
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

      expect(find.text('?'), findsOneWidget);
    });
  });
}
