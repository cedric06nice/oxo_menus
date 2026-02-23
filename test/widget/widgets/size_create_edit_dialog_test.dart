import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/widgets/size_create_edit_dialog.dart';

void main() {
  group('SizeCreateEditDialog', () {
    group('create mode', () {
      testWidgets('should show create title', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => SizeCreateEditDialog(onSave: (_) {}),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Create Page Size'), findsOneWidget);
      });

      testWidgets('should have empty fields in create mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => SizeCreateEditDialog(onSave: (_) {}),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Name field should be empty
        final nameField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Name'),
        );
        expect(nameField.controller!.text, isEmpty);
      });

      testWidgets('should disable save button when fields are empty', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => SizeCreateEditDialog(onSave: (_) {}),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final saveButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Save'),
        );
        expect(saveButton.onPressed, isNull);
      });

      testWidgets('should enable save button when all fields are filled', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => SizeCreateEditDialog(onSave: (_) {}),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(find.widgetWithText(TextField, 'Name'), 'A4');
        await tester.enterText(
          find.widgetWithText(TextField, 'Width (mm)'),
          '210',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Height (mm)'),
          '297',
        );
        await tester.pumpAndSettle();

        final saveButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Save'),
        );
        expect(saveButton.onPressed, isNotNull);
      });

      testWidgets('should call onSave with correct data', (tester) async {
        SizeCreateEditResult? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) =>
                        SizeCreateEditDialog(onSave: (r) => result = r),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(find.widgetWithText(TextField, 'Name'), 'A4');
        await tester.enterText(
          find.widgetWithText(TextField, 'Width (mm)'),
          '210',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Height (mm)'),
          '297',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.name, 'A4');
        expect(result!.width, 210.0);
        expect(result!.height, 297.0);
        expect(result!.status, Status.draft);
        expect(result!.direction, 'portrait');
      });
    });

    group('edit mode', () {
      const existingSize = domain.Size(
        id: 1,
        name: 'A4',
        width: 210,
        height: 297,
        status: Status.published,
        direction: 'portrait',
      );

      testWidgets('should show edit title', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => SizeCreateEditDialog(
                      existingSize: existingSize,
                      onSave: (_) {},
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Page Size'), findsOneWidget);
      });

      testWidgets('should pre-populate fields from existing size', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => SizeCreateEditDialog(
                      existingSize: existingSize,
                      onSave: (_) {},
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final nameField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Name'),
        );
        expect(nameField.controller!.text, 'A4');

        final widthField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Width (mm)'),
        );
        expect(widthField.controller!.text, '210.0');

        final heightField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Height (mm)'),
        );
        expect(heightField.controller!.text, '297.0');
      });
    });

    testWidgets('should close dialog on cancel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => SizeCreateEditDialog(onSave: (_) {}),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Create Page Size'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Create Page Size'), findsNothing);
    });
  });
}
