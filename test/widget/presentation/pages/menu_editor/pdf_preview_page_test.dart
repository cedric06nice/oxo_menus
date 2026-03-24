import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/pdf_preview_page.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';

import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';

class MockFetchMenuTreeUseCase extends Mock implements FetchMenuTreeUseCase {}

class MockGeneratePdfUseCase extends Mock implements GeneratePdfUseCase {}

class FakeMenuTree extends Fake implements MenuTree {}

void main() {
  late MockFetchMenuTreeUseCase mockFetchMenuTree;
  late MockGeneratePdfUseCase mockGeneratePdf;

  setUpAll(() {
    registerFallbackValue(FakeMenuTree());
  });

  setUp(() {
    mockFetchMenuTree = MockFetchMenuTreeUseCase();
    mockGeneratePdf = MockGeneratePdfUseCase();
  });

  Widget buildWidget({
    TargetPlatform platform = TargetPlatform.android,
    bool pendingForever = false,
    MenuDisplayOptions? displayOptions,
  }) {
    if (pendingForever) {
      when(
        () => mockFetchMenuTree.execute(any()),
      ).thenAnswer((_) => Completer<Result<MenuTree, DomainError>>().future);
    }

    return ProviderScope(
      overrides: [
        fetchMenuTreeUseCaseProvider.overrideWithValue(mockFetchMenuTree),
        generatePdfUseCaseProvider.overrideWithValue(mockGeneratePdf),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        home: PdfPreviewPage(menuId: 1, displayOptions: displayOptions),
      ),
    );
  }

  group('PdfPreviewPage', () {
    testWidgets('uses AuthenticatedScaffold with PDF Preview title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(pendingForever: true));
      await tester.pump();

      expect(find.byType(AuthenticatedScaffold), findsOneWidget);
      expect(find.text('PDF Preview'), findsOneWidget);
    });

    testWidgets('does not render custom download or print buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(pendingForever: true));
      await tester.pump();

      expect(find.byIcon(Icons.download), findsNothing);
      expect(find.byIcon(Icons.print), findsNothing);
      expect(find.byKey(const Key('download_pdf_button')), findsNothing);
      expect(find.byKey(const Key('print_pdf_button')), findsNothing);
    });

    testWidgets('does not render Dialog widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(pendingForever: true));
      await tester.pump();

      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('shows CupertinoActivityIndicator while loading on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(platform: TargetPlatform.iOS, pendingForever: true),
      );
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows CircularProgressIndicator while loading on Android', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(pendingForever: true));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('shows error state with Cupertino icon on iOS', (
      WidgetTester tester,
    ) async {
      when(() => mockFetchMenuTree.execute(any())).thenAnswer(
        (_) async => const Failure<MenuTree, DomainError>(
          ServerError('PDF generation failed'),
        ),
      );

      await tester.pumpWidget(buildWidget(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      expect(
        find.byIcon(CupertinoIcons.exclamationmark_circle),
        findsOneWidget,
      );
    });

    testWidgets('shows error state with Material icon on Android', (
      WidgetTester tester,
    ) async {
      when(() => mockFetchMenuTree.execute(any())).thenAnswer(
        (_) async => const Failure<MenuTree, DomainError>(
          ServerError('PDF generation failed'),
        ),
      );

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows Generating PDF text while loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(pendingForever: true));
      await tester.pump();

      expect(find.text('Generating PDF...'), findsOneWidget);
    });

    testWidgets('overrides menu displayOptions when provided', (
      WidgetTester tester,
    ) async {
      final menu = Menu(
        id: 1,
        name: 'Test',
        status: Status.draft,
        version: '1',
        displayOptions: const MenuDisplayOptions(
          showPrices: true,
          showAllergens: true,
        ),
      );
      final menuTree = MenuTree(menu: menu, pages: const []);

      when(
        () => mockFetchMenuTree.execute(1),
      ).thenAnswer((_) async => Success(menuTree));

      MenuTree? capturedTree;
      when(() => mockGeneratePdf.execute(any())).thenAnswer((inv) async {
        capturedTree = inv.positionalArguments[0] as MenuTree;
        return const Failure(ServerError('test'));
      });

      const overrideOptions = MenuDisplayOptions(
        showPrices: false,
        showAllergens: false,
      );

      await tester.pumpWidget(buildWidget(displayOptions: overrideOptions));
      await tester.pumpAndSettle();

      expect(capturedTree, isNotNull);
      expect(capturedTree!.menu.displayOptions?.showPrices, false);
      expect(capturedTree!.menu.displayOptions?.showAllergens, false);
    });

    testWidgets('uses menu displayOptions when none provided', (
      WidgetTester tester,
    ) async {
      final menu = Menu(
        id: 1,
        name: 'Test',
        status: Status.draft,
        version: '1',
        displayOptions: const MenuDisplayOptions(
          showPrices: true,
          showAllergens: true,
        ),
      );
      final menuTree = MenuTree(menu: menu, pages: const []);

      when(
        () => mockFetchMenuTree.execute(1),
      ).thenAnswer((_) async => Success(menuTree));

      MenuTree? capturedTree;
      when(() => mockGeneratePdf.execute(any())).thenAnswer((inv) async {
        capturedTree = inv.positionalArguments[0] as MenuTree;
        return const Failure(ServerError('test'));
      });

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(capturedTree, isNotNull);
      expect(capturedTree!.menu.displayOptions?.showPrices, true);
      expect(capturedTree!.menu.displayOptions?.showAllergens, true);
    });
  });
}
