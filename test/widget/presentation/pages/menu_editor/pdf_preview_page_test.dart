import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/presentation/pages/menu_editor/pdf_preview_page.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/pdf_viewer_widget.dart';

import '../../../../fakes/fake_fetch_menu_tree_usecase.dart';
import '../../../../fakes/fake_generate_pdf_usecase.dart';
import '../../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Fake that pends forever to expose loading state
// ---------------------------------------------------------------------------

class _PendingFetchMenuTreeUseCase extends FakeFetchMenuTreeUseCase {
  @override
  Future<Result<MenuTree, DomainError>> execute(int menuId) async {
    calls.add(FetchMenuTreeCall(menuId: menuId));
    // Never completes — keeps the page in its loading state
    return Completer<Result<MenuTree, DomainError>>().future;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeFetchMenuTreeUseCase fakeFetchMenuTree;
  late FakeGeneratePdfUseCase fakeGeneratePdf;

  setUp(() {
    fakeFetchMenuTree = FakeFetchMenuTreeUseCase();
    fakeGeneratePdf = FakeGeneratePdfUseCase();
  });

  Widget buildPage({
    TargetPlatform platform = TargetPlatform.android,
    bool pendingForever = false,
    MenuDisplayOptions? displayOptions,
  }) {
    final fetchUseCase = pendingForever
        ? _PendingFetchMenuTreeUseCase()
        : fakeFetchMenuTree;

    return ProviderScope(
      overrides: [
        fetchMenuTreeUseCaseProvider.overrideWithValue(fetchUseCase),
        generatePdfUseCaseProvider.overrideWithValue(fakeGeneratePdf),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        home: PdfPreviewPage(menuId: 1, displayOptions: displayOptions),
      ),
    );
  }

  group('PdfPreviewPage', () {
    testWidgets('should use AuthenticatedScaffold with PDF Preview title', (
      WidgetTester tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(buildPage(pendingForever: true));
      await tester.pump();

      // Assert
      expect(find.byType(AuthenticatedScaffold), findsOneWidget);
      expect(find.text('PDF Preview'), findsOneWidget);
    });

    testWidgets('should not render download or print action buttons', (
      WidgetTester tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(buildPage(pendingForever: true));
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.download), findsNothing);
      expect(find.byIcon(Icons.print), findsNothing);
      expect(find.byKey(const Key('download_pdf_button')), findsNothing);
      expect(find.byKey(const Key('print_pdf_button')), findsNothing);
    });

    testWidgets('should not render a Dialog widget', (
      WidgetTester tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(buildPage(pendingForever: true));
      await tester.pump();

      // Assert
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should show CupertinoActivityIndicator while loading on iOS', (
      WidgetTester tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(
        buildPage(platform: TargetPlatform.iOS, pendingForever: true),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
      'should show CircularProgressIndicator while loading on Android',
      (WidgetTester tester) async {
        // Arrange + Act
        await tester.pumpWidget(buildPage(pendingForever: true));
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      },
    );

    testWidgets('should show Generating PDF text while loading', (
      WidgetTester tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(buildPage(pendingForever: true));
      await tester.pump();

      // Assert
      expect(find.text('Generating PDF...'), findsOneWidget);
    });

    testWidgets(
      'should show error state with Cupertino icon on iOS when fetch fails',
      (WidgetTester tester) async {
        // Arrange
        fakeFetchMenuTree.stubExecute(
          failure(const ServerError('PDF generation failed')),
        );

        // Act
        await tester.pumpWidget(buildPage(platform: TargetPlatform.iOS));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.byIcon(CupertinoIcons.exclamationmark_circle),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should show error state with Material icon on Android when fetch fails',
      (WidgetTester tester) async {
        // Arrange
        fakeFetchMenuTree.stubExecute(
          failure(const ServerError('PDF generation failed')),
        );

        // Act
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      },
    );

    testWidgets(
      'should override menu displayOptions when displayOptions are provided',
      (WidgetTester tester) async {
        // Arrange
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

        fakeFetchMenuTree.stubExecute(success(menuTree));

        MenuTree? capturedTree;
        fakeGeneratePdf.stubExecute(failure(const ServerError('test')));

        const overrideOptions = MenuDisplayOptions(
          showPrices: false,
          showAllergens: false,
        );

        // Act
        await tester.pumpWidget(buildPage(displayOptions: overrideOptions));
        await tester.pumpAndSettle();

        // Capture the tree passed to generatePdf
        capturedTree = fakeGeneratePdf.calls.isNotEmpty
            ? fakeGeneratePdf.calls.last.menuTree
            : null;

        // Assert
        expect(capturedTree, isNotNull);
        expect(capturedTree!.menu.displayOptions?.showPrices, isFalse);
        expect(capturedTree.menu.displayOptions?.showAllergens, isFalse);
      },
    );

    testWidgets('should use menu displayOptions when no override is provided', (
      WidgetTester tester,
    ) async {
      // Arrange
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

      fakeFetchMenuTree.stubExecute(success(menuTree));
      fakeGeneratePdf.stubExecute(failure(const ServerError('test')));

      // Act
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      final capturedTree = fakeGeneratePdf.calls.isNotEmpty
          ? fakeGeneratePdf.calls.last.menuTree
          : null;

      // Assert
      expect(capturedTree, isNotNull);
      expect(capturedTree!.menu.displayOptions?.showPrices, isTrue);
      expect(capturedTree.menu.displayOptions?.showAllergens, isTrue);
    });

    testWidgets(
      'should generate filename containing menu name and Allergy label when allergens shown',
      (WidgetTester tester) async {
        // Arrange
        final menu = Menu(
          id: 1,
          name: 'Restaurant A La Carte',
          status: Status.draft,
          version: '1',
          displayOptions: const MenuDisplayOptions(
            showPrices: true,
            showAllergens: true,
          ),
        );
        final menuTree = MenuTree(menu: menu, pages: const []);
        final pdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);

        fakeFetchMenuTree.stubExecute(success(menuTree));
        fakeGeneratePdf.stubExecute(success(pdfBytes));

        // Act
        await tester.pumpWidget(buildPage());
        await tester.pump();
        await tester.pump();

        // Assert
        final viewer = tester.widget<PdfViewerWidget>(
          find.byType(PdfViewerWidget),
        );
        expect(viewer.filename, contains('Restaurant A La Carte'));
        expect(viewer.filename, contains('Allergy'));
        expect(viewer.filename, endsWith('.pdf'));
      },
    );

    testWidgets(
      'should generate filename without Allergy label when allergens not shown',
      (WidgetTester tester) async {
        // Arrange
        final menu = Menu(
          id: 1,
          name: 'Dinner Menu',
          status: Status.draft,
          version: '1',
          displayOptions: const MenuDisplayOptions(
            showPrices: true,
            showAllergens: true,
          ),
        );
        final menuTree = MenuTree(menu: menu, pages: const []);
        final pdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);

        fakeFetchMenuTree.stubExecute(success(menuTree));
        fakeGeneratePdf.stubExecute(success(pdfBytes));

        const overrideOptions = MenuDisplayOptions(
          showPrices: false,
          showAllergens: false,
        );

        // Act
        await tester.pumpWidget(buildPage(displayOptions: overrideOptions));
        await tester.pump();
        await tester.pump();

        // Assert
        final viewer = tester.widget<PdfViewerWidget>(
          find.byType(PdfViewerWidget),
        );
        expect(viewer.filename, contains('Dinner Menu'));
        expect(viewer.filename, contains('No Prices'));
        expect(viewer.filename, isNot(contains('Allergy')));
        expect(viewer.filename, endsWith('.pdf'));
      },
    );
  });
}
