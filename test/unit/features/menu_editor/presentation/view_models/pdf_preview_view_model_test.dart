import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/pdf_preview_view_model.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';

class _FakeGeneratePdf implements GenerateMenuPdfUseCase {
  Result<GenerateMenuPdfOutput, DomainError> result = Success(
    GenerateMenuPdfOutput(
      bytes: Uint8List.fromList(const [1, 2, 3]),
      filename: 'menu.pdf',
    ),
  );
  final List<GenerateMenuPdfInput> calls = [];
  Completer<Result<GenerateMenuPdfOutput, DomainError>>? _gate;

  void blockNextCall() {
    _gate = Completer<Result<GenerateMenuPdfOutput, DomainError>>();
  }

  void release() {
    _gate?.complete(result);
    _gate = null;
  }

  @override
  Future<Result<GenerateMenuPdfOutput, DomainError>> execute(
    GenerateMenuPdfInput input,
  ) {
    calls.add(input);
    if (_gate != null) {
      return _gate!.future;
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

({PdfPreviewViewModel vm, _FakeGeneratePdf generate, _RecordingRouter router})
_buildVm({
  int menuId = 42,
  MenuDisplayOptions? displayOptionsOverride,
  List<WidgetTypeConfig>? allowedWidgetsOverride,
  _FakeGeneratePdf? generate,
}) {
  final useCase = generate ?? _FakeGeneratePdf();
  final router = _RecordingRouter();
  final vm = PdfPreviewViewModel(
    menuId: menuId,
    generatePdf: useCase,
    router: router,
    displayOptionsOverride: displayOptionsOverride,
    allowedWidgetsOverride: allowedWidgetsOverride,
  );
  return (vm: vm, generate: useCase, router: router);
}

void main() {
  group('PdfPreviewViewModel — initial state', () {
    test('starts with isLoading=true and no payload', () {
      final generate = _FakeGeneratePdf()..blockNextCall();
      final harness = _buildVm(generate: generate);
      addTearDown(harness.vm.dispose);

      expect(harness.vm.state.isLoading, isTrue);
      expect(harness.vm.state.errorMessage, isNull);
      expect(harness.vm.state.pdfBytes, isNull);
      expect(harness.vm.state.filename, isNull);

      generate.release();
    });
  });

  group('PdfPreviewViewModel — eager generation', () {
    test(
      'drives the use case with the menuId and overrides on construction',
      () async {
        const override = MenuDisplayOptions(showPrices: false);
        const allowed = <WidgetTypeConfig>[WidgetTypeConfig(type: 'dish')];
        final harness = _buildVm(
          menuId: 99,
          displayOptionsOverride: override,
          allowedWidgetsOverride: allowed,
        );
        addTearDown(harness.vm.dispose);

        await Future<void>.delayed(Duration.zero);

        expect(harness.generate.calls.single.menuId, 99);
        expect(harness.generate.calls.single.displayOptionsOverride, override);
        expect(harness.generate.calls.single.allowedWidgetsOverride, allowed);
      },
    );

    test('on success exposes bytes + filename and clears isLoading', () async {
      final bytes = Uint8List.fromList(const [9, 8, 7]);
      final generate = _FakeGeneratePdf()
        ..result = Success(
          GenerateMenuPdfOutput(bytes: bytes, filename: 'fancy.pdf'),
        );
      final harness = _buildVm(generate: generate);
      addTearDown(harness.vm.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isLoading, isFalse);
      expect(harness.vm.state.pdfBytes, same(bytes));
      expect(harness.vm.state.filename, 'fancy.pdf');
      expect(harness.vm.state.errorMessage, isNull);
    });

    test('on failure exposes errorMessage and clears isLoading', () async {
      final generate = _FakeGeneratePdf()
        ..result = const Failure(NetworkError('boom'));
      final harness = _buildVm(generate: generate);
      addTearDown(harness.vm.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state.isLoading, isFalse);
      expect(harness.vm.state.errorMessage, 'boom');
      expect(harness.vm.state.pdfBytes, isNull);
      expect(harness.vm.state.filename, isNull);
    });
  });

  group('PdfPreviewViewModel — retry', () {
    test('retry re-runs the use case and replays loading flag', () async {
      final generate = _FakeGeneratePdf()
        ..result = const Failure(NetworkError('boom'));
      final harness = _buildVm(generate: generate);
      addTearDown(harness.vm.dispose);
      await Future<void>.delayed(Duration.zero);
      expect(harness.vm.state.errorMessage, 'boom');

      final bytes = Uint8List.fromList(const [4, 5, 6]);
      generate.result = Success(
        GenerateMenuPdfOutput(bytes: bytes, filename: 'second.pdf'),
      );
      generate.blockNextCall();
      final retryFuture = harness.vm.retry();

      expect(harness.vm.state.isLoading, isTrue);
      expect(harness.vm.state.errorMessage, isNull);

      generate.release();
      await retryFuture;

      expect(harness.generate.calls, hasLength(2));
      expect(harness.vm.state.isLoading, isFalse);
      expect(harness.vm.state.pdfBytes, same(bytes));
      expect(harness.vm.state.filename, 'second.pdf');
    });

    test('retry is a no-op while a generation is already in flight', () async {
      final generate = _FakeGeneratePdf()..blockNextCall();
      final harness = _buildVm(generate: generate);
      addTearDown(harness.vm.dispose);

      final retryFuture = harness.vm.retry();
      await retryFuture;

      expect(harness.generate.calls, hasLength(1));

      generate.release();
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('PdfPreviewViewModel — navigation', () {
    test('goBack delegates to router.goBack', () async {
      final harness = _buildVm();
      addTearDown(harness.vm.dispose);

      harness.vm.goBack();

      expect(harness.router.backCalls, 1);
    });
  });

  group('PdfPreviewViewModel — disposal', () {
    test('dispose marks the VM as disposed', () async {
      final harness = _buildVm();

      harness.vm.dispose();

      expect(harness.vm.isDisposed, isTrue);
    });

    test('does not emit when generation completes after dispose', () async {
      final generate = _FakeGeneratePdf()..blockNextCall();
      final harness = _buildVm(generate: generate);
      final initialState = harness.vm.state;

      harness.vm.dispose();
      generate.release();
      await Future<void>.delayed(Duration.zero);

      expect(harness.vm.state, initialState);
    });
  });
}
