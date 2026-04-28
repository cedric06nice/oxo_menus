import 'dart:async';

import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/pdf_preview_screen_state.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';

/// View model that owns the PDF-preview screen's state.
///
/// Eagerly drives [GenerateMenuPdfUseCase] on construction. Surfaces three
/// shapes: loading, failure (with retry), success (bytes + filename). Knows
/// nothing about widgets, `BuildContext`, or Riverpod — the screen reads
/// state and forwards `goBack` / `retry` back to the VM.
class PdfPreviewViewModel extends ViewModel<PdfPreviewScreenState> {
  PdfPreviewViewModel({
    required int menuId,
    required GenerateMenuPdfUseCase generatePdf,
    required PdfPreviewRouter router,
    MenuDisplayOptions? displayOptionsOverride,
    List<WidgetTypeConfig>? allowedWidgetsOverride,
  }) : _menuId = menuId,
       _generatePdf = generatePdf,
       _router = router,
       _displayOptionsOverride = displayOptionsOverride,
       _allowedWidgetsOverride = allowedWidgetsOverride,
       super(const PdfPreviewScreenState()) {
    unawaited(_load());
  }

  final int _menuId;
  final GenerateMenuPdfUseCase _generatePdf;
  final PdfPreviewRouter _router;
  final MenuDisplayOptions? _displayOptionsOverride;
  final List<WidgetTypeConfig>? _allowedWidgetsOverride;

  /// Re-runs PDF generation. No-op while a generation is already in flight.
  Future<void> retry() async {
    if (state.isLoading) {
      return;
    }
    await _load();
  }

  /// Pop the preview and return to the previous screen.
  void goBack() => _router.goBack();

  Future<void> _load() async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        pdfBytes: null,
        filename: null,
      ),
    );
    final result = await _generatePdf.execute(
      GenerateMenuPdfInput(
        menuId: _menuId,
        displayOptionsOverride: _displayOptionsOverride,
        allowedWidgetsOverride: _allowedWidgetsOverride,
      ),
    );
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (output) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: null,
            pdfBytes: output.bytes,
            filename: output.filename,
          ),
        );
      },
      onFailure: (error) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: error.message,
            pdfBytes: null,
            filename: null,
          ),
        );
      },
    );
  }
}
