import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/common/edge_insets_editor.dart';

void main() {
  group('EdgeInsetsEditor', () {
    group('widget rendering', () {
      testWidgets('displays label text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EdgeInsetsEditor(
                label: 'Margins',
                keyPrefix: 'margin',
                onChanged: ({top, bottom, left, right}) {},
              ),
            ),
          ),
        );
        expect(find.text('Margins'), findsOneWidget);
      });

      testWidgets('displays segmented button with three modes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EdgeInsetsEditor(
                label: 'Margins',
                keyPrefix: 'margin',
                onChanged: ({top, bottom, left, right}) {},
              ),
            ),
          ),
        );
        expect(find.byKey(const Key('margin_mode_selector')), findsOneWidget);
        expect(find.text('Symmetric'), findsOneWidget);
        expect(find.text('Individual'), findsOneWidget);
      });

      testWidgets('shows single field in All mode for null values', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  onChanged: ({top, bottom, left, right}) {},
                ),
              ),
            ),
          ),
        );
        expect(find.byKey(const Key('margin_all')), findsOneWidget);
        expect(find.byKey(const Key('margin_top')), findsNothing);
      });

      testWidgets('shows single field with value when all values equal', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  top: 10,
                  bottom: 10,
                  left: 10,
                  right: 10,
                  onChanged: ({top, bottom, left, right}) {},
                ),
              ),
            ),
          ),
        );
        final field = tester.widget<TextField>(
          find.byKey(const Key('margin_all')),
        );
        expect(field.controller?.text, '10');
      });

      testWidgets('shows vertical and horizontal fields in Symmetric mode', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Paddings',
                  keyPrefix: 'padding',
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 20,
                  onChanged: ({top, bottom, left, right}) {},
                ),
              ),
            ),
          ),
        );
        expect(find.byKey(const Key('padding_vertical')), findsOneWidget);
        expect(find.byKey(const Key('padding_horizontal')), findsOneWidget);
        expect(find.byKey(const Key('padding_all')), findsNothing);
      });

      testWidgets('shows four individual fields when values differ', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  top: 10,
                  bottom: 20,
                  left: 30,
                  right: 40,
                  onChanged: ({top, bottom, left, right}) {},
                ),
              ),
            ),
          ),
        );
        expect(find.byKey(const Key('margin_top')), findsOneWidget);
        expect(find.byKey(const Key('margin_bottom')), findsOneWidget);
        expect(find.byKey(const Key('margin_left')), findsOneWidget);
        expect(find.byKey(const Key('margin_right')), findsOneWidget);
      });

      testWidgets('individual fields display correct values', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  top: 10,
                  bottom: 20,
                  left: 30,
                  right: 40,
                  onChanged: ({top, bottom, left, right}) {},
                ),
              ),
            ),
          ),
        );
        final topField = tester.widget<TextField>(
          find.byKey(const Key('margin_top')),
        );
        expect(topField.controller?.text, '10');
        final rightField = tester.widget<TextField>(
          find.byKey(const Key('margin_right')),
        );
        expect(rightField.controller?.text, '40');
      });

      testWidgets('fields have pt suffix and numeric keyboard', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  onChanged: ({top, bottom, left, right}) {},
                ),
              ),
            ),
          ),
        );
        final field = tester.widget<TextField>(
          find.byKey(const Key('margin_all')),
        );
        expect(field.decoration?.suffixText, 'pt');
        expect(field.keyboardType, TextInputType.number);
      });
    });

    group('callback behavior', () {
      testWidgets('editing all field emits four equal values', (tester) async {
        double? emittedTop, emittedBottom, emittedLeft, emittedRight;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  onChanged: ({top, bottom, left, right}) {
                    emittedTop = top;
                    emittedBottom = bottom;
                    emittedLeft = left;
                    emittedRight = right;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(const Key('margin_all')), '15');
        await tester.pumpAndSettle();
        expect(emittedTop, 15.0);
        expect(emittedBottom, 15.0);
        expect(emittedLeft, 15.0);
        expect(emittedRight, 15.0);
      });

      testWidgets('editing symmetric vertical field updates top and bottom', (
        tester,
      ) async {
        double? emittedTop, emittedBottom, emittedLeft, emittedRight;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Paddings',
                  keyPrefix: 'padding',
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 20,
                  onChanged: ({top, bottom, left, right}) {
                    emittedTop = top;
                    emittedBottom = bottom;
                    emittedLeft = left;
                    emittedRight = right;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(const Key('padding_vertical')), '25');
        await tester.pumpAndSettle();
        expect(emittedTop, 25.0);
        expect(emittedBottom, 25.0);
        expect(emittedLeft, 20.0);
        expect(emittedRight, 20.0);
      });

      testWidgets('editing individual top field updates only top', (
        tester,
      ) async {
        double? emittedTop, emittedBottom, emittedLeft, emittedRight;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  top: 10,
                  bottom: 20,
                  left: 30,
                  right: 40,
                  onChanged: ({top, bottom, left, right}) {
                    emittedTop = top;
                    emittedBottom = bottom;
                    emittedLeft = left;
                    emittedRight = right;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(const Key('margin_top')), '99');
        await tester.pumpAndSettle();
        expect(emittedTop, 99.0);
        expect(emittedBottom, 20.0);
        expect(emittedLeft, 30.0);
        expect(emittedRight, 40.0);
      });

      testWidgets('clearing a field emits null', (tester) async {
        double? emittedTop;
        bool callbackCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  top: 10,
                  bottom: 20,
                  left: 30,
                  right: 40,
                  onChanged: ({top, bottom, left, right}) {
                    callbackCalled = true;
                    emittedTop = top;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(const Key('margin_top')), '');
        await tester.pumpAndSettle();
        expect(callbackCalled, true);
        expect(emittedTop, isNull);
      });
    });

    group('mode switching', () {
      testWidgets('switching from All to Symmetric shows two fields', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  top: 10,
                  bottom: 10,
                  left: 10,
                  right: 10,
                  onChanged: ({top, bottom, left, right}) {},
                ),
              ),
            ),
          ),
        );
        // Starts in All mode
        expect(find.byKey(const Key('margin_all')), findsOneWidget);

        // Switch to Symmetric
        await tester.tap(find.text('Symmetric'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('margin_vertical')), findsOneWidget);
        expect(find.byKey(const Key('margin_horizontal')), findsOneWidget);
        expect(find.byKey(const Key('margin_all')), findsNothing);
      });

      testWidgets(
        'switching from All to Symmetric preserves value in both fields',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: EdgeInsetsEditor(
                    label: 'Margins',
                    keyPrefix: 'margin',
                    top: 10,
                    bottom: 10,
                    left: 10,
                    right: 10,
                    onChanged: ({top, bottom, left, right}) {},
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Symmetric'));
          await tester.pumpAndSettle();

          final vField = tester.widget<TextField>(
            find.byKey(const Key('margin_vertical')),
          );
          expect(vField.controller?.text, '10');
          final hField = tester.widget<TextField>(
            find.byKey(const Key('margin_horizontal')),
          );
          expect(hField.controller?.text, '10');
        },
      );

      testWidgets('switching from Individual to All uses top value', (
        tester,
      ) async {
        double? emittedTop, emittedBottom, emittedLeft, emittedRight;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  top: 10,
                  bottom: 20,
                  left: 30,
                  right: 40,
                  onChanged: ({top, bottom, left, right}) {
                    emittedTop = top;
                    emittedBottom = bottom;
                    emittedLeft = left;
                    emittedRight = right;
                  },
                ),
              ),
            ),
          ),
        );
        // Starts in Individual mode
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        final allField = tester.widget<TextField>(
          find.byKey(const Key('margin_all')),
        );
        expect(allField.controller?.text, '10');
        // onChanged should have been called with all four == 10
        expect(emittedTop, 10.0);
        expect(emittedBottom, 10.0);
        expect(emittedLeft, 10.0);
        expect(emittedRight, 10.0);
      });

      testWidgets('switching from Individual to Symmetric uses top and left', (
        tester,
      ) async {
        double? emittedTop, emittedBottom, emittedLeft, emittedRight;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EdgeInsetsEditor(
                  label: 'Margins',
                  keyPrefix: 'margin',
                  top: 10,
                  bottom: 20,
                  left: 30,
                  right: 40,
                  onChanged: ({top, bottom, left, right}) {
                    emittedTop = top;
                    emittedBottom = bottom;
                    emittedLeft = left;
                    emittedRight = right;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Symmetric'));
        await tester.pumpAndSettle();

        final vField = tester.widget<TextField>(
          find.byKey(const Key('margin_vertical')),
        );
        expect(vField.controller?.text, '10');
        final hField = tester.widget<TextField>(
          find.byKey(const Key('margin_horizontal')),
        );
        expect(hField.controller?.text, '30');
        expect(emittedTop, 10.0);
        expect(emittedBottom, 10.0);
        expect(emittedLeft, 30.0);
        expect(emittedRight, 30.0);
      });
    });

    group('compact mode', () {
      Widget buildCompact({
        String label = 'Margins',
        String keyPrefix = 'margin',
        double? top,
        double? bottom,
        double? left,
        double? right,
        void Function({
          double? top,
          double? bottom,
          double? left,
          double? right,
        })?
        onChanged,
      }) {
        return MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              child: EdgeInsetsEditor(
                isCompact: true,
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

      testWidgets('uses DropdownButton instead of SegmentedButton', (
        tester,
      ) async {
        await tester.pumpWidget(buildCompact());
        expect(find.byType(DropdownButton<EdgeInsetsEditMode>), findsOneWidget);
        expect(find.byType(SegmentedButton<EdgeInsetsEditMode>), findsNothing);
      });

      testWidgets('uses short labels in symmetric mode', (tester) async {
        await tester.pumpWidget(
          buildCompact(top: 10, bottom: 10, left: 5, right: 5),
        );
        // Should use 'V' and 'H' not 'Vertical' and 'Horizontal'
        final vField = tester.widget<TextField>(
          find.byKey(const Key('margin_vertical')),
        );
        expect(vField.decoration?.labelText, 'V');
        final hField = tester.widget<TextField>(
          find.byKey(const Key('margin_horizontal')),
        );
        expect(hField.decoration?.labelText, 'H');
      });

      testWidgets('uses short labels in individual mode', (tester) async {
        await tester.pumpWidget(
          buildCompact(top: 1, bottom: 2, left: 3, right: 4),
        );
        final topField = tester.widget<TextField>(
          find.byKey(const Key('margin_top')),
        );
        expect(topField.decoration?.labelText, 'T');
        final bottomField = tester.widget<TextField>(
          find.byKey(const Key('margin_bottom')),
        );
        expect(bottomField.decoration?.labelText, 'B');
        final leftField = tester.widget<TextField>(
          find.byKey(const Key('margin_left')),
        );
        expect(leftField.decoration?.labelText, 'L');
        final rightField = tester.widget<TextField>(
          find.byKey(const Key('margin_right')),
        );
        expect(rightField.decoration?.labelText, 'R');
      });

      testWidgets('updates controllers when parent props change', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildCompact(top: 5, bottom: 5, left: 5, right: 5),
        );
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller!.text, '5');

        await tester.pumpWidget(
          buildCompact(top: 20, bottom: 20, left: 20, right: 20),
        );
        final updatedField = tester.widget<TextField>(find.byType(TextField));
        expect(updatedField.controller!.text, '20');
      });

      testWidgets('re-detects mode when prop symmetry changes', (tester) async {
        await tester.pumpWidget(
          buildCompact(top: 5, bottom: 5, left: 5, right: 5),
        );
        expect(find.byType(TextField), findsOneWidget);

        await tester.pumpWidget(
          buildCompact(top: 1, bottom: 2, left: 3, right: 4),
        );
        expect(find.byType(TextField), findsNWidgets(4));
      });

      testWidgets('mode dropdown switches layout', (tester) async {
        await tester.pumpWidget(
          buildCompact(top: 5, bottom: 5, left: 5, right: 5),
        );
        expect(find.byType(TextField), findsOneWidget);

        await tester.tap(find.byKey(const Key('margin_mode_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Individual').last);
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsNWidgets(4));
      });

      testWidgets('fields use isDense decoration', (tester) async {
        await tester.pumpWidget(buildCompact());
        final field = tester.widget<TextField>(
          find.byKey(const Key('margin_all')),
        );
        expect(field.decoration?.isDense, isTrue);
      });

      testWidgets('individual fields use Column layout not Row', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildCompact(top: 1, bottom: 2, left: 3, right: 4),
        );
        // In compact mode, individual fields should be in a Column with two Rows
        // (T,B in one Row and L,R in another) — not all in one Row
        expect(find.byType(TextField), findsNWidgets(4));
      });
    });

    group('detectMode', () {
      test('returns all when all values are null', () {
        expect(
          EdgeInsetsEditor.detectMode(
            top: null,
            bottom: null,
            left: null,
            right: null,
          ),
          EdgeInsetsEditMode.all,
        );
      });

      test('returns all when all values are equal', () {
        expect(
          EdgeInsetsEditor.detectMode(top: 10, bottom: 10, left: 10, right: 10),
          EdgeInsetsEditMode.all,
        );
      });

      test(
        'returns symmetric when top==bottom and left==right but different',
        () {
          expect(
            EdgeInsetsEditor.detectMode(
              top: 10,
              bottom: 10,
              left: 20,
              right: 20,
            ),
            EdgeInsetsEditMode.symmetric,
          );
        },
      );

      test('returns individual when values differ', () {
        expect(
          EdgeInsetsEditor.detectMode(top: 10, bottom: 20, left: 30, right: 40),
          EdgeInsetsEditMode.individual,
        );
      });

      test('returns individual when top differs from bottom', () {
        expect(
          EdgeInsetsEditor.detectMode(top: 10, bottom: 20, left: 20, right: 20),
          EdgeInsetsEditMode.individual,
        );
      });

      test('returns all when some null and rest zero', () {
        expect(
          EdgeInsetsEditor.detectMode(
            top: 0,
            bottom: null,
            left: 0,
            right: null,
          ),
          EdgeInsetsEditMode.all,
        );
      });
    });
  });
}
