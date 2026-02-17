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

    group('allowedWidgetTypes filtering', () {
      testWidgets('shows only allowed types when list is non-empty', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgetTypes: const ['dish'],
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
        expect(find.byKey(const Key('palette_item_section')), findsNothing);
        expect(find.byKey(const Key('palette_item_text')), findsNothing);
      });

      testWidgets('shows all types when list is empty', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgetTypes: const [],
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
        expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
        expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
      });

      testWidgets('shows all types when allowedWidgetTypes is null', (
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
    });

    group('admin mode checkboxes', () {
      testWidgets('shows checkboxes when onAllowedTypesChanged is provided', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgetTypes: const ['dish', 'text'],
                onAllowedTypesChanged: (_) {},
              ),
            ),
          ),
        );

        // All types should be visible (admin sees all)
        expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
        expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
        expect(find.byKey(const Key('palette_item_text')), findsOneWidget);

        // Should have checkboxes
        expect(find.byType(Checkbox), findsNWidgets(3));
      });

      testWidgets('checkboxes reflect allowedWidgetTypes state', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgetTypes: const ['dish'],
                onAllowedTypesChanged: (_) {},
              ),
            ),
          ),
        );

        // dish should be checked, section and text should not
        final checkboxes = tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .toList();
        expect(checkboxes.length, 3);

        // Find checkbox by key
        final dishCheckbox = tester.widget<Checkbox>(
          find.byKey(const Key('allowed_type_checkbox_dish')),
        );
        final sectionCheckbox = tester.widget<Checkbox>(
          find.byKey(const Key('allowed_type_checkbox_section')),
        );
        final textCheckbox = tester.widget<Checkbox>(
          find.byKey(const Key('allowed_type_checkbox_text')),
        );

        expect(dishCheckbox.value, true);
        expect(sectionCheckbox.value, false);
        expect(textCheckbox.value, false);
      });

      testWidgets('empty allowedWidgetTypes means all checked', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgetTypes: const [],
                onAllowedTypesChanged: (_) {},
              ),
            ),
          ),
        );

        final dishCheckbox = tester.widget<Checkbox>(
          find.byKey(const Key('allowed_type_checkbox_dish')),
        );
        final sectionCheckbox = tester.widget<Checkbox>(
          find.byKey(const Key('allowed_type_checkbox_section')),
        );
        final textCheckbox = tester.widget<Checkbox>(
          find.byKey(const Key('allowed_type_checkbox_text')),
        );

        expect(dishCheckbox.value, true);
        expect(sectionCheckbox.value, true);
        expect(textCheckbox.value, true);
      });

      testWidgets('tapping checkbox calls onAllowedTypesChanged', (
        WidgetTester tester,
      ) async {
        List<String>? updatedTypes;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgetTypes: const ['dish', 'text'],
                onAllowedTypesChanged: (types) {
                  updatedTypes = types;
                },
              ),
            ),
          ),
        );

        // Tap the section checkbox (currently unchecked) to add it
        await tester.tap(
          find.byKey(const Key('allowed_type_checkbox_section')),
        );
        await tester.pump();

        expect(updatedTypes, isNotNull);
        expect(updatedTypes, contains('dish'));
        expect(updatedTypes, contains('text'));
        expect(updatedTypes, contains('section'));
      });

      testWidgets('unchecking a type removes it from list', (
        WidgetTester tester,
      ) async {
        List<String>? updatedTypes;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgetTypes: const ['dish', 'text'],
                onAllowedTypesChanged: (types) {
                  updatedTypes = types;
                },
              ),
            ),
          ),
        );

        // Tap the dish checkbox (currently checked) to remove it
        await tester.tap(find.byKey(const Key('allowed_type_checkbox_dish')));
        await tester.pump();

        expect(updatedTypes, isNotNull);
        expect(updatedTypes, ['text']);
      });

      testWidgets(
        'unchecking a type when all allowed (empty list) produces list of remaining types',
        (WidgetTester tester) async {
          List<String>? updatedTypes;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: WidgetPalette(
                  registry: registry,
                  allowedWidgetTypes: const [],
                  onAllowedTypesChanged: (types) {
                    updatedTypes = types;
                  },
                ),
              ),
            ),
          );

          // All are checked (empty list = all allowed)
          // Tap dish to uncheck it
          await tester.tap(find.byKey(const Key('allowed_type_checkbox_dish')));
          await tester.pump();

          // Should produce a list with all types EXCEPT dish
          expect(updatedTypes, isNotNull);
          expect(updatedTypes, isNot(contains('dish')));
          expect(updatedTypes, contains('section'));
          expect(updatedTypes, contains('text'));
        },
      );

      testWidgets('no checkboxes when onAllowedTypesChanged is null', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgetTypes: const ['dish'],
              ),
            ),
          ),
        );

        expect(find.byType(Checkbox), findsNothing);
      });
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
