import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';

/// Dialog for editing image properties
class ImageEditDialog extends StatefulWidget {
  final ImageProps props;
  final void Function(ImageProps) onSave;

  const ImageEditDialog({super.key, required this.props, required this.onSave});

  @override
  State<ImageEditDialog> createState() => _ImageEditDialogState();
}

class _ImageEditDialogState extends State<ImageEditDialog> {
  late TextEditingController _fileIdController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late String _align;
  late String _fit;

  @override
  void initState() {
    super.initState();
    _fileIdController = TextEditingController(text: widget.props.fileId);
    _widthController = TextEditingController(
      text: widget.props.width?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.props.height?.toString() ?? '',
    );
    _align = widget.props.align;
    _fit = widget.props.fit;
  }

  @override
  void dispose() {
    _fileIdController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Image'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fileIdController,
              decoration: const InputDecoration(
                labelText: 'File ID',
                hintText: 'Enter Directus file ID',
              ),
              enabled: false, // Read-only for now
            ),
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
          ],
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

  void _handleSave() {
    final width = _widthController.text.trim().isEmpty
        ? null
        : double.tryParse(_widthController.text.trim());
    final height = _heightController.text.trim().isEmpty
        ? null
        : double.tryParse(_heightController.text.trim());

    final updatedProps = ImageProps(
      fileId: _fileIdController.text.trim(),
      align: _align,
      fit: _fit,
      width: width,
      height: height,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
