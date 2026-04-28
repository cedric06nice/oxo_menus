import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';
import 'package:oxo_menus/shared/presentation/helpers/cupertino_picker_helper.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_edit_scaffold.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';

/// Dialog for editing image properties.
///
/// Loads the available image list and per-thumbnail bytes through the injected
/// [ImageGateway]. Pure widget — no Riverpod.
class ImageEditDialog extends StatefulWidget {
  final ImageProps props;
  final ImageGateway? imageGateway;
  final void Function(ImageProps) onSave;

  const ImageEditDialog({
    super.key,
    required this.props,
    required this.onSave,
    this.imageGateway,
  });

  @override
  State<ImageEditDialog> createState() => _ImageEditDialogState();
}

class _ImageEditDialogState extends State<ImageEditDialog> {
  late String _selectedFileId;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late String _align;
  late String _fit;
  bool _isLoadingFiles = false;
  String? _filesErrorMessage;
  List<ImageFileInfo> _imageFiles = const [];

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadImageFiles();
    });
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadImageFiles() async {
    final gateway = widget.imageGateway;
    if (gateway == null) {
      return;
    }
    setState(() {
      _isLoadingFiles = true;
      _filesErrorMessage = null;
    });
    final result = await gateway.listImages();
    if (!mounted) return;
    setState(() {
      _isLoadingFiles = false;
      switch (result) {
        case Success(:final value):
          _imageFiles = value;
        case Failure(:final error):
          _filesErrorMessage = error.message;
      }
    });
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
    final alignLabels = {'left': 'Left', 'center': 'Center', 'right': 'Right'};
    final fitLabels = {
      'contain': 'Contain',
      'cover': 'Cover',
      'fill': 'Fill',
      'fitwidth': 'Fit Width',
      'fitheight': 'Fit Height',
    };

    return [
      _buildImageGrid(),
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
    return [
      _buildImageGrid(),
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

  Widget _buildImageGrid() {
    if (_isLoadingFiles) {
      return const SizedBox(
        height: 100,
        child: Center(child: AdaptiveLoadingIndicator()),
      );
    }

    if (_filesErrorMessage != null) {
      return Text(
        'Error loading images: $_filesErrorMessage',
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
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _imageFiles.length,
        itemBuilder: (context, index) {
          final file = _imageFiles[index];
          final isSelected = file.id == _selectedFileId;

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
                    Expanded(child: _buildThumbnail(file.id)),
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

  Widget _buildThumbnail(String fileId) {
    final gateway = widget.imageGateway;
    if (gateway == null) {
      return Icon(
        isApplePlatform(context)
            ? CupertinoIcons.photo
            : Icons.broken_image,
      );
    }
    return FutureBuilder<Uint8List>(
      future: gateway.getBytes(fileId),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AdaptiveLoadingIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Icon(
            isApplePlatform(context)
                ? CupertinoIcons.photo
                : Icons.broken_image,
          );
        }
        return Image.memory(
          snapshot.data!,
          fit: BoxFit.contain,
          width: double.infinity,
        );
      },
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
