import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfViewerWidget extends StatelessWidget {
  final Uint8List pdfBytes;
  final String filename;

  const PdfViewerWidget({
    super.key,
    required this.pdfBytes,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: PdfPreview(
        build: (format) => pdfBytes,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: false,
        allowSharing: true,
        pdfFileName: filename,
        useActions: false,
        actions: [
          PdfPreviewAction(
            icon: Icon(isApple ? CupertinoIcons.share_up : Icons.share),
            onPressed: (context, _, _) {
              Printing.sharePdf(bytes: pdfBytes, filename: filename);
            },
          ),
        ],
      ),
    );
  }
}
