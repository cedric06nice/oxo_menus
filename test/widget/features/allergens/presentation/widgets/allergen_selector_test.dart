import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/allergens/domain/allergen_detail_options.dart';
import 'package:oxo_menus/features/allergens/domain/allergen_info.dart';
import 'package:oxo_menus/features/allergens/domain/uk_allergen.dart';
import 'package:oxo_menus/features/allergens/presentation/widgets/allergen_detail_chips.dart';
import 'package:oxo_menus/features/allergens/presentation/widgets/allergen_selector.dart';

void main() {
  group('AllergenSelector', () {
    testWidgets('should display title and all 14 UK allergens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Allergens'), findsOneWidget);

      // All 14 UK allergens should be shown
      for (final allergen in UkAllergen.values) {
        expect(find.text(allergen.displayName), findsOneWidget);
      }
    });

    testWidgets('should select an allergen when checkbox tapped', (
      WidgetTester tester,
    ) async {
      List<AllergenInfo>? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [],
                onChanged: (selection) => result = selection,
              ),
            ),
          ),
        ),
      );

      // Find and tap the first checkbox (Celery)
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets);
      await tester.tap(checkboxes.first);
      await tester.pump();

      expect(result, isNotNull);
      expect(result, hasLength(1));
      expect(result!.first.allergen, UkAllergen.celery);
      expect(result!.first.mayContain, false);
    });

    testWidgets('should deselect an allergen when checkbox tapped again', (
      WidgetTester tester,
    ) async {
      List<AllergenInfo>? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [
                  AllergenInfo(allergen: UkAllergen.celery, mayContain: false),
                ],
                onChanged: (selection) => result = selection,
              ),
            ),
          ),
        ),
      );

      // The first checkbox should be checked already; tap to deselect
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.first);
      await tester.pump();

      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    testWidgets('should show may-contain checkbox when allergen is selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [
                  AllergenInfo(allergen: UkAllergen.celery, mayContain: false),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('May contain (trace amounts)'), findsOneWidget);
    });

    testWidgets('should toggle may-contain on selected allergen', (
      WidgetTester tester,
    ) async {
      List<AllergenInfo>? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [
                  AllergenInfo(allergen: UkAllergen.celery, mayContain: false),
                ],
                onChanged: (selection) => result = selection,
              ),
            ),
          ),
        ),
      );

      // Find the "may contain" checkbox (second checkbox since first is the allergen)
      final checkboxes = find.byType(Checkbox);
      // First checkbox is celery, second is may-contain
      await tester.tap(checkboxes.at(1));
      await tester.pump();

      expect(result, isNotNull);
      expect(result!.first.mayContain, true);
    });

    testWidgets('should show cereal chips for gluten', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [
                  AllergenInfo(allergen: UkAllergen.gluten, mayContain: false),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AllergenDetailChips), findsOneWidget);
      for (final cereal in AllergenDetailOptions.cerealOptions) {
        expect(find.text(cereal), findsOneWidget);
      }
    });

    testWidgets('should show nut chips for nuts', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [
                  AllergenInfo(allergen: UkAllergen.nuts, mayContain: false),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AllergenDetailChips), findsOneWidget);
      for (final nut in AllergenDetailOptions.nutOptions) {
        expect(find.text(nut), findsOneWidget);
      }
    });

    testWidgets(
      'tapping a cereal chip stores sorted lowercase details on the AllergenInfo',
      (WidgetTester tester) async {
        List<AllergenInfo>? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AllergenSelector(
                  initialSelection: const [
                    AllergenInfo(
                      allergen: UkAllergen.gluten,
                      mayContain: false,
                    ),
                  ],
                  onChanged: (selection) => result = selection,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('wheat'));
        await tester.pump();
        await tester.tap(find.text('barley'));
        await tester.pump();

        expect(result, isNotNull);
        expect(result!.first.allergen, UkAllergen.gluten);
        expect(result!.first.details, 'barley, wheat');
      },
    );

    testWidgets('does not show details chips for allergens without details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [
                  AllergenInfo(allergen: UkAllergen.celery, mayContain: false),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AllergenDetailChips), findsNothing);
    });

    testWidgets('should render with initial selections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [
                  AllergenInfo(allergen: UkAllergen.milk, mayContain: true),
                  AllergenInfo(allergen: UkAllergen.eggs, mayContain: false),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Both "May contain" labels should show (one per selected allergen)
      expect(find.text('May contain (trace amounts)'), findsNWidgets(2));
    });

    testWidgets('renders CupertinoCheckbox on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoCheckbox), findsNWidgets(14));
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('renders AllergenDetailChips for details on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [
                  AllergenInfo(allergen: UkAllergen.gluten, mayContain: false),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AllergenDetailChips), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsNothing);
    });

    testWidgets('selects allergen on iOS via CupertinoCheckbox', (
      WidgetTester tester,
    ) async {
      List<AllergenInfo>? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [],
                onChanged: (selection) => result = selection,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoCheckbox).first);
      await tester.pump();

      expect(result, isNotNull);
      expect(result, hasLength(1));
      expect(result!.first.allergen, UkAllergen.celery);
    });

    testWidgets('uses CupertinoFormSection.insetGrouped on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoFormSection), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('uses Card tiles on Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsNWidgets(14));
      expect(find.byType(CupertinoFormSection), findsNothing);
    });

    testWidgets('renders Checkbox on Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AllergenSelector(
                initialSelection: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsNWidgets(14));
      expect(find.byType(CupertinoCheckbox), findsNothing);
    });
  });
}
