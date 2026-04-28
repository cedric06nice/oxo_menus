import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/text_widget/text_widget.dart';

void main() {
  group('TextWidget', () {
    testWidgets('should display text content', (tester) async {
      const props = TextProps(text: 'Welcome to our restaurant');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Welcome to our restaurant'), findsOneWidget);
    });

    testWidgets('should align text to left by default', (tester) async {
      const props = TextProps(text: 'Left aligned text');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Left aligned text'));
      expect(text.textAlign, TextAlign.left);
    });

    testWidgets('should align text to center when align is center', (
      tester,
    ) async {
      const props = TextProps(text: 'Center aligned text', align: 'center');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Center aligned text'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('should align text to right when align is right', (
      tester,
    ) async {
      const props = TextProps(text: 'Right aligned text', align: 'right');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Right aligned text'));
      expect(text.textAlign, TextAlign.right);
    });

    testWidgets('should display text in bold when bold is true', (
      tester,
    ) async {
      const props = TextProps(text: 'Bold text', bold: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Bold text'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should display text in normal weight when bold is false', (
      tester,
    ) async {
      const props = TextProps(text: 'Normal text', bold: false);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Normal text'));
      expect(text.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('should display text in italic when italic is true', (
      tester,
    ) async {
      const props = TextProps(text: 'Italic text', italic: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Italic text'));
      expect(text.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('should display text in normal style when italic is false', (
      tester,
    ) async {
      const props = TextProps(text: 'Normal text', italic: false);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Normal text'));
      expect(text.style?.fontStyle, FontStyle.normal);
    });

    testWidgets('should open edit dialog when tapped in editable mode', (
      tester,
    ) async {
      const props = TextProps(text: 'Editable text');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: true),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SizedBox));
      await tester.pumpAndSettle();

      // Edit dialog should appear
      expect(find.text('Edit Text'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should not open edit dialog in non-editable mode', (
      tester,
    ) async {
      const props = TextProps(text: 'Non-editable text');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SizedBox));
      await tester.pumpAndSettle();

      // Edit dialog should NOT appear
      expect(find.text('Edit Text'), findsNothing);
    });

    testWidgets('should call onUpdate with updated props when saved', (
      tester,
    ) async {
      const props = TextProps(text: 'Original text');

      Map<String, dynamic>? capturedUpdate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextWidget(
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
      await tester.tap(find.byType(SizedBox));
      await tester.pumpAndSettle();

      // Modify the text
      await tester.enterText(
        find.widgetWithText(TextField, 'Text'),
        'Updated text',
      );

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify onUpdate was called
      expect(capturedUpdate, isNotNull);
      expect(capturedUpdate!['text'], 'Updated text');
    });

    testWidgets(
      'should call onEditStarted before and onEditEnded after edit dialog',
      (tester) async {
        const props = TextProps(text: 'Editable text');
        var editStartedCount = 0;
        var editEndedCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextWidget(
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

        await tester.tap(find.byType(SizedBox));
        await tester.pumpAndSettle();

        expect(editStartedCount, 1);
        expect(editEndedCount, 0);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(editEndedCount, 1);
      },
    );

    testWidgets('should render with proper styling', (tester) async {
      const props = TextProps(text: 'Test text');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      // Verify the widget renders a Container
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Test text'), findsOneWidget);
    });

    testWidgets('should handle combined bold and italic', (tester) async {
      const props = TextProps(
        text: 'Bold and italic',
        bold: true,
        italic: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Bold and italic'));
      expect(text.style?.fontWeight, FontWeight.bold);
      expect(text.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('should handle center alignment with bold and italic', (
      tester,
    ) async {
      const props = TextProps(
        text: 'Formatted text',
        align: 'center',
        bold: true,
        italic: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextWidget(
              props: props,
              context: WidgetContext(isEditable: false),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Formatted text'));
      expect(text.textAlign, TextAlign.center);
      expect(text.style?.fontWeight, FontWeight.bold);
      expect(text.style?.fontStyle, FontStyle.italic);
    });
  });
}
