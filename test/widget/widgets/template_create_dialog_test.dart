import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/pages/menu_list/widgets/template_create_dialog.dart';

import '../../fakes/fake_size_repository.dart';
import '../../fakes/fake_area_repository.dart';
import '../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Local helper fake — future that resolves only when completer fires
// ---------------------------------------------------------------------------

class _ControllableSizeRepository implements SizeRepository {
  final Completer<Result<List<domain.Size>, DomainError>> _completer;

  _ControllableSizeRepository(this._completer);

  @override
  Future<Result<List<domain.Size>, DomainError>> getAll() => _completer.future;

  @override
  Future<Result<domain.Size, DomainError>> getById(int id) =>
      throw UnimplementedError();

  @override
  Future<Result<domain.Size, DomainError>> create(CreateSizeInput input) =>
      throw UnimplementedError();

  @override
  Future<Result<domain.Size, DomainError>> update(UpdateSizeInput input) =>
      throw UnimplementedError();

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

const _testAreas = [Area(id: 1, name: 'Dining'), Area(id: 2, name: 'Bar')];

const _testSize = domain.Size(
  id: 1,
  name: 'A4',
  width: 210,
  height: 297,
  status: Status.published,
  direction: 'portrait',
);

const _testSize2 = domain.Size(
  id: 2,
  name: 'A5',
  width: 148,
  height: 210,
  status: Status.published,
  direction: 'portrait',
);

void main() {
  late FakeSizeRepository fakeSizeRepository;
  late FakeAreaRepository fakeAreaRepository;

  setUp(() {
    fakeSizeRepository = FakeSizeRepository();
    fakeAreaRepository = FakeAreaRepository();
    fakeAreaRepository.whenGetAll(success(List<Area>.from(_testAreas)));
  });

  Widget buildApp({
    void Function(TemplateCreateResult)? onSave,
    SizeRepository? sizeRepo,
  }) {
    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<void>(
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
        sizeRepositoryProvider.overrideWithValue(
          sizeRepo ?? fakeSizeRepository,
        ),
        areaRepositoryProvider.overrideWithValue(fakeAreaRepository),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
        theme: ThemeData(platform: TargetPlatform.android),
      ),
    );
  }

