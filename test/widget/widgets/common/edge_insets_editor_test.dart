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
