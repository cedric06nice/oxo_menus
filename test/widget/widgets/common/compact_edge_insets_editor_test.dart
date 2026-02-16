import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/common/compact_edge_insets_editor.dart';
import 'package:oxo_menus/presentation/widgets/common/edge_insets_editor.dart';

void main() {
  Widget buildSubject({
    String label = 'Margins',
    String keyPrefix = 'margin',
    double? top,
    double? bottom,
    double? left,
    double? right,
    void Function({double? top, double? bottom, double? left, double? right})?
    onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 240,
          child: CompactEdgeInsetsEditor(
            label: label,
            keyPrefix: keyPrefix,
            top: top,
            bottom: bottom,
            left: left,
            right: right,
            onChanged: onChanged ?? ({top, bottom, left, right}) {},
          ),
        ),
      ),
    );
  }

  group('CompactEdgeInsetsEditor', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(buildSubject(label: 'Paddings'));

      expect(find.text('Paddings'), findsOneWidget);
    });

    testWidgets('All mode: shows single text field', (tester) async {
      // All values equal → All mode
      await tester.pumpWidget(
        buildSubject(top: 5, bottom: 5, left: 5, right: 5),
      );

      // Should show 1 text field
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Symmetric mode: shows 2 text fields (V, H)', (tester) async {
      // top==bottom, left==right but not all equal → Symmetric mode
      await tester.pumpWidget(
        buildSubject(top: 10, bottom: 10, left: 5, right: 5),
      );

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Individual mode: shows 4 text fields (T, B, L, R)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(top: 1, bottom: 2, left: 3, right: 4),
      );

      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets(
      'detects mode from initial values using EdgeInsetsEditor.detectMode',
      (tester) async {
        // All equal → All mode
        final mode = EdgeInsetsEditor.detectMode(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
        );
        expect(mode, EdgeInsetsEditMode.all);

        // Symmetric → Symmetric mode
        final symmetric = EdgeInsetsEditor.detectMode(
          top: 10,
          bottom: 10,
          left: 5,
          right: 5,
        );
        expect(symmetric, EdgeInsetsEditMode.symmetric);

        // Different → Individual mode
        final individual = EdgeInsetsEditor.detectMode(
          top: 1,
          bottom: 2,
          left: 3,
          right: 4,
        );
        expect(individual, EdgeInsetsEditMode.individual);
      },
    );

    testWidgets('changing a field fires onChanged with correct values', (
      tester,
    ) async {
      double? changedTop;

      await tester.pumpWidget(
        buildSubject(
          top: 5,
          bottom: 5,
          left: 5,
          right: 5,
          onChanged: ({top, bottom, left, right}) {
            changedTop = top;
          },
        ),
      );

      // In All mode, one text field
      await tester.enterText(find.byType(TextField), '20');
      await tester.pump();

      expect(changedTop, 20);
    });

    testWidgets('mode dropdown switches layout', (tester) async {
      await tester.pumpWidget(
        buildSubject(top: 5, bottom: 5, left: 5, right: 5),
      );

      // Starts in All mode with 1 field
      expect(find.byType(TextField), findsOneWidget);

      // Find and tap the dropdown
      await tester.tap(find.byKey(const Key('margin_mode_dropdown')));
      await tester.pumpAndSettle();

      // Select Individual
      await tester.tap(find.text('Individual').last);
      await tester.pumpAndSettle();

      // Should now show 4 fields
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('uses DropdownButton instead of SegmentedButton', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(DropdownButton<EdgeInsetsEditMode>), findsOneWidget);
      expect(find.byType(SegmentedButton<EdgeInsetsEditMode>), findsNothing);
    });

    testWidgets('updates displayed values when parent props change', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(top: 5, bottom: 5, left: 5, right: 5),
      );

      // In All mode, single field should show "5"
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '5');

      // Re-pump with new values
      await tester.pumpWidget(
        buildSubject(top: 20, bottom: 20, left: 20, right: 20),
      );

      final updatedField = tester.widget<TextField>(find.byType(TextField));
      expect(updatedField.controller!.text, '20');
    });

    testWidgets(
      're-detects mode when new prop values have different symmetry',
      (tester) async {
        // Start with All mode (all equal)
        await tester.pumpWidget(
          buildSubject(top: 5, bottom: 5, left: 5, right: 5),
        );
        expect(find.byType(TextField), findsOneWidget);

        // Switch to Individual mode (all different)
        await tester.pumpWidget(
          buildSubject(top: 1, bottom: 2, left: 3, right: 4),
        );
        expect(find.byType(TextField), findsNWidgets(4));
      },
    );
  });
}
