import 'package:flutter/material.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/pdf_preview_screen_state.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/pdf_preview_view_model.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/pdf_viewer_widget.dart';

/// MVVM-stack PDF preview screen.
///
/// Pure widget — owns no Riverpod providers and no navigation. Reads the
/// generation status from the injected [PdfPreviewViewModel] and forwards
/// retry / back actions back to it. Renders [PdfViewerWidget] once the bytes
/// are available; surfaces errors with a retry affordance.
class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({super.key, required this.viewModel});

  final PdfPreviewViewModel viewModel;

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: widget.viewModel.goBack,
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, PdfPreviewScreenState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AdaptiveLoadingIndicator(),
            SizedBox(height: 16),
            Text('Generating PDF...'),
          ],
        ),
      );
    }

    final error = state.errorMessage;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.viewModel.retry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final bytes = state.pdfBytes;
    final filename = state.filename;
    if (bytes == null || filename == null) {
      return const Center(child: Text('No PDF data available'));
    }

    return PdfViewerWidget(pdfBytes: bytes, filename: filename);
  }
}
