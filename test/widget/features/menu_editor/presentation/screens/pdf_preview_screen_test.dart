import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/pdf_preview_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/pdf_preview_view_model.dart';

import '../../../../../helpers/build_view_model_test_harness.dart';

class _FakeGeneratePdf implements GenerateMenuPdfUseCase {
  Result<GenerateMenuPdfOutput, DomainError> result = Success(
    GenerateMenuPdfOutput(
      bytes: Uint8List.fromList(const [1, 2, 3]),
      filename: 'menu.pdf',
    ),
  );
  Completer<Result<GenerateMenuPdfOutput, DomainError>>? gate;
  final List<GenerateMenuPdfInput> calls = [];

  @override
  Future<Result<GenerateMenuPdfOutput, DomainError>> execute(
    GenerateMenuPdfInput input,
  ) {
    calls.add(input);
    if (gate != null) {
      return gate!.future;
    }
    return Future.value(result);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingRouter implements PdfPreviewRouter {
  int backCalls = 0;

  @override
  void goBack() => backCalls++;
}

PdfPreviewViewModel _buildVm({
  _FakeGeneratePdf? generate,
  _RecordingRouter? router,
}) {
  return PdfPreviewViewModel(
    menuId: 1,
    generatePdf: generate ?? _FakeGeneratePdf(),
    router: router ?? _RecordingRouter(),
  );
}

void main() {
  group('PdfPreviewScreen — loading state', () {
    testWidgets('shows a loading indicator while generation is in flight', (
      tester,
    ) async {
      final generate = _FakeGeneratePdf()
        ..gate = Completer<Result<GenerateMenuPdfOutput, DomainError>>();
      final vm = _buildVm(generate: generate);
      await pumpScreenWithViewModel<PdfPreviewViewModel>(
        tester,
        viewModel: vm,
        screenBuilder: (vm) => PdfPreviewScreen(viewModel: vm),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating PDF...'), findsOneWidget);

      generate.gate!.complete(
        const Failure<GenerateMenuPdfOutput, DomainError>(NetworkError('done')),
      );
    });
  });

  group('PdfPreviewScreen — error state', () {
    testWidgets('renders the error message returned by the VM', (tester) async {
      final generate = _FakeGeneratePdf()
        ..result = const Failure(NetworkError('boom'));
      final vm = _buildVm(generate: generate);
      await pumpScreenWithViewModel<PdfPreviewViewModel>(
        tester,
        viewModel: vm,
        screenBuilder: (vm) => PdfPreviewScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('boom'), findsOneWidget);
    });

    testWidgets('error state offers a retry button that re-runs generation', (
      tester,
    ) async {
      final generate = _FakeGeneratePdf()
        ..result = const Failure(NetworkError('boom'));
      final vm = _buildVm(generate: generate);
      await pumpScreenWithViewModel<PdfPreviewViewModel>(
        tester,
        viewModel: vm,
        screenBuilder: (vm) => PdfPreviewScreen(viewModel: vm),
      );
      await tester.pumpAndSettle();
      expect(generate.calls, hasLength(1));

      // Retry returns another failure so the test stays in the error state
      // without rendering the platform PDF viewer.
      generate.result = const Failure(NetworkError('still boom'));

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(generate.calls, hasLength(2));
    });
  });

  group('PdfPreviewScreen — chrome', () {
    testWidgets('AppBar title is "PDF Preview" while still generating', (
      tester,
    ) async {
      final generate = _FakeGeneratePdf()
        ..gate = Completer<Result<GenerateMenuPdfOutput, DomainError>>();
      final vm = _buildVm(generate: generate);
      await pumpScreenWithViewModel<PdfPreviewViewModel>(
        tester,
        viewModel: vm,
        screenBuilder: (vm) => PdfPreviewScreen(viewModel: vm),
      );
      await tester.pump();

      expect(find.widgetWithText(AppBar, 'PDF Preview'), findsOneWidget);

      generate.gate!.complete(generate.result);
    });

    testWidgets('AppBar back button calls router.goBack', (tester) async {
      final router = _RecordingRouter();
      final generate = _FakeGeneratePdf()
        ..gate = Completer<Result<GenerateMenuPdfOutput, DomainError>>();
      final vm = _buildVm(router: router, generate: generate);
      await pumpScreenWithViewModel<PdfPreviewViewModel>(
        tester,
        viewModel: vm,
        screenBuilder: (vm) => PdfPreviewScreen(viewModel: vm),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(router.backCalls, 1);

      generate.gate!.complete(generate.result);
    });
  });
}
