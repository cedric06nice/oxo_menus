import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/editor/page_size_dialog_helper.dart';

class MockSizeRepository extends Mock implements SizeRepository {}

class MockMenuRepository extends Mock implements MenuRepository {}

class FakeUpdateMenuInput extends Fake implements UpdateMenuInput {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpdateMenuInput());
  });

  group('showPageSizeDialog', () {
    late MockSizeRepository mockSizeRepo;
    late MockMenuRepository mockMenuRepo;

    setUp(() {
      mockSizeRepo = MockSizeRepository();
      mockMenuRepo = MockMenuRepository();
    });

    Widget buildTestWidget({
      required void Function(BuildContext, WidgetRef) onPressed,
    }) {
      return ProviderScope(
        overrides: [
          sizeRepositoryProvider.overrideWithValue(mockSizeRepo),
          menuRepositoryProvider.overrideWithValue(mockMenuRepo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => ElevatedButton(
                onPressed: () => onPressed(context, ref),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows size options when loaded', (WidgetTester tester) async {
      when(() => mockSizeRepo.getAll()).thenAnswer(
        (_) async => Success([
          const domain.Size(
            id: 1,
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          ),
        ]),
      );

      await tester.pumpWidget(
        buildTestWidget(
          onPressed: (context, ref) => showPageSizeDialog(
            context: context,
            ref: ref,
            menuId: 1,
            currentPageSize: null,
            onPageSizeUpdated: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Select Page Size'), findsOneWidget);
      expect(find.text('A4'), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure', (WidgetTester tester) async {
      when(
        () => mockSizeRepo.getAll(),
      ).thenAnswer((_) async => Failure(const ServerError('Server down')));

      await tester.pumpWidget(
        buildTestWidget(
          onPressed: (context, ref) => showPageSizeDialog(
            context: context,
            ref: ref,
            menuId: 1,
            currentPageSize: null,
            onPageSizeUpdated: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load sizes: Server down'), findsOneWidget);
    });
  });
}
