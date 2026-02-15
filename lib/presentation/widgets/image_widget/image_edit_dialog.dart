import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

/// Dialog for editing image properties
class ImageEditDialog extends ConsumerStatefulWidget {
  final ImageProps props;
  final void Function(ImageProps) onSave;

  const ImageEditDialog({super.key, required this.props, required this.onSave});

  @override
  ConsumerState<ImageEditDialog> createState() => _ImageEditDialogState();
}

class _ImageEditDialogState extends ConsumerState<ImageEditDialog> {
  late String _selectedFileId;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late String _align;
  late String _fit;

  // File loading state
  List<ImageFileInfo> _imageFiles = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _selectedFileId = widget.props.fileId;
    _widthController = TextEditingController(
      text: widget.props.width?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.props.height?.toString() ?? '',
    );
    _align = widget.props.align;
    _fit = widget.props.fit;
    _loadImageFiles();
  }

  Future<void> _loadImageFiles() async {
    final fileRepository = ref.read(fileRepositoryProvider);
    final result = await fileRepository.listImageFiles();

    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        setState(() {
          _imageFiles = value;
          _isLoading = false;
        });
      case Failure(:final error):
        setState(() {
          _loadError = error.message;
          _isLoading = false;
        });
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ref.watch(directusBaseUrlProvider);

    return AlertDialog(
      title: const Text('Edit Image'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail grid section
              _buildImageGrid(baseUrl),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _align,
                decoration: const InputDecoration(labelText: 'Alignment'),
                items: const [
                  DropdownMenuItem(value: 'left', child: Text('Left')),
                  DropdownMenuItem(value: 'center', child: Text('Center')),
                  DropdownMenuItem(value: 'right', child: Text('Right')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _align = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _fit,
                decoration: const InputDecoration(labelText: 'Fit'),
                items: const [
                  DropdownMenuItem(value: 'contain', child: Text('Contain')),
                  DropdownMenuItem(value: 'cover', child: Text('Cover')),
                  DropdownMenuItem(value: 'fill', child: Text('Fill')),
                  DropdownMenuItem(
                    value: 'fitwidth',
                    child: Text('Fit Width'),
                  ),
                  DropdownMenuItem(
                    value: 'fitheight',
                    child: Text('Fit Height'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _fit = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _widthController,
                decoration: const InputDecoration(
                  labelText: 'Width',
                  hintText: 'Optional width in pixels',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height',
                  hintText: 'Optional height in pixels',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _handleSave, child: const Text('Save')),
      ],
    );
  }

  Widget _buildImageGrid(String baseUrl) {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Text(
        'Error loading images: $_loadError',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    if (_imageFiles.isEmpty) {
      return const Text('No images available');
    }

    return SizedBox(
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _imageFiles.length,
        itemBuilder: (context, index) {
          final file = _imageFiles[index];
          final isSelected = file.id == _selectedFileId;
          final thumbnailUrl =
              '$baseUrl/assets/${file.id}?width=150&height=150&fit=cover';

          return GestureDetector(
            onTap: () => setState(() => _selectedFileId = file.id),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                    if (file.title != null)
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          file.title!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSave() {
    final width = _widthController.text.trim().isEmpty
        ? null
        : double.tryParse(_widthController.text.trim());
    final height = _heightController.text.trim().isEmpty
        ? null
        : double.tryParse(_heightController.text.trim());

    final updatedProps = ImageProps(
      fileId: _selectedFileId,
      align: _align,
      fit: _fit,
      width: width,
      height: height,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
