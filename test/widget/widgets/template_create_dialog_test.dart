import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/area_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/pages/menu_list/widgets/template_create_dialog.dart';

class MockSizeRepository extends Mock implements SizeRepository {}

class MockAreaRepository extends Mock implements AreaRepository {}

class MockGoRouter extends Mock implements GoRouter {}

const _testAreas = [Area(id: 1, name: 'Dining'), Area(id: 2, name: 'Bar')];

void main() {
  late MockSizeRepository mockSizeRepository;
  late MockAreaRepository mockAreaRepository;

  setUp(() {
    mockSizeRepository = MockSizeRepository();
    mockAreaRepository = MockAreaRepository();
    when(
      () => mockAreaRepository.getAll(),
    ).thenAnswer((_) async => const Success(_testAreas));
  });

  Widget buildApp({
    required MockSizeRepository sizeRepo,
    MockAreaRepository? areaRepo,
    GoRouter? router,
    void Function(TemplateCreateResult)? onSave,
  }) {
    final goRouter =
        router ??
        GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) =>
                          TemplateCreateDialog(onSave: onSave ?? (_) {}),
                    ),
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/admin/sizes',
              builder: (_, _) => const Scaffold(body: Text('Admin Sizes Page')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [
        sizeRepositoryProvider.overrideWithValue(sizeRepo),
        areaRepositoryProvider.overrideWithValue(
          areaRepo ?? mockAreaRepository,
        ),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
        theme: ThemeData(platform: TargetPlatform.android),
      ),
    );
  }

  group('TemplateCreateDialog', () {
    testWidgets(
      'should show "No page sizes available" and navigate button when sizes list is empty',
      (tester) async {
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => const Success(<domain.Size>[]));

        await tester.pumpWidget(buildApp(sizeRepo: mockSizeRepository));

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('No page sizes available.'), findsOneWidget);
        expect(find.text('Manage Page Sizes'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to /admin/sizes when "Manage Page Sizes" is tapped',
      (tester) async {
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => const Success(<domain.Size>[]));

        await tester.pumpWidget(buildApp(sizeRepo: mockSizeRepository));

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Manage Page Sizes'));
        await tester.pumpAndSettle();

        // Dialog should be closed and we should be on the admin sizes page
        expect(find.text('Admin Sizes Page'), findsOneWidget);
      },
    );

    testWidgets('should show size dropdown when sizes are available', (
      tester,
    ) async {
      when(() => mockSizeRepository.getAll()).thenAnswer(
        (_) async => const Success([
          domain.Size(
            id: 1,
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          ),
        ]),
      );

      await tester.pumpWidget(buildApp(sizeRepo: mockSizeRepository));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Manage Page Sizes'), findsNothing);
      expect(find.text('Page Size'), findsOneWidget);
    });

    testWidgets(
      'should auto-select first size when sizes load asynchronously',
      (tester) async {
        final completer = Completer<Result<List<domain.Size>, DomainError>>();
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildApp(sizeRepo: mockSizeRepository));

        await tester.tap(find.text('Open Dialog'));
        await tester.pump();
        await tester.pump();

        // Sizes haven't loaded yet
        expect(find.text('Loading sizes...'), findsOneWidget);

        // Complete the sizes future
        completer.complete(
          const Success([
            domain.Size(
              id: 1,
              name: 'A4',
              width: 210,
              height: 297,
              status: Status.published,
              direction: 'portrait',
            ),
            domain.Size(
              id: 2,
              name: 'A5',
              width: 148,
              height: 210,
              status: Status.published,
              direction: 'portrait',
            ),
          ]),
        );
        await tester.pumpAndSettle();

        // First size should be auto-selected
        expect(find.text('A4 (210x297 mm)'), findsOneWidget);

        // Create button should be disabled (name is empty)
        final createButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Create'),
        );
        expect(createButton.onPressed, isNull);

        // Fill in name and verify create is now enabled
        await tester.enterText(
          find.widgetWithText(TextField, 'Template Name'),
          'My Template',
        );
        await tester.pump();

        final enabledButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Create'),
        );
        expect(enabledButton.onPressed, isNotNull);
      },
    );

    testWidgets('should show area dropdown with loaded areas', (tester) async {
      when(() => mockSizeRepository.getAll()).thenAnswer(
        (_) async => const Success([
          domain.Size(
            id: 1,
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          ),
        ]),
      );

      await tester.pumpWidget(buildApp(sizeRepo: mockSizeRepository));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Area'), findsOneWidget);
    });

    testWidgets('should include areaId in result when area is selected', (
      tester,
    ) async {
      when(() => mockSizeRepository.getAll()).thenAnswer(
        (_) async => const Success([
          domain.Size(
            id: 1,
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          ),
        ]),
      );

      TemplateCreateResult? capturedResult;

      await tester.pumpWidget(
        buildApp(
          sizeRepo: mockSizeRepository,
          onSave: (result) => capturedResult = result,
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Enter template name
      await tester.enterText(
        find.widgetWithText(TextField, 'Template Name'),
        'Test Menu',
      );
      await tester.pump();

      // Select an area from the dropdown
      await tester.tap(find.text('Area').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dining').last);
      await tester.pumpAndSettle();

      // Tap create
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      expect(capturedResult, isNotNull);
      expect(capturedResult!.areaId, 1);
    });

    testWidgets('should allow creating template without area (null areaId)', (
      tester,
    ) async {
      when(() => mockSizeRepository.getAll()).thenAnswer(
        (_) async => const Success([
          domain.Size(
            id: 1,
            name: 'A4',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          ),
        ]),
      );

      TemplateCreateResult? capturedResult;

      await tester.pumpWidget(
        buildApp(
          sizeRepo: mockSizeRepository,
          onSave: (result) => capturedResult = result,
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Enter template name
      await tester.enterText(
        find.widgetWithText(TextField, 'Template Name'),
        'Test Menu',
      );
      await tester.pump();

      // Don't select area — leave as "None"

      // Tap create
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      expect(capturedResult, isNotNull);
      expect(capturedResult!.areaId, isNull);
    });
  });
}
