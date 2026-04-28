import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class PdfViewerWidget extends StatefulWidget {
  final Uint8List pdfBytes;
  final String filename;

  const PdfViewerWidget({
    super.key,
    required this.pdfBytes,
    required this.filename,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  late final String _viewType;
  String? _blobUrl;

  @override
  void initState() {
    super.initState();
    _viewType = 'pdf-viewer-${widget.hashCode}';
    _createBlobUrl();
    _registerViewFactory();
  }

  void _createBlobUrl() {
    final blob = web.Blob(
      [widget.pdfBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    _blobUrl = web.URL.createObjectURL(blob);
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement
            ..src = _blobUrl!
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';
      return iframe;
    });
  }

  @override
  void dispose() {
    if (_blobUrl != null) {
      web.URL.revokeObjectURL(_blobUrl!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Download PDF',
                onPressed: _downloadPdf,
              ),
            ],
          ),
        ),
        Expanded(child: HtmlElementView(viewType: _viewType)),
      ],
    );
  }

  void _downloadPdf() {
    final blob = web.Blob(
      [widget.pdfBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = widget.filename;
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
