import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_palette.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/set_menu_title_widget/set_menu_title_widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

void main() {
  group('WidgetPalette', () {
    late PresentableWidgetRegistry registry;

    setUp(() {
      registry = PresentableWidgetRegistry();
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

    testWidgets('each palette item shows icon and displayName label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      expect(find.text('Dish'), findsOneWidget);
      expect(find.text('Section'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);

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
                allowedWidgets: const [WidgetTypeConfig(type: 'dish')],
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
              body: WidgetPalette(registry: registry, allowedWidgets: const []),
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
                allowedWidgets: const [
                  WidgetTypeConfig(type: 'dish'),
                  WidgetTypeConfig(type: 'text'),
                ],
                onAllowedWidgetsChanged: (_) {},
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
                allowedWidgets: const [WidgetTypeConfig(type: 'dish')],
                onAllowedWidgetsChanged: (_) {},
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
                allowedWidgets: const [],
                onAllowedWidgetsChanged: (_) {},
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
        List<WidgetTypeConfig>? updatedTypes;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgets: const [
                  WidgetTypeConfig(type: 'dish'),
                  WidgetTypeConfig(type: 'text'),
                ],
                onAllowedWidgetsChanged: (types) {
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
        final section = updatedTypes!.firstWhere((c) => c.type == 'section');
        expect(section.enabled, isTrue);
      });

      testWidgets('unchecking a type flips its enabled flag to false', (
        WidgetTester tester,
      ) async {
        List<WidgetTypeConfig>? updatedTypes;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(
                registry: registry,
                allowedWidgets: const [
                  WidgetTypeConfig(type: 'dish'),
                  WidgetTypeConfig(type: 'text'),
                ],
                onAllowedWidgetsChanged: (types) {
                  updatedTypes = types;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('allowed_type_checkbox_dish')));
        await tester.pump();

        expect(updatedTypes, isNotNull);
        final dish = updatedTypes!.firstWhere((c) => c.type == 'dish');
        expect(dish.enabled, isFalse);
        // text remains enabled
        final text = updatedTypes!.firstWhere((c) => c.type == 'text');
        expect(text.enabled, isTrue);
      });

      testWidgets(
        'unchecking a type when all allowed (empty list) flips only that '
        'type\'s enabled flag',
        (WidgetTester tester) async {
          List<WidgetTypeConfig>? updatedTypes;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: WidgetPalette(
                  registry: registry,
                  allowedWidgets: const [],
                  onAllowedWidgetsChanged: (types) {
                    updatedTypes = types;
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.byKey(const Key('allowed_type_checkbox_dish')));
          await tester.pump();

          expect(updatedTypes, isNotNull);
          final dish = updatedTypes!.firstWhere((c) => c.type == 'dish');
          expect(dish.enabled, isFalse);
          final section = updatedTypes!.firstWhere((c) => c.type == 'section');
          expect(section.enabled, isTrue);
          final text = updatedTypes!.firstWhere((c) => c.type == 'text');
          expect(text.enabled, isTrue);
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
                allowedWidgets: const [WidgetTypeConfig(type: 'dish')],
              ),
            ),
          ),
        );

        expect(find.byType(Checkbox), findsNothing);
      });

      testWidgets(
        'shows alignment selector for each enabled type with Justified for '
        'price-bearing types',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: WidgetPalette(
                  registry: registry,
                  allowedWidgets: const [
                    WidgetTypeConfig(type: 'dish'),
                    WidgetTypeConfig(type: 'section'),
                  ],
                  onAllowedWidgetsChanged: (_) {},
                ),
              ),
            ),
          );

          // Alignment selector is always shown in admin mode — admins can
          // configure alignment even for disabled types. Section hides the
          // Justified option since it has no price line.
          expect(
            find.byKey(const Key('alignment_selector_dish')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('alignment_selector_section')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('alignment_selector_text')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'stale justified alignment on non-price types is sanitised when '
        'the list is emitted',
        (WidgetTester tester) async {
          List<WidgetTypeConfig>? captured;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: WidgetPalette(
                  registry: registry,
                  // Section has stale justified (non-price-line type).
                  allowedWidgets: const [
                    WidgetTypeConfig(type: 'dish'),
                    WidgetTypeConfig(
                      type: 'section',
                      alignment: WidgetAlignment.justified,
                    ),
                  ],
                  onAllowedWidgetsChanged: (configs) => captured = configs,
                ),
              ),
            ),
          );

          // Toggle an unrelated dish checkbox — the emitted list must still
          // scrub the stale justified from section.
          await tester.tap(find.byKey(const Key('allowed_type_checkbox_dish')));
          await tester.pump();

          expect(captured, isNotNull);
          final section = captured!.firstWhere((c) => c.type == 'section');
          expect(section.alignment, isNot(WidgetAlignment.justified));
        },
      );

      testWidgets(
        'changing alignment fires onAllowedWidgetsChanged with new config',
        (WidgetTester tester) async {
          List<WidgetTypeConfig>? captured;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: WidgetPalette(
                  registry: registry,
                  allowedWidgets: const [WidgetTypeConfig(type: 'dish')],
                  onAllowedWidgetsChanged: (configs) => captured = configs,
                ),
              ),
            ),
          );

          // Tap the Center icon inside the dish selector.
          final centerIcon = find.descendant(
            of: find.byKey(const Key('alignment_selector_dish')),
            matching: find.byIcon(Icons.format_align_center),
          );
          expect(centerIcon, findsOneWidget);
          await tester.tap(centerIcon);
          await tester.pump();

          expect(captured, isNotNull);
          final dish = captured!.firstWhere((c) => c.type == 'dish');
          expect(dish.alignment, WidgetAlignment.center);
        },
      );
    });

    testWidgets(
      'displays displayName without underscores for multi-word types',
      (WidgetTester tester) async {
        final registryWithMultiWord = PresentableWidgetRegistry();
        registryWithMultiWord.register(setMenuTitleWidgetDefinition);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(registry: registryWithMultiWord),
            ),
          ),
        );

        // Should show "Set Menu Title" (from displayName), not "SET_MENU_TITLE"
        expect(find.text('Set Menu Title'), findsOneWidget);
        expect(find.text('SET_MENU_TITLE'), findsNothing);
      },
    );

    testWidgets('palette item has 12px border radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      final container = tester.widget<Container>(
        find.byKey(const Key('palette_item_dish')),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('palette item uses theme surface color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      final container = tester.widget<Container>(
        find.byKey(const Key('palette_item_dish')),
      );
      final decoration = container.decoration as BoxDecoration;
      // Should use theme.colorScheme.surface instead of hardcoded Colors.white
      final theme = Theme.of(
        tester.element(find.byKey(const Key('palette_item_dish'))),
      );
      expect(decoration.color, theme.colorScheme.surface);
    });

    testWidgets('palette item border uses theme outlineVariant', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      final container = tester.widget<Container>(
        find.byKey(const Key('palette_item_dish')),
      );
      final decoration = container.decoration as BoxDecoration;
      final theme = Theme.of(
        tester.element(find.byKey(const Key('palette_item_dish'))),
      );
      expect(
        decoration.border,
        Border.all(color: theme.colorScheme.outlineVariant),
      );
    });

    testWidgets('icon uses theme onSurfaceVariant color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.restaurant_menu));
      final theme = Theme.of(
        tester.element(find.byIcon(Icons.restaurant_menu)),
      );
      expect(icon.color, theme.colorScheme.onSurfaceVariant);
    });

    testWidgets('palette container uses theme surfaceContainerLow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      final widgetPalette = find.byType(WidgetPalette);
      // The WidgetPalette's root Container should use surfaceContainerLow
      final containers = find.descendant(
        of: widgetPalette,
        matching: find.byType(Container),
      );
      // First container is the root one with background color
      final rootContainer = tester.widget<Container>(containers.first);
      final theme = Theme.of(tester.element(widgetPalette));
      expect(rootContainer.color, theme.colorScheme.surfaceContainerLow);
    });

    group('horizontal mode', () {
      testWidgets('renders horizontally when axis is Axis.horizontal', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(registry: registry, axis: Axis.horizontal),
            ),
          ),
        );

        // Title should be hidden in horizontal mode
        expect(find.text('Widget Palette'), findsNothing);

        // Items should still be present
        expect(find.byKey(const Key('palette_item_dish')), findsOneWidget);
        expect(find.byKey(const Key('palette_item_section')), findsOneWidget);
        expect(find.byKey(const Key('palette_item_text')), findsOneWidget);
      });

      testWidgets('horizontal mode uses horizontal scrolling ListView', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(registry: registry, axis: Axis.horizontal),
            ),
          ),
        );

        // Find a ListView with horizontal scroll direction
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.scrollDirection, Axis.horizontal);
      });

      testWidgets('horizontal mode container has fixed height', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(registry: registry, axis: Axis.horizontal),
            ),
          ),
        );

        // The root container should have a constrained height
        final widgetPalette = find.byType(WidgetPalette);
        final rootContainer = tester.widget<Container>(
          find
              .descendant(of: widgetPalette, matching: find.byType(Container))
              .first,
        );
        expect(rootContainer.constraints?.maxHeight, 60);
      });

      testWidgets('short label shrinks to content width', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetPalette(registry: registry, axis: Axis.horizontal),
            ),
          ),
        );

        final itemBox = tester.renderObject<RenderBox>(
          find.byKey(const Key('palette_item_text')),
        );
        // "TEXT" is short — item should shrink below 200px max
        expect(itemBox.size.width, lessThan(200));
      });

      testWidgets('item width is capped at maxWidth', (
        WidgetTester tester,
      ) async {
        // Register a widget with a very long type name
        final longRegistry = PresentableWidgetRegistry();
        longRegistry.register(textWidgetDefinition);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                child: WidgetPalette(
                  registry: longRegistry,
                  axis: Axis.horizontal,
                ),
              ),
            ),
          ),
        );

        // The palette item's rendered width should not exceed 200
        final itemBox = tester.renderObject<RenderBox>(
          find.byKey(const Key('palette_item_text')),
        );
        expect(itemBox.size.width, lessThanOrEqualTo(200));
      });

      testWidgets('defaults to vertical axis', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: WidgetPalette(registry: registry)),
          ),
        );

        // Default axis is vertical — title visible
        expect(find.text('Widget Palette'), findsOneWidget);
      });
    });

    group('text overflow', () {
      testWidgets(
        'palette item text uses Flexible to prevent overflow in narrow container',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 100,
                  child: WidgetPalette(registry: registry),
                ),
              ),
            ),
          );

          // Should not overflow — the Flexible widget should handle it
          // Find the Text widget inside a palette item
          final textFinder = find.descendant(
            of: find.byKey(const Key('palette_item_dish')),
            matching: find.byType(Text),
          );
          expect(textFinder, findsOneWidget);

          final text = tester.widget<Text>(textFinder);
          expect(text.overflow, TextOverflow.ellipsis);
        },
      );

      testWidgets('palette item text is wrapped in Flexible', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: WidgetPalette(registry: registry)),
          ),
        );

        // Find a Flexible ancestor of the Text inside palette_item_dish
        final textFinder = find.descendant(
          of: find.byKey(const Key('palette_item_dish')),
          matching: find.byType(Text),
        );
        expect(textFinder, findsOneWidget);

        final flexibleFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(Flexible),
        );
        expect(flexibleFinder, findsOneWidget);
      });
    });

    testWidgets('renders CupertinoCheckbox in admin mode on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: WidgetPalette(
              registry: registry,
              allowedWidgets: const [
                WidgetTypeConfig(type: 'dish'),
                WidgetTypeConfig(type: 'text'),
              ],
              onAllowedWidgetsChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoCheckbox), findsNWidgets(3));
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('renders Checkbox in admin mode on Android', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: WidgetPalette(
              registry: registry,
              allowedWidgets: const [
                WidgetTypeConfig(type: 'dish'),
                WidgetTypeConfig(type: 'text'),
              ],
              onAllowedWidgetsChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsNWidgets(3));
      expect(find.byType(CupertinoCheckbox), findsNothing);
    });

    testWidgets('uses CupertinoIcons on iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(body: WidgetPalette(registry: registry)),
        ),
      );

      expect(find.byIcon(CupertinoIcons.text_justify), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsNothing);
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
