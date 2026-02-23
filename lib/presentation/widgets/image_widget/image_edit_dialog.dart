import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/presentation/helpers/cupertino_picker_helper.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_edit_scaffold.dart';

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

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

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
    return AdaptiveEditScaffold(
      title: 'Edit Image',
      onSave: _handleSave,
      appleFormChildren: _buildAppleFormChildren(context),
      materialFormChildren: _buildMaterialFormChildren(context),
    );
  }

  List<Widget> _buildAppleFormChildren(BuildContext context) {
    final baseUrl = ref.watch(directusBaseUrlProvider);
    final alignLabels = {'left': 'Left', 'center': 'Center', 'right': 'Right'};
    final fitLabels = {
      'contain': 'Contain',
      'cover': 'Cover',
      'fill': 'Fill',
      'fitwidth': 'Fit Width',
      'fitheight': 'Fit Height',
    };

    return [
      _buildImageGrid(baseUrl),
      CupertinoFormSection.insetGrouped(
        header: const Text('LAYOUT'),
        children: [
          CupertinoListTile(
            title: const Text('Alignment'),
            additionalInfo: Text(alignLabels[_align] ?? 'Center'),
            trailing: const CupertinoListTileChevron(),
            onTap: () {
              final alignments = ['left', 'center', 'right'];
              showCupertinoPicker<String>(
                context,
                items: alignments,
                currentValue: _align,
                labelBuilder: (a) => alignLabels[a] ?? a,
                onSelected: (v) => setState(() => _align = v),
              );
            },
          ),
          CupertinoListTile(
            title: const Text('Fit'),
            additionalInfo: Text(fitLabels[_fit] ?? 'Contain'),
            trailing: const CupertinoListTileChevron(),
            onTap: () {
              final fits = fitLabels.keys.toList();
              showCupertinoPicker<String>(
                context,
                items: fits,
                currentValue: _fit,
                labelBuilder: (f) => fitLabels[f] ?? f,
                onSelected: (v) => setState(() => _fit = v),
              );
            },
          ),
          CupertinoTextFormFieldRow(
            controller: _widthController,
            prefix: const Text('Width'),
            placeholder: 'Optional width in pixels',
            keyboardType: TextInputType.number,
          ),
          CupertinoTextFormFieldRow(
            controller: _heightController,
            prefix: const Text('Height'),
            placeholder: 'Optional height in pixels',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMaterialFormChildren(BuildContext context) {
    final baseUrl = ref.watch(directusBaseUrlProvider);

    return [
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
          DropdownMenuItem(value: 'fitwidth', child: Text('Fit Width')),
          DropdownMenuItem(value: 'fitheight', child: Text('Fit Height')),
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
    ];
  }

  Widget _buildImageGrid(String baseUrl) {
    if (_isLoading) {
      return SizedBox(
        height: 100,
        child: Center(
          child: _isApple
              ? const CupertinoActivityIndicator()
              : const CircularProgressIndicator(),
        ),
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
                      : Theme.of(context).colorScheme.outlineVariant,
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
                        errorBuilder: (_, _, _) => Icon(
                          _isApple ? CupertinoIcons.photo : Icons.broken_image,
                        ),
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
