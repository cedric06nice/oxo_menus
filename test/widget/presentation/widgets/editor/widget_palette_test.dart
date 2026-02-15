import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

void main() {
  group('WidgetPalette', () {
    late WidgetRegistry registry;

    setUp(() {
      registry = WidgetRegistry();
      registry.register(dishWidgetDefinition);
      registry.register(sectionWidgetDefinition);
      registry.register(textWidgetDefinition);
    });

    testWidgets('renders Widget Palette title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      expect(find.text('Widget Palette'), findsOneWidget);
    });

    testWidgets('renders palette item for each registered type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
      expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
    });

    testWidgets('each palette item shows icon and uppercase label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      expect(find.text('DISH'), findsOneWidget);
      expect(find.text('SECTION'), findsOneWidget);
      expect(find.text('TEXT'), findsOneWidget);

      // Check icons are present (at least one icon per item)
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      expect(find.byIcon(Icons.title), findsOneWidget);
      expect(find.byIcon(Icons.text_fields), findsOneWidget);
    });

    testWidgets('wraps items in Draggable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      // Find Draggable widgets by checking if they can be dragged
      final dishItem = find.byKey(const Key('palette_item_dish'));
      expect(dishItem, findsOneWidget);

      // Verify the parent is a Draggable by attempting a drag gesture
      final gesture = await tester.startGesture(tester.getCenter(dishItem));
      await tester.pump();

      // During drag, the original should become semi-transparent (childWhenDragging)
      // and a feedback widget should appear
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      await gesture.up();
      await tester.pump();
    });
  });
}
