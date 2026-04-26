import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/editor/area_dialog_helper.dart';

import '../../../fakes/fake_area_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared fixtures
  // ---------------------------------------------------------------------------

  const bar = Area(id: 1, name: 'Bar');
  const restaurant = Area(id: 2, name: 'Restaurant');
  const terrace = Area(id: 3, name: 'Terrace');

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
    required FakeAreaRepository fakeAreaRepo,
    required FakeMenuRepository fakeMenuRepo,
    required void Function(BuildContext, WidgetRef) onPressed,
  }) {
    return ProviderScope(
      overrides: [
        areaRepositoryProvider.overrideWithValue(fakeAreaRepo),
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

  group('showAreaDialog', () {
    late FakeAreaRepository fakeAreaRepo;
    late FakeMenuRepository fakeMenuRepo;

    setUp(() {
      fakeAreaRepo = FakeAreaRepository();
      fakeMenuRepo = FakeMenuRepository();
    });

    group('dialog display', () {
      testWidgets('should show the dialog title when areas load successfully', (
        tester,
      ) async {
        // Arrange
        fakeAreaRepo.whenGetAll(success([bar]));

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeAreaRepo: fakeAreaRepo,
            fakeMenuRepo: fakeMenuRepo,
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

        // Assert
        expect(find.text('Select Area'), findsOneWidget);
      });

      testWidgets('should always show the None option when the dialog opens', (
        tester,
      ) async {
        // Arrange
        fakeAreaRepo.whenGetAll(success([bar]));

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeAreaRepo: fakeAreaRepo,
            fakeMenuRepo: fakeMenuRepo,
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

        // Assert
        expect(find.text('None'), findsOneWidget);
      });

      testWidgets('should show all loaded area options in the dialog', (
        tester,
      ) async {
        // Arrange
        fakeAreaRepo.whenGetAll(success([bar, restaurant, terrace]));

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeAreaRepo: fakeAreaRepo,
            fakeMenuRepo: fakeMenuRepo,
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

        // Assert
        expect(find.text('Bar'), findsOneWidget);
        expect(find.text('Restaurant'), findsOneWidget);
        expect(find.text('Terrace'), findsOneWidget);
      });

      testWidgets(
        'should show only the None option when no areas are available',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(success(<Area>[]));

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
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

          // Assert
          expect(find.text('Select Area'), findsOneWidget);
          expect(find.text('None'), findsOneWidget);
          expect(find.text('Bar'), findsNothing);
        },
      );
    });

    group('error handling', () {
      testWidgets(
        'should show an error snackbar when areas fail to load with ServerError',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(
            failure<List<Area>>(const ServerError('Server down')),
          );

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
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

          // Assert
          expect(
            find.text('Failed to load areas: Server down'),
            findsOneWidget,
          );
        },
      );

      testWidgets('should not open the area dialog when areas fail to load', (
        tester,
      ) async {
        // Arrange
        fakeAreaRepo.whenGetAll(
          failure<List<Area>>(const NetworkError('offline')),
        );

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            fakeAreaRepo: fakeAreaRepo,
            fakeMenuRepo: fakeMenuRepo,
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

        // Assert — the dialog title is absent when loading failed
        expect(find.text('Select Area'), findsNothing);
      });
    });

    group('None selection', () {
      testWidgets(
        'should call onAreaUpdated with null when None is tapped and update succeeds',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(success([bar]));
          fakeMenuRepo.whenUpdate(success(updatedMenu));

          Area? receivedArea;
          var callbackInvoked = false;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showAreaDialog(
                context: context,
                ref: ref,
                menuId: 1,
                onAreaUpdated: (area) {
                  callbackInvoked = true;
                  receivedArea = area;
                },
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('None'));
          await tester.pumpAndSettle();

          // Assert
          expect(callbackInvoked, isTrue);
          expect(receivedArea, isNull);
        },
      );

      testWidgets(
        'should pass areaId null to the menu update when None is tapped',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(success([bar]));
          fakeMenuRepo.whenUpdate(success(updatedMenu));

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
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
          await tester.tap(find.text('None'));
          await tester.pumpAndSettle();

          // Assert
          expect(fakeMenuRepo.updateCalls, hasLength(1));
          expect(fakeMenuRepo.updateCalls.first.input.areaId, isNull);
        },
      );

      testWidgets(
        'should not call onAreaUpdated when None is tapped but update fails',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(success([bar]));
          fakeMenuRepo.whenUpdate(
            failure<Menu>(const ServerError('update failed')),
          );

          var callbackInvoked = false;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showAreaDialog(
                context: context,
                ref: ref,
                menuId: 1,
                onAreaUpdated: (_) => callbackInvoked = true,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('None'));
          await tester.pumpAndSettle();

          // Assert
          expect(callbackInvoked, isFalse);
        },
      );
    });

    group('area selection', () {
      testWidgets(
        'should call onAreaUpdated with the tapped area when update succeeds',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(success([bar, restaurant]));
          fakeMenuRepo.whenUpdate(success(updatedMenu));

          Area? receivedArea;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showAreaDialog(
                context: context,
                ref: ref,
                menuId: 1,
                onAreaUpdated: (area) => receivedArea = area,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Bar'));
          await tester.pumpAndSettle();

          // Assert
          expect(receivedArea, equals(bar));
        },
      );

      testWidgets(
        'should pass the correct areaId to the menu update when an area is tapped',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(success([bar]));
          fakeMenuRepo.whenUpdate(success(updatedMenu));

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
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
          await tester.tap(find.text('Bar'));
          await tester.pumpAndSettle();

          // Assert
          expect(fakeMenuRepo.updateCalls, hasLength(1));
          expect(fakeMenuRepo.updateCalls.first.input.areaId, bar.id);
        },
      );

      testWidgets(
        'should not call onAreaUpdated when an area is tapped but update fails',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(success([bar]));
          fakeMenuRepo.whenUpdate(
            failure<Menu>(const ServerError('update failed')),
          );

          var callbackInvoked = false;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showAreaDialog(
                context: context,
                ref: ref,
                menuId: 1,
                onAreaUpdated: (_) => callbackInvoked = true,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Bar'));
          await tester.pumpAndSettle();

          // Assert
          expect(callbackInvoked, isFalse);
        },
      );

      testWidgets(
        'should call onAreaUpdated with the second area when the second option is tapped',
        (tester) async {
          // Arrange
          fakeAreaRepo.whenGetAll(success([bar, restaurant]));
          fakeMenuRepo.whenUpdate(success(updatedMenu));

          Area? receivedArea;

          // Act
          await tester.pumpWidget(
            buildTestWidget(
              fakeAreaRepo: fakeAreaRepo,
              fakeMenuRepo: fakeMenuRepo,
              onPressed: (context, ref) => showAreaDialog(
                context: context,
                ref: ref,
                menuId: 1,
                onAreaUpdated: (area) => receivedArea = area,
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Restaurant'));
          await tester.pumpAndSettle();

          // Assert
          expect(receivedArea, equals(restaurant));
        },
      );
    });
  });
}
