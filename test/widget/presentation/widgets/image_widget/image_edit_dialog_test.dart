import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_edit_dialog.dart';

void main() {
  group('ImageEditDialog', () {
    testWidgets('should display current fileId', (tester) async {
      const props = ImageProps(fileId: 'test-file-123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageEditDialog(props: props, onSave: (_) {}),
          ),
        ),
      );

      expect(find.text('test-file-123'), findsOneWidget);
    });

    testWidgets(
      'should show alignment selector with left/center/right options',
      (tester) async {
        const props = ImageProps(fileId: 'test-file-123', align: 'center');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(props: props, onSave: (_) {}),
            ),
          ),
        );

        // Find the dropdown
        expect(find.byType(DropdownButtonFormField<String>), findsWidgets);

        // Tap the alignment dropdown to open it
        await tester.tap(find.text('Center'));
        await tester.pumpAndSettle();

        // Check that all alignment options are available
        expect(find.text('Left').hitTestable(), findsOneWidget);
        expect(find.text('Center').hitTestable(), findsWidgets);
        expect(find.text('Right').hitTestable(), findsOneWidget);
      },
    );

    testWidgets('should call onSave with updated props when saved', (
      tester,
    ) async {
      const props = ImageProps(fileId: 'original-file');
      ImageProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageEditDialog(
              props: props,
              onSave: (updated) => savedProps = updated,
            ),
          ),
        ),
      );

      // Change alignment
      await tester.tap(find.text('Center'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Left').last);
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify onSave was called with updated props
      expect(savedProps, isNotNull);
      expect(savedProps?.align, 'left');
    });

    testWidgets('should not call onSave when cancelled', (tester) async {
      const props = ImageProps(fileId: 'test-file');
      ImageProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageEditDialog(
              props: props,
              onSave: (updated) => savedProps = updated,
            ),
          ),
        ),
      );

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify onSave was not called
      expect(savedProps, isNull);
    });

    testWidgets('should allow editing width and height', (tester) async {
      const props = ImageProps(fileId: 'test-file');
      ImageProps? savedProps;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageEditDialog(
              props: props,
              onSave: (updated) => savedProps = updated,
            ),
          ),
        ),
      );

      // Enter width
      await tester.enterText(find.widgetWithText(TextField, 'Width'), '200');

      // Enter height
      await tester.enterText(find.widgetWithText(TextField, 'Height'), '150');

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify dimensions were saved
      expect(savedProps?.width, 200.0);
      expect(savedProps?.height, 150.0);
    });
  });
}
