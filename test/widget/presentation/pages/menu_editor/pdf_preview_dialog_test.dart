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
import 'package:oxo_menus/presentation/pages/menu_editor/pdf_preview_dialog.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

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
  }) {
    if (pendingForever) {
      // Never resolve to keep loading state
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
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const PdfPreviewDialog(menuId: 1),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('PdfPreviewDialog', () {
    testWidgets('renders AppBar with Material icons on Android', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(pendingForever: true));
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.byIcon(Icons.print), findsOneWidget);
    });

    testWidgets('renders CupertinoNavigationBar on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(platform: TargetPlatform.iOS, pendingForever: true),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('uses CupertinoIcons on iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(platform: TargetPlatform.iOS, pendingForever: true),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.arrow_down_doc), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.printer), findsOneWidget);
    });

    testWidgets('shows CupertinoActivityIndicator while loading on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(platform: TargetPlatform.iOS, pendingForever: true),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows CircularProgressIndicator while loading on Android', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(pendingForever: true));
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });
  });
}
