import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/editor_column_card.dart';

void main() {
  late PresentableWidgetRegistry registry;

  setUp(() {
    registry = PresentableWidgetRegistry();
  });

  Widget buildTestWidget({
    entity.Column? column,
    List<WidgetInstance> widgets = const [],
    bool isSelected = false,
    Widget? header,
    VoidCallback? onTap,
    Widget Function(WidgetInstance widget, int columnId)? widgetItemBuilder,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: EditorColumnCard(
          column:
              column ?? const entity.Column(id: 1, containerId: 1, index: 0),
          widgets: widgets,
          registry: registry,
          isSelected: isSelected,
          header: header,
          onTap: onTap,
          onWidgetDrop: (type, colId, idx) async {},
          onWidgetMove: (w, srcCol, tgtCol, idx) async {},
          widgetItemBuilder:
              widgetItemBuilder ?? (w, colId) => Text('Widget ${w.id}'),
        ),
      ),
    );
  }

  group('EditorColumnCard', () {
    testWidgets('renders with column key', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byKey(const Key('column_1')), findsOneWidget);
    });

    testWidgets('shows "Drop widgets here" when no widgets', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Drop widgets here'), findsOneWidget);
    });

    testWidgets('shows "Drop widgets here" at each drop position with widgets', (
      tester,
    ) async {
      const widget1 = WidgetInstance(
        id: 10,
        columnId: 1,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );
      const widget2 = WidgetInstance(
        id: 11,
        columnId: 1,
        type: 'text',
        version: '1.0',
        index: 1,
        props: {},
      );

      await tester.pumpWidget(buildTestWidget(widgets: [widget1, widget2]));
      await tester.pump();

      // 3 drop zones: before widget1, between widget1 and widget2, after widget2
      expect(find.text('Drop widgets here'), findsNWidgets(3));
    });

    testWidgets('renders widget items via builder', (tester) async {
      const widget1 = WidgetInstance(
        id: 10,
        columnId: 1,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );
      const widget2 = WidgetInstance(
        id: 11,
        columnId: 1,
        type: 'text',
        version: '1.0',
        index: 1,
        props: {},
      );

      await tester.pumpWidget(buildTestWidget(widgets: [widget1, widget2]));
      await tester.pump();

      expect(find.text('Widget 10'), findsOneWidget);
      expect(find.text('Widget 11'), findsOneWidget);
    });

    testWidgets('shows selected border when isSelected', (tester) async {
      await tester.pumpWidget(buildTestWidget(isSelected: true));
      await tester.pump();

      final container = tester.widget<Container>(
        find.byKey(const Key('column_1')),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      final border = decoration.border as Border;
      expect(border.top.width, 2);
    });

    testWidgets('shows default border when not selected', (tester) async {
      await tester.pumpWidget(buildTestWidget(isSelected: false));
      await tester.pump();

      final container = tester.widget<Container>(
        find.byKey(const Key('column_1')),
      );
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.width, 1);
    });

    testWidgets('renders header widget when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(header: const Text('Column Header')),
      );
      await tester.pump();

      expect(find.text('Column Header'), findsOneWidget);
    });

    testWidgets('wraps in GestureDetector when onTap provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(onTap: () => tapped = true));
      await tester.pump();

      // Tap on the column card
      await tester.tap(find.byKey(const Key('column_1')));
      expect(tapped, isTrue);
    });

    testWidgets('shows non-droppable state for locked column', (tester) async {
      const lockedColumn = entity.Column(
        id: 2,
        containerId: 1,
        index: 0,
        isDroppable: false,
      );

      await tester.pumpWidget(buildTestWidget(column: lockedColumn));
      await tester.pump();

      // Locked empty column shows lock icon
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Drop widgets here'), findsNothing);
    });

    testWidgets('uses CrossAxisAlignment.stretch for outer Column', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final container = tester.widget<Container>(
        find.byKey(const Key('column_1')),
      );
      final outerColumn = container.child as Column;
      expect(outerColumn.crossAxisAlignment, CrossAxisAlignment.stretch);
    });

    testWidgets('uses CrossAxisAlignment.stretch for droppable content Column', (
      tester,
    ) async {
      const widget1 = WidgetInstance(
        id: 10,
        columnId: 1,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );

      await tester.pumpWidget(buildTestWidget(widgets: [widget1]));
      await tester.pump();

      // The droppable content Column is a child of the outer Column
      final container = tester.widget<Container>(
        find.byKey(const Key('column_1')),
      );
      final outerColumn = container.child as Column;
      // Find the inner Column (droppable content) among outer Column's children
      final innerColumns = outerColumn.children.whereType<Column>().toList();
      expect(innerColumns, isNotEmpty);
      expect(innerColumns.first.crossAxisAlignment, CrossAxisAlignment.stretch);
    });

    testWidgets(
      'uses CrossAxisAlignment.stretch for non-droppable content Column',
      (tester) async {
        const lockedColumn = entity.Column(
          id: 2,
          containerId: 1,
          index: 0,
          isDroppable: false,
        );

        await tester.pumpWidget(buildTestWidget(column: lockedColumn));
        await tester.pump();

        final container = tester.widget<Container>(
          find.byKey(const Key('column_2')),
        );
        final outerColumn = container.child as Column;
        final innerColumns = outerColumn.children.whereType<Column>().toList();
        expect(innerColumns, isNotEmpty);
        expect(
          innerColumns.first.crossAxisAlignment,
          CrossAxisAlignment.stretch,
        );
      },
    );

    testWidgets('renders widgets in non-droppable column without drop zones', (
      tester,
    ) async {
      const lockedColumn = entity.Column(
        id: 2,
        containerId: 1,
        index: 0,
        isDroppable: false,
      );
      const widget1 = WidgetInstance(
        id: 10,
        columnId: 2,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );

      await tester.pumpWidget(
        buildTestWidget(column: lockedColumn, widgets: [widget1]),
      );
      await tester.pump();

      expect(find.text('Widget 10'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });
  });
}
