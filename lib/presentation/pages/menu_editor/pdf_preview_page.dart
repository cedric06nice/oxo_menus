import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/presentation/providers/allowed_widgets_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/presentation/utils/pdf_filename.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_loading_indicator.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/pdf_viewer_widget.dart';

/// PDF Preview Page
///
/// Shows a full-page preview of the generated PDF menu.
/// Uses PdfPreview's built-in toolbar for print and share actions.
class PdfPreviewPage extends ConsumerWidget {
  final int menuId;
  final MenuDisplayOptions? displayOptions;

  const PdfPreviewPage({super.key, required this.menuId, this.displayOptions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isApple = isApplePlatform(context);

    return AuthenticatedScaffold(
      title: 'PDF Preview',
      body: FutureBuilder<({Uint8List bytes, String filename})?>(
        future: _generatePdf(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AdaptiveLoadingIndicator(),
                  const SizedBox(height: 16),
                  const Text('Generating PDF...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isApple
                        ? CupertinoIcons.exclamationmark_circle
                        : Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No PDF data available'));
          }

          return PdfViewerWidget(
            pdfBytes: snapshot.data!.bytes,
            filename: snapshot.data!.filename,
          );
        },
      ),
    );
  }

  Future<({Uint8List bytes, String filename})?> _generatePdf(
    WidgetRef ref,
  ) async {
    final menuTreeResult = await ref
        .read(fetchMenuTreeUseCaseProvider)
        .execute(menuId);

    if (menuTreeResult.isFailure) {
      throw Exception(
        menuTreeResult.errorOrNull?.message ?? 'Failed to load menu',
      );
    }

    final menuTree = menuTreeResult.valueOrNull!;

    // Merge live alignment state (admin may have configured alignment during
    // this session before schema roundtrip preserves it).
    final liveAllowedWidgets = ref.read(allowedWidgetsProvider);
    final mergedMenu = menuTree.menu.copyWith(
      displayOptions: displayOptions ?? menuTree.menu.displayOptions,
      allowedWidgets: liveAllowedWidgets.isNotEmpty
          ? liveAllowedWidgets
          : menuTree.menu.allowedWidgets,
    );
    final effectiveTree = menuTree.copyWith(menu: mergedMenu);

    final pdfResult = await ref
        .read(generatePdfUseCaseProvider)
        .execute(effectiveTree);

    if (pdfResult.isFailure) {
      throw Exception(
        pdfResult.errorOrNull?.message ?? 'Failed to generate PDF',
      );
    }

    final effectiveOptions =
        effectiveTree.menu.displayOptions ?? const MenuDisplayOptions();

    return (
      bytes: pdfResult.valueOrNull!,
      filename: generatePdfFilename(effectiveTree.menu.name, effectiveOptions),
    );
  }
}
