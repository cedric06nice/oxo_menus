import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/features/menu_list/presentation/widgets/template_create_dialog.dart';

import '../../../../../fakes/fake_size_repository.dart';
import '../../../../../fakes/fake_area_repository.dart';
import '../../../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Local helper fake — controlled via a Completer so no pending timers are
// created. The test owner must complete or GC the completer after pumping.
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

void main() {
  late FakeSizeRepository fakeSizeRepository;
  late FakeAreaRepository fakeAreaRepository;

  const testSize = domain.Size(
    id: 1,
    name: 'A4',
    width: 210,
    height: 297,
    direction: 'portrait',
    status: Status.published,
  );

  setUp(() {
    fakeSizeRepository = FakeSizeRepository();
    fakeAreaRepository = FakeAreaRepository();
    fakeAreaRepository.whenGetAll(success([const Area(id: 1, name: 'Dining')]));
  });

  Widget buildMaterialApp({
    void Function(TemplateCreateResult)? onSave,
    SizeRepository? sizeRepo,
  }) {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => TemplateCreateDialog(
                onSave: onSave ?? (_) {},
                sizeRepository: sizeRepo ?? fakeSizeRepository,
                areaRepository: fakeAreaRepository,
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  Widget buildIosApp({
    void Function(TemplateCreateResult)? onSave,
    SizeRepository? sizeRepo,
  }) {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => TemplateCreateDialog(
                  onSave: onSave ?? (_) {},
                  sizeRepository: sizeRepo ?? fakeSizeRepository,
                  areaRepository: fakeAreaRepository,
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('TemplateCreateDialog', () {
    group('Material (Android)', () {
      testWidgets('should render AlertDialog when platform is Android', (
        WidgetTester tester,
      ) async {
        fakeSizeRepository.whenGetAll(success([testSize]));

        await tester.pumpWidget(buildMaterialApp());
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Create Template'), findsOneWidget);
      });

      testWidgets('should show loading indicator while sizes are loading', (
        WidgetTester tester,
      ) async {
        final completer = Completer<Result<List<domain.Size>, DomainError>>();
        final controllableRepo = _ControllableSizeRepository(completer);

        await tester.pumpWidget(buildMaterialApp(sizeRepo: controllableRepo));
        await tester.tap(find.text('Open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Loading sizes...'), findsOneWidget);

        completer.complete(success([testSize]));
        await tester.pumpAndSettle();
      });

      testWidgets('should show Page Size dropdown when sizes are available', (
        WidgetTester tester,
      ) async {
        fakeSizeRepository.whenGetAll(success([testSize]));

        await tester.pumpWidget(buildMaterialApp());
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Page Size'), findsOneWidget);
        expect(find.text('Manage Page Sizes'), findsNothing);
      });

      testWidgets(
        'should show "No page sizes available" message when sizes list is empty',
        (WidgetTester tester) async {
          fakeSizeRepository.whenGetAll(success(<domain.Size>[]));

          await tester.pumpWidget(buildMaterialApp());
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.text('No page sizes available.'), findsOneWidget);
        },
      );

      testWidgets(
        'should show "Manage Page Sizes" button when sizes list is empty',
        (WidgetTester tester) async {
          fakeSizeRepository.whenGetAll(success(<domain.Size>[]));

          await tester.pumpWidget(buildMaterialApp());
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.text('Manage Page Sizes'), findsOneWidget);
        },
      );

      testWidgets('should show Area dropdown when areas are available', (
        WidgetTester tester,
      ) async {
        fakeSizeRepository.whenGetAll(success([testSize]));

        await tester.pumpWidget(buildMaterialApp());
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Area'), findsOneWidget);
      });

      testWidgets('should disable Create button when name is empty', (
        WidgetTester tester,
      ) async {
        fakeSizeRepository.whenGetAll(success([testSize]));

        await tester.pumpWidget(buildMaterialApp());
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final createButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Create'),
        );
        expect(createButton.onPressed, isNull);
      });

      testWidgets(
        'should enable Create button when name and size are provided',
        (WidgetTester tester) async {
          fakeSizeRepository.whenGetAll(success([testSize]));

          await tester.pumpWidget(buildMaterialApp());
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

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

      testWidgets(
        'should call onSave with correct name when Create is tapped',
        (WidgetTester tester) async {
          fakeSizeRepository.whenGetAll(success([testSize]));
          TemplateCreateResult? capturedResult;

          await tester.pumpWidget(
            buildMaterialApp(onSave: (result) => capturedResult = result),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextField, 'Template Name'),
            'My Template',
          );
          await tester.pump();
          await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
          await tester.pumpAndSettle();

          expect(capturedResult, isNotNull);
          expect(capturedResult!.name, 'My Template');
        },
      );

      testWidgets(
        'should call onSave with correct sizeId when Create is tapped',
        (WidgetTester tester) async {
          fakeSizeRepository.whenGetAll(success([testSize]));
          TemplateCreateResult? capturedResult;

          await tester.pumpWidget(
            buildMaterialApp(onSave: (result) => capturedResult = result),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextField, 'Template Name'),
            'My Template',
          );
          await tester.pump();
          await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
          await tester.pumpAndSettle();

          expect(capturedResult, isNotNull);
          expect(capturedResult!.sizeId, 1);
        },
      );

      testWidgets(
        'should call onSave with null areaId when no area is selected',
        (WidgetTester tester) async {
          fakeSizeRepository.whenGetAll(success([testSize]));
          TemplateCreateResult? capturedResult;

          await tester.pumpWidget(
            buildMaterialApp(onSave: (result) => capturedResult = result),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextField, 'Template Name'),
            'My Template',
          );
          await tester.pump();
          await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
          await tester.pumpAndSettle();

          expect(capturedResult, isNotNull);
          expect(capturedResult!.areaId, isNull);
        },
      );

      testWidgets('should call onSave with areaId when area is selected', (
        WidgetTester tester,
      ) async {
        fakeSizeRepository.whenGetAll(success([testSize]));
        TemplateCreateResult? capturedResult;

        await tester.pumpWidget(
          buildMaterialApp(onSave: (result) => capturedResult = result),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Template Name'),
          'My Template',
        );
        await tester.pump();

        await tester.tap(find.text('Area').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dining').last);
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
        await tester.pumpAndSettle();

        expect(capturedResult, isNotNull);
        expect(capturedResult!.areaId, 1);
      });

      testWidgets('should dismiss dialog when Cancel is tapped', (
        WidgetTester tester,
      ) async {
        fakeSizeRepository.whenGetAll(success([testSize]));

        await tester.pumpWidget(buildMaterialApp());
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Create Template'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      });
    });

    group('Cupertino (iOS)', () {
      testWidgets('should render CupertinoPageScaffold when platform is iOS', (
        WidgetTester tester,
      ) async {
        fakeSizeRepository.whenGetAll(success([testSize]));

        await tester.pumpWidget(buildIosApp());
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoPageScaffold), findsOneWidget);
        expect(find.text('Create Template'), findsOneWidget);
      });

      testWidgets('should render CupertinoNavigationBar when platform is iOS', (
        WidgetTester tester,
      ) async {
        fakeSizeRepository.whenGetAll(success([testSize]));

        await tester.pumpWidget(buildIosApp());
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      });

      testWidgets(
        'should render CupertinoTextFormFieldRow fields when platform is iOS',
        (WidgetTester tester) async {
          fakeSizeRepository.whenGetAll(success([testSize]));

          await tester.pumpWidget(buildIosApp());
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.byType(CupertinoTextFormFieldRow), findsNWidgets(2));
        },
      );

      testWidgets(
        'should show CupertinoActivityIndicator while sizes are loading on iOS',
        (WidgetTester tester) async {
          final completer = Completer<Result<List<domain.Size>, DomainError>>();
          final controllableRepo = _ControllableSizeRepository(completer);

          await tester.pumpWidget(buildIosApp(sizeRepo: controllableRepo));
          await tester.tap(find.text('Open'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

          completer.complete(success([testSize]));
          await tester.pumpAndSettle();
        },
      );
    });
  });
}
