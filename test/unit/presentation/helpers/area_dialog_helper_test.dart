import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/area_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/editor/area_dialog_helper.dart';

class MockAreaRepository extends Mock implements AreaRepository {}

class MockMenuRepository extends Mock implements MenuRepository {}

class FakeUpdateMenuInput extends Fake implements UpdateMenuInput {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpdateMenuInput());
  });

  group('showAreaDialog', () {
    late MockAreaRepository mockAreaRepo;
    late MockMenuRepository mockMenuRepo;

    setUp(() {
      mockAreaRepo = MockAreaRepository();
      mockMenuRepo = MockMenuRepository();
    });

    Widget buildTestWidget({
      required void Function(BuildContext, WidgetRef) onPressed,
    }) {
      return ProviderScope(
        overrides: [
          areaRepositoryProvider.overrideWithValue(mockAreaRepo),
          menuRepositoryProvider.overrideWithValue(mockMenuRepo),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () => onPressed(context, ref),
              child: const Text('Open'),
            ),
          ),
        ),
      );
    }

    testWidgets('shows area options when loaded', (WidgetTester tester) async {
      when(() => mockAreaRepo.getAll()).thenAnswer(
        (_) async => Success([
          const Area(id: 1, name: 'Bar'),
          const Area(id: 2, name: 'Restaurant'),
        ]),
      );

      await tester.pumpWidget(
        buildTestWidget(
          onPressed: (context, ref) => showAreaDialog(
            context: context,
            ref: ref,
            menuId: 1,
            onAreaUpdated: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Select Area'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
      expect(find.text('Bar'), findsOneWidget);
      expect(find.text('Restaurant'), findsOneWidget);
    });

    testWidgets('calls onAreaUpdated with null when None selected', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAreaRepo.getAll(),
      ).thenAnswer((_) async => Success([const Area(id: 1, name: 'Bar')]));
      when(() => mockMenuRepo.update(any())).thenAnswer(
        (_) async => Success(
          Menu(id: 1, name: 'Test', version: '1.0', status: Status.draft),
        ),
      );

      Area? updatedArea;
      var wasCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          onPressed: (context, ref) => showAreaDialog(
            context: context,
            ref: ref,
            menuId: 1,
            onAreaUpdated: (area) {
              wasCalled = true;
              updatedArea = area;
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('None'));
      await tester.pumpAndSettle();

      expect(wasCalled, isTrue);
      expect(updatedArea, isNull);
    });

    testWidgets('calls onAreaUpdated with area when area selected', (
      WidgetTester tester,
    ) async {
      const bar = Area(id: 1, name: 'Bar');
      when(() => mockAreaRepo.getAll()).thenAnswer((_) async => Success([bar]));
      when(() => mockMenuRepo.update(any())).thenAnswer(
        (_) async => Success(
          Menu(id: 1, name: 'Test', version: '1.0', status: Status.draft),
        ),
      );

      Area? updatedArea;

      await tester.pumpWidget(
        buildTestWidget(
          onPressed: (context, ref) => showAreaDialog(
            context: context,
            ref: ref,
            menuId: 1,
            onAreaUpdated: (area) => updatedArea = area,
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bar'));
      await tester.pumpAndSettle();

      expect(updatedArea, bar);
    });
  });
}
