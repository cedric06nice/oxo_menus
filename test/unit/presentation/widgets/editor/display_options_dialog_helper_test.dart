import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/editor/display_options_dialog_helper.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class FakeUpdateMenuInput extends Fake implements UpdateMenuInput {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpdateMenuInput());
  });

  group('showDisplayOptionsDialog', () {
    late MockMenuRepository mockMenuRepo;

    setUp(() {
      mockMenuRepo = MockMenuRepository();
    });

    Menu makeMenu() => const Menu(
      id: 1,
      name: 'Test',
      status: Status.draft,
      version: '1',
      displayOptions: MenuDisplayOptions(showPrices: true, showAllergens: true),
    );

    testWidgets('opens MenuDisplayOptionsDialog and saves on success', (
      tester,
    ) async {
      when(
        () => mockMenuRepo.update(any()),
      ).thenAnswer((_) async => Success(makeMenu()));

      Menu? updatedMenu;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [menuRepositoryProvider.overrideWithValue(mockMenuRepo)],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => ElevatedButton(
                  onPressed: () => showDisplayOptionsDialog(
                    context: context,
                    ref: ref,
                    menuId: 1,
                    menu: makeMenu(),
                    onMenuUpdated: (m) => updatedMenu = m,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Display Options'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => mockMenuRepo.update(any())).called(1);
      expect(updatedMenu, isNotNull);
    });

    testWidgets('does not call onMenuUpdated when update fails', (
      tester,
    ) async {
      when(
        () => mockMenuRepo.update(any()),
      ).thenAnswer((_) async => Failure(ServerError('fail')));

      Menu? updatedMenu;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [menuRepositoryProvider.overrideWithValue(mockMenuRepo)],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => ElevatedButton(
                  onPressed: () => showDisplayOptionsDialog(
                    context: context,
                    ref: ref,
                    menuId: 1,
                    menu: makeMenu(),
                    onMenuUpdated: (m) => updatedMenu = m,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(updatedMenu, isNull);
    });
  });
}
