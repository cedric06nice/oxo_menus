import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';

/// Dialog for editing text properties
class TextEditDialog extends StatefulWidget {
  final TextProps props;
  final void Function(TextProps) onSave;

  const TextEditDialog({
    super.key,
    required this.props,
    required this.onSave,
  });

  @override
  State<TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<TextEditDialog> {
  late TextEditingController _textController;
  late String _align;
  late bool _bold;
  late bool _italic;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.props.text);
    _align = widget.props.align;
    _bold = widget.props.bold;
    _italic = widget.props.italic;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Text'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Text',
                hintText: 'Enter text content',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _align,
              decoration: const InputDecoration(
                labelText: 'Alignment',
              ),
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
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Bold'),
              value: _bold,
              onChanged: (value) => setState(() => _bold = value),
              dense: true,
            ),
            SwitchListTile(
              title: const Text('Italic'),
              value: _italic,
              onChanged: (value) => setState(() => _italic = value),
              dense: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _handleSave() {
    final updatedProps = TextProps(
      text: _textController.text.trim(),
      align: _align,
      bold: _bold,
      italic: _italic,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
