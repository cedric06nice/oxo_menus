import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/widgets/page_style_section.dart';

void main() {
  group('PageStyleSection', () {
    testWidgets('should display section headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(),
                onStyleChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Page Style'), findsOneWidget);
      expect(find.text('Margins'), findsOneWidget);
      expect(find.text('Paddings'), findsOneWidget);
    });

    testWidgets('should display current margin values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(
                  marginTop: 20.0,
                  marginBottom: 30.0,
                  marginLeft: 15.0,
                  marginRight: 15.0,
                ),
                onStyleChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final marginTopField = tester.widget<TextField>(
        find.byKey(const Key('margin_top')),
      );
      expect(marginTopField.controller?.text, '20');

      final marginBottomField = tester.widget<TextField>(
        find.byKey(const Key('margin_bottom')),
      );
      expect(marginBottomField.controller?.text, '30');
    });

    testWidgets('should display current padding values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(
                  paddingTop: 10.0,
                  paddingBottom: 12.0,
                  paddingLeft: 8.0,
                  paddingRight: 8.0,
                ),
                onStyleChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final paddingTopField = tester.widget<TextField>(
        find.byKey(const Key('padding_top')),
      );
      expect(paddingTopField.controller?.text, '10');
    });

    testWidgets('should display empty fields when styleConfig is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: null,
                onStyleChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Page Style'), findsOneWidget);
      final marginAllField = tester.widget<TextField>(
        find.byKey(const Key('margin_all')),
      );
      expect(marginAllField.controller?.text, '');
    });

    testWidgets('should call onStyleChanged when margin all is edited', (
      tester,
    ) async {
      StyleConfig? updatedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(),
                onStyleChanged: (config) => updatedConfig = config,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('margin_all')), '25');
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.marginTop, 25.0);
      expect(updatedConfig!.marginBottom, 25.0);
      expect(updatedConfig!.marginLeft, 25.0);
      expect(updatedConfig!.marginRight, 25.0);
    });

    testWidgets('should call onStyleChanged when padding all is edited', (
      tester,
    ) async {
      StyleConfig? updatedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(),
                onStyleChanged: (config) => updatedConfig = config,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('padding_all')), '12');
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.paddingTop, 12.0);
      expect(updatedConfig!.paddingBottom, 12.0);
      expect(updatedConfig!.paddingLeft, 12.0);
      expect(updatedConfig!.paddingRight, 12.0);
    });

    testWidgets('should display Border section header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(),
                onStyleChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Border'), findsOneWidget);
    });

    testWidgets('should show current border type in dropdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(
                  borderType: BorderType.plainThin,
                ),
                onStyleChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // The dropdown should display the label of the current border type
      expect(find.text('Plain Thin'), findsOneWidget);
    });

    testWidgets('should default to No Border when borderType is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(),
                onStyleChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('No Border'), findsOneWidget);
    });

    testWidgets('should display custom title when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                title: 'Container Style',
                styleConfig: const StyleConfig(),
                onStyleChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Container Style'), findsOneWidget);
      expect(find.text('Page Style'), findsNothing);
    });

    testWidgets('should call onStyleChanged when border type is changed', (
      tester,
    ) async {
      StyleConfig? updatedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PageStyleSection(
                styleConfig: const StyleConfig(),
                onStyleChanged: (config) => updatedConfig = config,
              ),
            ),
          ),
        ),
      );

      // Tap the dropdown to open it
      await tester.tap(find.byKey(const Key('border_type')));
      await tester.pumpAndSettle();

      // Select 'Drop Shadow'
      await tester.tap(find.text('Drop Shadow').last);
      await tester.pumpAndSettle();

      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.borderType, BorderType.dropShadow);
    });
  });
}
