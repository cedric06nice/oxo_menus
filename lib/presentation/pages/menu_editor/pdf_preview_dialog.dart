import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';
import 'package:printing/printing.dart';

/// PDF Preview Dialog
///
/// Shows a preview of the generated PDF menu with options to download or print.
class PdfPreviewDialog extends ConsumerWidget {
  final int menuId;

  const PdfPreviewDialog({super.key, required this.menuId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isApple =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;

    return Dialog(
      child: SizedBox(
        width: 600,
        height: 800,
        child: Column(
          children: [
            if (isApple)
              _buildCupertinoNavBar(context, ref)
            else
              _buildMaterialAppBar(context, ref),
            Expanded(
              child: FutureBuilder<Uint8List?>(
                future: _generatePdf(ref),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isApple)
                            const CupertinoActivityIndicator()
                          else
                            const CircularProgressIndicator(),
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
                          const SizedBox(height: 16),
                          if (isApple)
                            CupertinoButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            )
                          else
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No PDF data available'));
                  }

                  return PdfPreview(
                    build: (format) => snapshot.data!,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('PDF Preview'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          key: const Key('download_pdf_button'),
          icon: const Icon(Icons.download),
          onPressed: () => _downloadPdf(context, ref),
          tooltip: 'Download PDF',
        ),
        IconButton(
          key: const Key('print_pdf_button'),
          icon: const Icon(Icons.print),
          onPressed: () => _printPdf(context, ref),
          tooltip: 'Print PDF',
        ),
      ],
    );
  }

  Widget _buildCupertinoNavBar(BuildContext context, WidgetRef ref) {
    return CupertinoNavigationBar(
      middle: const Text('PDF Preview'),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(CupertinoIcons.xmark),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            key: const Key('download_pdf_button'),
            padding: EdgeInsets.zero,
            onPressed: () => _downloadPdf(context, ref),
            child: const Icon(CupertinoIcons.arrow_down_doc),
          ),
          CupertinoButton(
            key: const Key('print_pdf_button'),
            padding: EdgeInsets.zero,
            onPressed: () => _printPdf(context, ref),
            child: const Icon(CupertinoIcons.printer),
          ),
        ],
      ),
    );
  }

  /// Generate PDF from menu tree
  Future<Uint8List?> _generatePdf(WidgetRef ref) async {
    try {
      // Fetch menu tree
      final menuTreeResult = await ref
          .read(fetchMenuTreeUseCaseProvider)
          .execute(menuId);

      if (menuTreeResult.isFailure) {
        throw Exception(
          menuTreeResult.errorOrNull?.message ?? 'Failed to load menu',
        );
      }

      final menuTree = menuTreeResult.valueOrNull!;

      // Generate PDF
      final pdfResult = await ref
          .read(generatePdfUseCaseProvider)
          .execute(menuTree);

      if (pdfResult.isFailure) {
        throw Exception(
          pdfResult.errorOrNull?.message ?? 'Failed to generate PDF',
        );
      }

      return pdfResult.valueOrNull!;
    } catch (e) {
      rethrow;
    }
  }

  /// Download PDF file
  Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
    try {
      final bytes = await _generatePdf(ref);
      if (bytes == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate PDF')),
          );
        }
        return;
      }

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'menu_${DateTime.now().toIso8601String().split('T')[0]}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF downloaded successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
      }
    }
  }

  /// Print PDF
  Future<void> _printPdf(BuildContext context, WidgetRef ref) async {
    try {
      final bytes = await _generatePdf(ref);
      if (bytes == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate PDF')),
          );
        }
        return;
      }

      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error printing PDF: $e')));
      }
    }
  }
}
