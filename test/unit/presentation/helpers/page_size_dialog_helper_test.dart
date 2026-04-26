import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/editor/page_size_dialog_helper.dart';

import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_size_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared fixtures
  // ---------------------------------------------------------------------------

  const a4 = domain.Size(
    id: 1,
    name: 'A4',
    width: 210,
    height: 297,
    status: Status.published,
    direction: 'portrait',
  );

  const letter = domain.Size(
    id: 2,
    name: 'Letter',
    width: 215.9,
    height: 279.4,
    status: Status.published,
    direction: 'landscape',
  );

  const updatedMenu = Menu(
    id: 1,
    name: 'Test Menu',
    status: Status.draft,
    version: '1.0',
  );

  // ---------------------------------------------------------------------------
  // Widget builder
  // ---------------------------------------------------------------------------

  Widget buildTestWidget({
    required FakeSizeRepository fakeSizeRepo,
    required FakeMenuRepository fakeMenuRepo,
    required void Function(BuildContext, WidgetRef) onPressed,
  }) {
    return ProviderScope(
      overrides: [
        sizeRepositoryProvider.overrideWithValue(fakeSizeRepo),
        menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
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

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('showPageSizeDialog', () {
    late FakeSizeRepository fakeSizeRepo;
    late FakeMenuRepository fakeMenuRepo;

    setUp(() {
      fakeSizeRepo = FakeSizeRepository();
      fakeMenuRepo = FakeMenuRepository();
    });

    group('dialog display', () {
      testWidgets('should show the dialog title when sizes load successfully', (
        tester,
      ) async {
        // Arrange
        fakeSizeRepo.whenGetAll(success([a4]));

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeSizeRepo: fakeSizeRepo,
            fakeMenuRepo: fakeMenuRepo,
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

        // Assert
        expect(find.text('Select Page Size'), findsOneWidget);
      });

      testWidgets(
        'should show all loaded size options when sizes load successfully',
        (tester) async {
          // Arrange
          fakeSizeRepo.whenGetAll(success([a4, letter]));

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeSizeRepo: fakeSizeRepo,
              fakeMenuRepo: fakeMenuRepo,
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

          // Assert
          expect(find.text('A4'), findsOneWidget);
          expect(find.text('Letter'), findsOneWidget);
        },
      );

      testWidgets('should show an empty dialog when no sizes are available', (
        tester,
      ) async {
        // Arrange
        fakeSizeRepo.whenGetAll(success(<domain.Size>[]));

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeSizeRepo: fakeSizeRepo,
            fakeMenuRepo: fakeMenuRepo,
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

        // Assert — dialog appears with its title but no list items
        expect(find.text('Select Page Size'), findsOneWidget);
        expect(find.text('A4'), findsNothing);
      });
    });

    group('error handling', () {
      testWidgets(
        'should show an error snackbar when sizes fail to load with ServerError',
        (tester) async {
          // Arrange
          fakeSizeRepo.whenGetAll(
            failure<List<domain.Size>>(const ServerError('Server down')),
          );

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeSizeRepo: fakeSizeRepo,
              fakeMenuRepo: fakeMenuRepo,
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

          // Assert
          expect(
            find.text('Failed to load sizes: Server down'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'should not open the size picker dialog when sizes fail to load',
        (tester) async {
          // Arrange
          fakeSizeRepo.whenGetAll(
            failure<List<domain.Size>>(const NetworkError('offline')),
          );

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeSizeRepo: fakeSizeRepo,
              fakeMenuRepo: fakeMenuRepo,
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

          // Assert — dialog title is absent; only the snackbar message is shown
          expect(find.text('Select Page Size'), findsNothing);
        },
      );
    });

    group('size selection', () {
      testWidgets(
        'should call onPageSizeUpdated with the selected size after a successful update',
        (tester) async {
          // Arrange
          fakeSizeRepo.whenGetAll(success([a4]));
          fakeMenuRepo.whenUpdate(success(updatedMenu));

          PageSize? receivedPageSize;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeSizeRepo: fakeSizeRepo,
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showPageSizeDialog(
                context: context,
                ref: ref,
                menuId: 1,
                currentPageSize: null,
                onPageSizeUpdated: (ps) => receivedPageSize = ps,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('A4'));
          await tester.pumpAndSettle();

          // Assert
          expect(receivedPageSize, isNotNull);
          expect(receivedPageSize!.name, 'A4');
        },
      );

      testWidgets(
        'should not call onPageSizeUpdated when the menu update fails',
        (tester) async {
          // Arrange
          fakeSizeRepo.whenGetAll(success([a4]));
          fakeMenuRepo.whenUpdate(
            failure<Menu>(const ServerError('update failed')),
          );

          var callbackInvoked = false;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeSizeRepo: fakeSizeRepo,
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showPageSizeDialog(
                context: context,
                ref: ref,
                menuId: 1,
                currentPageSize: null,
                onPageSizeUpdated: (_) => callbackInvoked = true,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('A4'));
          await tester.pumpAndSettle();

          // Assert
          expect(callbackInvoked, isFalse);
        },
      );

      testWidgets(
        'should show a success snackbar after a successful page size update',
        (tester) async {
          // Arrange
          fakeSizeRepo.whenGetAll(success([a4]));
          fakeMenuRepo.whenUpdate(success(updatedMenu));

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeSizeRepo: fakeSizeRepo,
              fakeMenuRepo: fakeMenuRepo,
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
          await tester.tap(find.text('A4'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Page size updated'), findsOneWidget);
        },
      );

      testWidgets(
        'should pass the correct sizeId to the menu update when a size is selected',
        (tester) async {
          // Arrange
          fakeSizeRepo.whenGetAll(success([a4]));
          fakeMenuRepo.whenUpdate(success(updatedMenu));

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeSizeRepo: fakeSizeRepo,
              fakeMenuRepo: fakeMenuRepo,
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
          await tester.tap(find.text('A4'));
          await tester.pumpAndSettle();

          // Assert — the update call should carry sizeId = a4.id
          expect(fakeMenuRepo.updateCalls, hasLength(1));
          expect(fakeMenuRepo.updateCalls.first.input.sizeId, a4.id);
        },
      );
    });

    group('cancel', () {
      testWidgets(
        'should not call onPageSizeUpdated when the dialog is dismissed via Cancel',
        (tester) async {
          // Arrange
          fakeSizeRepo.whenGetAll(success([a4]));

          var callbackInvoked = false;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeSizeRepo: fakeSizeRepo,
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showPageSizeDialog(
                context: context,
                ref: ref,
                menuId: 1,
                currentPageSize: null,
                onPageSizeUpdated: (_) => callbackInvoked = true,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();

          // Assert
          expect(callbackInvoked, isFalse);
        },
      );
    });
  });
}