  group('TemplateCreateDialog', () {
    group('empty sizes state', () {
      testWidgets(
        'should show "No page sizes available" when sizes list is empty',
        (tester) async {
          // Arrange
          fakeSizeRepository.whenGetAll(success(<domain.Size>[]));

          // Act
          await tester.pumpWidget(buildApp());
          await tester.tap(find.text('Open Dialog'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('No page sizes available.'), findsOneWidget);
        },
      );

      testWidgets(
        'should show "Manage Page Sizes" navigate button when sizes list is empty',
        (tester) async {
          // Arrange
          fakeSizeRepository.whenGetAll(success(<domain.Size>[]));

          // Act
          await tester.pumpWidget(buildApp());
          await tester.tap(find.text('Open Dialog'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Manage Page Sizes'), findsOneWidget);
        },
      );

      testWidgets(
        'should navigate to /admin/sizes when "Manage Page Sizes" is tapped',
        (tester) async {
          // Arrange
          fakeSizeRepository.whenGetAll(success(<domain.Size>[]));

          // Act
          await tester.pumpWidget(buildApp());
          await tester.tap(find.text('Open Dialog'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Manage Page Sizes'));
          await tester.pumpAndSettle();

          // Assert — dialog closed and navigated to admin sizes page
          expect(find.text('Admin Sizes Page'), findsOneWidget);
        },
      );
    });

    group('sizes available', () {
      testWidgets('should show size dropdown when sizes are available', (
        tester,
      ) async {
        // Arrange
        fakeSizeRepository.whenGetAll(success([_testSize]));

        // Act
        await tester.pumpWidget(buildApp());
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Manage Page Sizes'), findsNothing);
        expect(find.text('Page Size'), findsOneWidget);
      });

      testWidgets('should show Area dropdown when areas are available', (
        tester,
      ) async {
        // Arrange
        fakeSizeRepository.whenGetAll(success([_testSize]));

        // Act
        await tester.pumpWidget(buildApp());
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Area'), findsOneWidget);
      });
    });

    group('async loading', () {
      testWidgets('should show loading state before sizes resolve', (
        tester,
      ) async {
        // Arrange
        final completer = Completer<Result<List<domain.Size>, DomainError>>();
        final controllableRepo = _ControllableSizeRepository(completer);

        // Act
        await tester.pumpWidget(buildApp(sizeRepo: controllableRepo));
        await tester.tap(find.text('Open Dialog'));
        await tester.pump();
        await tester.pump();

        // Assert — sizes haven't loaded yet
        expect(find.text('Loading sizes...'), findsOneWidget);

        // Cleanup — resolve to avoid timer leak
        completer.complete(success([_testSize]));
        await tester.pumpAndSettle();
      });

      testWidgets(
        'should auto-select first size when sizes load asynchronously',
        (tester) async {
          // Arrange
          final completer = Completer<Result<List<domain.Size>, DomainError>>();
          final controllableRepo = _ControllableSizeRepository(completer);

          // Act
          await tester.pumpWidget(buildApp(sizeRepo: controllableRepo));
          await tester.tap(find.text('Open Dialog'));
          await tester.pump();
          await tester.pump();

          // Sizes haven't loaded yet
          expect(find.text('Loading sizes...'), findsOneWidget);

          // Complete the sizes future
          completer.complete(success([_testSize, _testSize2]));
          await tester.pumpAndSettle();

          // Assert — first size auto-selected
          expect(find.text('A4 (210x297 mm)'), findsOneWidget);
        },
      );

      testWidgets(
        'should disable Create button when sizes loaded but name is still empty',
        (tester) async {
          // Arrange
          final completer = Completer<Result<List<domain.Size>, DomainError>>();
          final controllableRepo = _ControllableSizeRepository(completer);

          // Act
          await tester.pumpWidget(buildApp(sizeRepo: controllableRepo));
          await tester.tap(find.text('Open Dialog'));
          await tester.pump();
          await tester.pump();

          completer.complete(success([_testSize, _testSize2]));
          await tester.pumpAndSettle();

          // Assert — Create disabled with empty name
          final createButton = tester.widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Create'),
          );
          expect(createButton.onPressed, isNull);
        },
      );

      testWidgets(
        'should enable Create button after sizes load and name is filled',
        (tester) async {
          // Arrange
          final completer = Completer<Result<List<domain.Size>, DomainError>>();
          final controllableRepo = _ControllableSizeRepository(completer);

          // Act
          await tester.pumpWidget(buildApp(sizeRepo: controllableRepo));
          await tester.tap(find.text('Open Dialog'));
          await tester.pump();
          await tester.pump();

          completer.complete(success([_testSize, _testSize2]));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextField, 'Template Name'),
            'My Template',
          );
          await tester.pump();

          // Assert
          final enabledButton = tester.widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Create'),
          );
          expect(enabledButton.onPressed, isNotNull);
        },
      );
    });

    group('area selection', () {
      testWidgets('should include areaId in result when area is selected', (
        tester,
      ) async {
        // Arrange
        fakeSizeRepository.whenGetAll(success([_testSize]));
        TemplateCreateResult? capturedResult;

        // Act
        await tester.pumpWidget(
          buildApp(onSave: (result) => capturedResult = result),
        );
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

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

        await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
        await tester.pumpAndSettle();

        // Assert
        expect(capturedResult, isNotNull);
        expect(capturedResult!.areaId, 1);
      });

      testWidgets('should allow creating template without area (null areaId)', (
        tester,
      ) async {
        // Arrange
        fakeSizeRepository.whenGetAll(success([_testSize]));
        TemplateCreateResult? capturedResult;

        // Act
        await tester.pumpWidget(
          buildApp(onSave: (result) => capturedResult = result),
        );
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Template Name'),
          'Test Menu',
        );
        await tester.pump();

        // Don't select area — leave as "None"
        await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
        await tester.pumpAndSettle();

        // Assert
        expect(capturedResult, isNotNull);
        expect(capturedResult!.areaId, isNull);
      });
    });
  });
}
