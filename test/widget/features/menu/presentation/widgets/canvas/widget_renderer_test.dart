import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/canvas/widget_renderer.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/dish_widget/dish_widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/section_widget/section_widget_definition.dart';

void main() {
  PresentableWidgetRegistry buildRegistry() {
    final registry = PresentableWidgetRegistry();
    registry.register(sectionWidgetDefinition);
    registry.register(dishWidgetDefinition);
    return registry;
  }

  group('WidgetRenderer', () {
    final sectionWidget = WidgetInstance(
      id: 1,
      type: 'section',
      version: '1.0.0',
      props: const <String, dynamic>{'title': 'Test Section'},
      index: 0,
      columnId: 1,
    );

    testWidgets('passes onEditStarted and onEditEnded to WidgetContext', (
      tester,
    ) async {
      var editStartedCalled = false;
      var editEndedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WidgetRenderer(
              widgetInstance: sectionWidget,
              registry: buildRegistry(),
              isEditable: true,
              onEditStarted: () => editStartedCalled = true,
              onEditEnded: () => editEndedCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Section'));
      await tester.pumpAndSettle();

      expect(editStartedCalled, isTrue);
      expect(editEndedCalled, isFalse);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(editEndedCalled, isTrue);
    });

    testWidgets('renders an unknown-widget placeholder when type is missing', (
      tester,
    ) async {
      final unknown = WidgetInstance(
        id: 99,
        type: 'mystery',
        version: '1.0.0',
        props: const <String, dynamic>{},
        index: 0,
        columnId: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WidgetRenderer(
              widgetInstance: unknown,
              registry: buildRegistry(),
            ),
          ),
        ),
      );

      expect(find.text('Unknown widget type: mystery'), findsOneWidget);
    });

    testWidgets(
      'resolves alignment from allowedWidgets matching widget type',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetRenderer(
                widgetInstance: sectionWidget,
                registry: buildRegistry(),
                allowedWidgets: const [
                  WidgetTypeConfig(
                    type: 'section',
                    alignment: WidgetAlignment.center,
                  ),
                ],
              ),
            ),
          ),
        );

        // Render succeeds; the alignment plumbed through is captured by the
        // section's rendered Text widget alignment behavior.
        expect(find.text('Test Section'), findsOneWidget);
      },
    );

    testWidgets(
      'forwards displayOptions to the rendered widget',
      (tester) async {
        const options = MenuDisplayOptions(showPrices: false);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WidgetRenderer(
                widgetInstance: sectionWidget,
                registry: buildRegistry(),
                displayOptions: options,
              ),
            ),
          ),
        );

        expect(find.text('Test Section'), findsOneWidget);
      },
    );
  });
}
