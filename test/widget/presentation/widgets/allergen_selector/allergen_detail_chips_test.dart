import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widgets/allergen_selector/allergen_detail_chips.dart';

void main() {
  group('AllergenDetailChips', () {
    const options = ['barley', 'kamut', 'oats', 'rye', 'spelt', 'wheat'];

    Widget buildHarness({
      String? value,
      required ValueChanged<String?> onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AllergenDetailChips(
            options: options,
            value: value,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('renders one FilterChip per option', (tester) async {
      await tester.pumpWidget(buildHarness(onChanged: (_) {}));

      for (final option in options) {
        expect(find.text(option), findsOneWidget);
      }
      expect(find.byType(FilterChip), findsNWidgets(options.length));
    });

    testWidgets('no chips selected when value is null', (tester) async {
      await tester.pumpWidget(buildHarness(onChanged: (_) {}));

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      for (final chip in chips) {
        expect(chip.selected, isFalse);
      }
    });

    testWidgets('selects chips that match comma-separated value', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildHarness(value: 'wheat, barley', onChanged: (_) {}),
      );

      final selectedLabels = <String>[];
      for (final option in options) {
        final chip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text(option),
            matching: find.byType(FilterChip),
          ),
        );
        if (chip.selected) {
          selectedLabels.add(option);
        }
      }

      expect(selectedLabels, ['barley', 'wheat']);
    });

    testWidgets('tapping an unselected chip emits sorted comma-joined value', (
      tester,
    ) async {
      String? captured = 'sentinel';

      await tester.pumpWidget(
        buildHarness(value: 'wheat', onChanged: (v) => captured = v),
      );

      await tester.tap(find.text('barley'));
      await tester.pump();

      expect(captured, 'barley, wheat');
    });

    testWidgets('tapping a selected chip removes it from the value', (
      tester,
    ) async {
      String? captured = 'sentinel';

      await tester.pumpWidget(
        buildHarness(value: 'barley, wheat', onChanged: (v) => captured = v),
      );

      await tester.tap(find.text('wheat'));
      await tester.pump();

      expect(captured, 'barley');
    });

    testWidgets('deselecting the last chip emits null', (tester) async {
      String? captured = 'sentinel';

      await tester.pumpWidget(
        buildHarness(value: 'wheat', onChanged: (v) => captured = v),
      );

      await tester.tap(find.text('wheat'));
      await tester.pump();

      expect(captured, isNull);
    });

    testWidgets('matches value case-insensitively with whitespace', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildHarness(value: '  WHEAT ,Barley ', onChanged: (_) {}),
      );

      for (final option in ['barley', 'wheat']) {
        final chip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text(option),
            matching: find.byType(FilterChip),
          ),
        );
        expect(
          chip.selected,
          isTrue,
          reason: '$option should be selected from messy value',
        );
      }
    });

    testWidgets('ignores unknown tokens in value', (tester) async {
      await tester.pumpWidget(
        buildHarness(value: 'wheat, nonsense', onChanged: (_) {}),
      );

      final wheatChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('wheat'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(wheatChip.selected, isTrue);

      for (final option in options.where((o) => o != 'wheat')) {
        final chip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text(option),
            matching: find.byType(FilterChip),
          ),
        );
        expect(chip.selected, isFalse);
      }
    });
  });
}
