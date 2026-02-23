import 'package:flutter/cupertino.dart';
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

  bool get _isApple {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

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
    return _isApple ? _buildAppleForm(context) : _buildMaterialDialog(context);
  }

  Widget _buildAppleForm(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Section'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('SECTION DETAILS'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _titleController,
                  prefix: const Text('Title'),
                  placeholder: 'Enter section title',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text('Uppercase'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: CupertinoSwitch(
                        value: _uppercase,
                        onChanged: (value) =>
                            setState(() => _uppercase = value),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text('Show Divider'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: CupertinoSwitch(
                        value: _showDivider,
                        onChanged: (value) =>
                            setState(() => _showDivider = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
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
        ElevatedButton(onPressed: _handleSave, child: const Text('Save')),
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
