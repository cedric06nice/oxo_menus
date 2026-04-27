import 'dart:typed_data';

import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/shared/presentation/utils/pdf_filename.dart';

/// Input for [GenerateMenuPdfUseCase].
///
/// Carries the menu identifier plus optional overrides surfaced by the editor
/// during a live editing session — display options that the admin tweaked
/// without reloading the schema, and an `allowedWidgets` list that's been
/// reconfigured client-side. When omitted (e.g. deep-link to the preview),
/// the use case falls back to the values stored on the menu.
final class GenerateMenuPdfInput {
  const GenerateMenuPdfInput({
    required this.menuId,
    this.displayOptionsOverride,
    this.allowedWidgetsOverride,
  });

  final int menuId;
  final MenuDisplayOptions? displayOptionsOverride;
  final List<WidgetTypeConfig>? allowedWidgetsOverride;

  @override
  bool operator ==(Object other) =>
      other is GenerateMenuPdfInput &&
      other.menuId == menuId &&
      other.displayOptionsOverride == displayOptionsOverride &&
      _listEquals(other.allowedWidgetsOverride, allowedWidgetsOverride);

  @override
  int get hashCode => Object.hash(
    menuId,
    displayOptionsOverride,
    allowedWidgetsOverride == null
        ? null
        : Object.hashAll(allowedWidgetsOverride!),
  );

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

/// Result of [GenerateMenuPdfUseCase].
///
/// Pairs the rendered PDF bytes with the suggested filename so the screen can
/// surface a single payload for the viewer + share/print actions.
final class GenerateMenuPdfOutput {
  const GenerateMenuPdfOutput({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;

  @override
  bool operator ==(Object other) =>
      other is GenerateMenuPdfOutput &&
      identical(other.bytes, bytes) &&
      other.filename == filename;

  @override
  int get hashCode => Object.hash(identityHashCode(bytes), filename);
}

/// Generates a printable PDF for a menu — the entry point the migrated
/// `PdfPreviewViewModel` calls.
///
/// Composes [FetchMenuTreeUseCase] + [GeneratePdfUseCase] and concentrates the
/// merge logic that used to live inside `PdfPreviewPage` (mixing live edits
/// with stored values).
///
/// Authorisation rule:
/// - **Authenticated user** — fetch the tree, apply the optional overrides,
///   render the PDF, and return the bytes + filename.
/// - **Anonymous viewer** — never reaches the repositories; returns
///   [UnauthorizedError].
class GenerateMenuPdfUseCase
    extends UseCase<GenerateMenuPdfInput, GenerateMenuPdfOutput> {
  GenerateMenuPdfUseCase({
    required AuthGateway authGateway,
    required FetchMenuTreeUseCase fetchMenuTree,
    required GeneratePdfUseCase generatePdf,
    DateTime Function()? now,
  }) : _authGateway = authGateway,
       _fetchMenuTree = fetchMenuTree,
       _generatePdf = generatePdf,
       _now = now ?? DateTime.now;

  final AuthGateway _authGateway;
  final FetchMenuTreeUseCase _fetchMenuTree;
  final GeneratePdfUseCase _generatePdf;
  final DateTime Function() _now;

  @override
  Future<Result<GenerateMenuPdfOutput, DomainError>> execute(
    GenerateMenuPdfInput input,
  ) async {
    if (_authGateway.currentUser == null) {
      return const Failure(UnauthorizedError());
    }

    final treeResult = await _fetchMenuTree.execute(input.menuId);
    if (treeResult.isFailure) {
      return Failure(treeResult.errorOrNull!);
    }

    final tree = treeResult.valueOrNull!;
    final overrides = input.allowedWidgetsOverride;
    final effectiveAllowed = (overrides != null && overrides.isNotEmpty)
        ? overrides
        : tree.menu.allowedWidgets;
    final effectiveOptions =
        input.displayOptionsOverride ?? tree.menu.displayOptions;

    final mergedMenu = tree.menu.copyWith(
      displayOptions: effectiveOptions,
      allowedWidgets: effectiveAllowed,
    );
    final effectiveTree = tree.copyWith(menu: mergedMenu);

    final pdfResult = await _generatePdf.execute(effectiveTree);
    if (pdfResult.isFailure) {
      return Failure(pdfResult.errorOrNull!);
    }

    final bytes = pdfResult.valueOrNull!;
    final options =
        effectiveTree.menu.displayOptions ?? const MenuDisplayOptions();
    final filename = generatePdfFilename(
      effectiveTree.menu.name,
      options,
      now: _now(),
    );

    return Success(GenerateMenuPdfOutput(bytes: bytes, filename: filename));
  }
}
