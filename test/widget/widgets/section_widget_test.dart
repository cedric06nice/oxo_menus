import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/widgets/section_widget/section_widget.dart';

void main() {
  group('SectionWidget', () {
    testWidgets('should display section title', (tester) async {
      const props = SectionProps(title: 'Appetizers');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Appetizers'), findsOneWidget);
    });

    testWidgets('should display title in uppercase when uppercase is true', (
      tester,
    ) async {
      const props = SectionProps(title: 'Appetizers', uppercase: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('APPETIZERS'), findsOneWidget);
      expect(find.text('Appetizers'), findsNothing);
    });

    testWidgets('should not uppercase title when uppercase is false', (
      tester,
    ) async {
      const props = SectionProps(title: 'Main Courses', uppercase: false);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Main Courses'), findsOneWidget);
      expect(find.text('MAIN COURSES'), findsNothing);
    });

    testWidgets('should show divider when showDivider is true', (tester) async {
      const props = SectionProps(title: 'Desserts', showDivider: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('should hide divider when showDivider is false', (
      tester,
    ) async {
      const props = SectionProps(title: 'Beverages', showDivider: false);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('should open edit dialog when tapped in editable mode', (
      tester,
    ) async {
      const props = SectionProps(title: 'Sides');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sides'));
      await tester.pumpAndSettle();

      // Edit dialog should appear
      expect(find.text('Edit Section'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should not open edit dialog in non-editable mode', (
      tester,
    ) async {
      const props = SectionProps(title: 'Salads');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Salads'));
      await tester.pumpAndSettle();

      // Edit dialog should NOT appear
      expect(find.text('Edit Section'), findsNothing);
    });

    testWidgets('should call onUpdate with updated props when saved', (
      tester,
    ) async {
      const props = SectionProps(title: 'Original Title');

      Map<String, dynamic>? capturedUpdate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(
                isEditable: true,
                onUpdate: (updatedProps) => capturedUpdate = updatedProps,
              ),
            ),
          ),
        ),
      );

      // Tap to open edit dialog
      await tester.tap(find.text('Original Title'));
      await tester.pumpAndSettle();

      // Verify dialog opened
      expect(find.text('Edit Section'), findsOneWidget);

      // Modify the title
      final titleField = find.byType(TextField);
      await tester.enterText(titleField, 'Updated Title');

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify onUpdate was called
      expect(capturedUpdate, isNotNull);
      expect(capturedUpdate!['title'], 'Updated Title');
    });

    testWidgets(
      'should call onEditStarted before and onEditEnded after edit dialog',
      (tester) async {
        const props = SectionProps(title: 'Sides');
        var editStartedCount = 0;
        var editEndedCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SectionWidget(
                props: props,
                context: WidgetContext(
                  isEditable: true,
                  onEditStarted: () => editStartedCount++,
                  onEditEnded: () => editEndedCount++,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Sides'));
        await tester.pumpAndSettle();

        expect(editStartedCount, 1);
        expect(editEndedCount, 0);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(editEndedCount, 1);
      },
    );

    testWidgets('should render title with LibreBaskerville font at size 17', (
      tester,
    ) async {
      const props = SectionProps(title: 'Test Section');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test Section'));
      expect(textWidget.style?.fontFamily, 'LibreBaskerville');
      expect(textWidget.style?.fontSize, 17);
    });

    testWidgets('should handle both uppercase and divider options', (
      tester,
    ) async {
      const props = SectionProps(
        title: 'featured items',
        uppercase: true,
        showDivider: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('FEATURED ITEMS'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
