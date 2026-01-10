import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/section/section_props.dart';

/// Dialog for editing section properties
class SectionEditDialog extends StatefulWidget {
  final SectionProps props;
  final void Function(SectionProps) onSave;

  const SectionEditDialog({
    super.key,
    required this.props,
    required this.onSave,
  });

  @override
  State<SectionEditDialog> createState() => _SectionEditDialogState();
}

class _SectionEditDialogState extends State<SectionEditDialog> {
  late TextEditingController _titleController;
  late bool _uppercase;
  late bool _showDivider;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.props.title);
    _uppercase = widget.props.uppercase;
    _showDivider = widget.props.showDivider;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Section'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter section title',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Uppercase'),
              value: _uppercase,
              onChanged: (value) => setState(() => _uppercase = value),
              dense: true,
            ),
            SwitchListTile(
              title: const Text('Show Divider'),
              value: _showDivider,
              onChanged: (value) => setState(() => _showDivider = value),
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
    final updatedProps = SectionProps(
      title: _titleController.text.trim(),
      uppercase: _uppercase,
      showDivider: _showDivider,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
