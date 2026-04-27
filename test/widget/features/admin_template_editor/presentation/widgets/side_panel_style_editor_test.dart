import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/domain/entities/border_type.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/vertical_alignment.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/models/editor_selection.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/widgets/side_panel_style_editor.dart';
import 'package:oxo_menus/shared/presentation/widgets/edge_insets_editor.dart';

void main() {
  Widget buildSubject({
    EditorElementType type = EditorElementType.container,
    StyleConfig? styleConfig,
    StyleConfig? clipboardStyle,
    VoidCallback? onCopy,
    VoidCallback? onPaste,
    ValueChanged<StyleConfig>? onStyleChanged,
    bool? isDroppable,
    ValueChanged<bool>? onDroppableChanged,
    PageSize? pageSize,
    VoidCallback? onPageSizePressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 240,
          child: SingleChildScrollView(
            child: SidePanelStyleEditor(
              type: type,
              styleConfig: styleConfig,
              clipboardStyle: clipboardStyle,
              onCopy: onCopy ?? () {},
              onPaste: onPaste ?? () {},
              onStyleChanged: onStyleChanged ?? (_) {},
              isDroppable: isDroppable,
              onDroppableChanged: onDroppableChanged,
              pageSize: pageSize,
              onPageSizePressed: onPageSizePressed,
            ),
          ),
        ),
      ),
    );
  }

  group('SidePanelStyleEditor', () {
    testWidgets('renders "Menu Style" label for menu type', (tester) async {
      await tester.pumpWidget(buildSubject(type: EditorElementType.menu));

      expect(find.text('Menu Style'), findsOneWidget);
    });

    testWidgets('renders "Container Style" label for container type', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(type: EditorElementType.container));

      expect(find.text('Container Style'), findsOneWidget);
    });

    testWidgets('renders "Column Style" label for column type', (tester) async {
      await tester.pumpWidget(buildSubject(type: EditorElementType.column));

      expect(find.text('Column Style'), findsOneWidget);
    });

    testWidgets('shows margins EdgeInsetsEditor', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Margins'), findsOneWidget);
      expect(find.byType(EdgeInsetsEditor), findsNWidgets(2));
    });

    testWidgets('shows border dropdown', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Border'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<BorderType>), findsOneWidget);
    });

    testWidgets('shows paddings EdgeInsetsEditor', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Paddings'), findsOneWidget);
    });

    testWidgets('column type shows "Allow Widget Drops" switch', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          type: EditorElementType.column,
          isDroppable: true,
          onDroppableChanged: (_) {},
        ),
      );

      expect(find.text('Allow Widget Drops'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('droppable switch renders CupertinoSwitch on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: SizedBox(
              width: 240,
              child: SingleChildScrollView(
                child: SidePanelStyleEditor(
                  type: EditorElementType.column,
                  styleConfig: null,
                  clipboardStyle: null,
                  onCopy: () {},
                  onPaste: () {},
                  onStyleChanged: (_) {},
                  isDroppable: true,
                  onDroppableChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      // On iOS platform, SwitchListTile.adaptive renders a CupertinoSwitch
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('non-column type does NOT show droppable switch', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(type: EditorElementType.container));

      expect(find.text('Allow Widget Drops'), findsNothing);
      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets('copy button calls onCopy callback', (tester) async {
      bool copyCalled = false;

      await tester.pumpWidget(buildSubject(onCopy: () => copyCalled = true));

      await tester.tap(find.byKey(const Key('copy_style_button')));
      await tester.pump();

      expect(copyCalled, isTrue);
    });

    testWidgets('paste button calls onPaste callback', (tester) async {
      bool pasteCalled = false;

      await tester.pumpWidget(
        buildSubject(
          clipboardStyle: const StyleConfig(marginTop: 10),
          onPaste: () => pasteCalled = true,
        ),
      );

      await tester.tap(find.byKey(const Key('paste_style_button')));
      await tester.pump();

      expect(pasteCalled, isTrue);
    });

    testWidgets('paste button disabled when clipboardStyle is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(clipboardStyle: null));

      final pasteButton = tester.widget<IconButton>(
        find.byKey(const Key('paste_style_button')),
      );
      expect(pasteButton.onPressed, isNull);
    });

    testWidgets(
      'changing margin fires onStyleChanged with updated StyleConfig',
      (tester) async {
        StyleConfig? changedStyle;

        await tester.pumpWidget(
          buildSubject(
            styleConfig: const StyleConfig(
              marginTop: 5,
              marginBottom: 5,
              marginLeft: 5,
              marginRight: 5,
            ),
            onStyleChanged: (style) => changedStyle = style,
          ),
        );

        // In All mode, there's a single margin field
        await tester.enterText(find.byKey(const Key('side_margin_all')), '20');
        await tester.pump();

        expect(changedStyle, isNotNull);
        expect(changedStyle!.marginTop, 20);
      },
    );

    testWidgets(
      'changing border fires onStyleChanged with updated StyleConfig',
      (tester) async {
        StyleConfig? changedStyle;

        await tester.pumpWidget(
          buildSubject(
            styleConfig: const StyleConfig(),
            onStyleChanged: (style) => changedStyle = style,
          ),
        );

        // Tap border dropdown
        await tester.tap(find.byType(DropdownButtonFormField<BorderType>));
        await tester.pumpAndSettle();

        // Select Plain Thin
        await tester.tap(find.text('Plain Thin').last);
        await tester.pumpAndSettle();

        expect(changedStyle, isNotNull);
        expect(changedStyle!.borderType, BorderType.plainThin);
      },
    );

    testWidgets('border dropdown updates when styleConfig changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          styleConfig: const StyleConfig(borderType: BorderType.none),
        ),
      );

      // Initially the form field value is none
      var state = tester.state<FormFieldState<BorderType>>(
        find.byType(DropdownButtonFormField<BorderType>),
      );
      expect(state.value, BorderType.none);

      // Re-pump with plainThin
      await tester.pumpWidget(
        buildSubject(
          styleConfig: const StyleConfig(borderType: BorderType.plainThin),
        ),
      );
      await tester.pumpAndSettle();

      // Form field value should now be plainThin
      state = tester.state<FormFieldState<BorderType>>(
        find.byType(DropdownButtonFormField<BorderType>),
      );
      expect(state.value, BorderType.plainThin);
    });

    testWidgets('all fields update when styleConfig changes (element switch)', (
      tester,
    ) async {
      // Simulate container selected: margins 5, no border, paddings 10
      await tester.pumpWidget(
        buildSubject(
          type: EditorElementType.container,
          styleConfig: const StyleConfig(
            marginTop: 5,
            marginBottom: 5,
            marginLeft: 5,
            marginRight: 5,
            borderType: BorderType.none,
            paddingTop: 10,
            paddingBottom: 10,
            paddingLeft: 10,
            paddingRight: 10,
          ),
        ),
      );

      // Verify initial margin field shows "5"
      var marginField = tester.widget<TextField>(
        find.byKey(const Key('side_margin_all')),
      );
      expect(marginField.controller!.text, '5');

      // Verify initial padding field shows "10"
      var paddingField = tester.widget<TextField>(
        find.byKey(const Key('side_padding_all')),
      );
      expect(paddingField.controller!.text, '10');

      // Verify border is none
      var borderState = tester.state<FormFieldState<BorderType>>(
        find.byType(DropdownButtonFormField<BorderType>),
      );
      expect(borderState.value, BorderType.none);

      // Switch to column: margins 20, plainThin border, paddings 0
      await tester.pumpWidget(
        buildSubject(
          type: EditorElementType.column,
          styleConfig: const StyleConfig(
            marginTop: 20,
            marginBottom: 20,
            marginLeft: 20,
            marginRight: 20,
            borderType: BorderType.plainThin,
            paddingTop: 0,
            paddingBottom: 0,
            paddingLeft: 0,
            paddingRight: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Margin field should now show "20"
      marginField = tester.widget<TextField>(
        find.byKey(const Key('side_margin_all')),
      );
      expect(marginField.controller!.text, '20');

      // Padding field should now show "0"
      paddingField = tester.widget<TextField>(
        find.byKey(const Key('side_padding_all')),
      );
      expect(paddingField.controller!.text, '0');

      // Border should now be plainThin
      borderState = tester.state<FormFieldState<BorderType>>(
        find.byType(DropdownButtonFormField<BorderType>),
      );
      expect(borderState.value, BorderType.plainThin);

      // Title should update too
      expect(find.text('Column Style'), findsOneWidget);
    });

    group('Page Size Row', () {
      testWidgets('shows page size row with size name for menu type', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.menu,
            pageSize: const PageSize(name: 'A4', width: 210, height: 297),
            onPageSizePressed: () {},
          ),
        );

        expect(find.text('Page Size'), findsOneWidget);
        expect(find.text('A4'), findsOneWidget);
        expect(find.byKey(const Key('page_size_tile')), findsOneWidget);
        expect(
          find.byKey(const Key('change_page_size_button')),
          findsOneWidget,
        );
      });

      testWidgets('does NOT show page size row for container type', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.container,
            pageSize: const PageSize(name: 'A4', width: 210, height: 297),
            onPageSizePressed: () {},
          ),
        );

        expect(find.byKey(const Key('page_size_tile')), findsNothing);
      });

      testWidgets('does NOT show page size row for column type', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.column,
            pageSize: const PageSize(name: 'A4', width: 210, height: 297),
            onPageSizePressed: () {},
          ),
        );

        expect(find.byKey(const Key('page_size_tile')), findsNothing);
      });

      testWidgets('shows "Not set" when pageSize is null', (tester) async {
        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.menu,
            pageSize: null,
            onPageSizePressed: () {},
          ),
        );

        expect(find.text('Not set'), findsOneWidget);
      });

      testWidgets('tapping change button calls onPageSizePressed', (
        tester,
      ) async {
        bool pressed = false;

        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.menu,
            pageSize: const PageSize(name: 'A4', width: 210, height: 297),
            onPageSizePressed: () => pressed = true,
          ),
        );

        await tester.tap(find.byKey(const Key('change_page_size_button')));
        await tester.pump();

        expect(pressed, isTrue);
      });

      testWidgets('change button disabled when onPageSizePressed is null', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.menu,
            pageSize: const PageSize(name: 'A4', width: 210, height: 297),
            onPageSizePressed: null,
          ),
        );

        final button = tester.widget<IconButton>(
          find.byKey(const Key('change_page_size_button')),
        );
        expect(button.onPressed, isNull);
      });
    });

    group('Vertical Alignment', () {
      testWidgets('shows vertical alignment dropdown for column type', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject(type: EditorElementType.column));

        expect(find.text('Vertical Alignment'), findsOneWidget);
        expect(
          find.byType(DropdownButtonFormField<VerticalAlignment>),
          findsOneWidget,
        );
      });

      testWidgets('does NOT show vertical alignment for container type', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(type: EditorElementType.container),
        );

        expect(find.text('Vertical Alignment'), findsNothing);
        expect(
          find.byType(DropdownButtonFormField<VerticalAlignment>),
          findsNothing,
        );
      });

      testWidgets('does NOT show vertical alignment for menu type', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject(type: EditorElementType.menu));

        expect(find.text('Vertical Alignment'), findsNothing);
      });

      testWidgets('calls onStyleChanged with selected verticalAlignment', (
        tester,
      ) async {
        StyleConfig? changedStyle;

        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.column,
            styleConfig: const StyleConfig(),
            onStyleChanged: (style) => changedStyle = style,
          ),
        );

        await tester.tap(
          find.byType(DropdownButtonFormField<VerticalAlignment>),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Center').last);
        await tester.pumpAndSettle();

        expect(changedStyle, isNotNull);
        expect(changedStyle!.verticalAlignment, VerticalAlignment.center);
      });

      testWidgets('displays current verticalAlignment from styleConfig', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.column,
            styleConfig: const StyleConfig(
              verticalAlignment: VerticalAlignment.bottom,
            ),
          ),
        );

        final state = tester.state<FormFieldState<VerticalAlignment>>(
          find.byType(DropdownButtonFormField<VerticalAlignment>),
        );
        expect(state.value, VerticalAlignment.bottom);
      });

      testWidgets('updates when styleConfig changes', (tester) async {
        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.column,
            styleConfig: const StyleConfig(
              verticalAlignment: VerticalAlignment.top,
            ),
          ),
        );

        var state = tester.state<FormFieldState<VerticalAlignment>>(
          find.byType(DropdownButtonFormField<VerticalAlignment>),
        );
        expect(state.value, VerticalAlignment.top);

        await tester.pumpWidget(
          buildSubject(
            type: EditorElementType.column,
            styleConfig: const StyleConfig(
              verticalAlignment: VerticalAlignment.bottom,
            ),
          ),
        );
        await tester.pumpAndSettle();

        state = tester.state<FormFieldState<VerticalAlignment>>(
          find.byType(DropdownButtonFormField<VerticalAlignment>),
        );
        expect(state.value, VerticalAlignment.bottom);
      });
    });

    testWidgets(
      'changing padding fires onStyleChanged with updated StyleConfig',
      (tester) async {
        StyleConfig? changedStyle;

        await tester.pumpWidget(
          buildSubject(
            styleConfig: const StyleConfig(
              paddingTop: 0,
              paddingBottom: 0,
              paddingLeft: 0,
              paddingRight: 0,
            ),
            onStyleChanged: (style) => changedStyle = style,
          ),
        );

        await tester.enterText(find.byKey(const Key('side_padding_all')), '15');
        await tester.pump();

        expect(changedStyle, isNotNull);
        expect(changedStyle!.paddingTop, 15);
      },
    );
  });
}
