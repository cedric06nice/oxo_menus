import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_edit_scaffold.dart';

/// Dialog for editing text properties
class TextEditDialog extends StatefulWidget {
  final TextProps props;
  final void Function(TextProps) onSave;

  const TextEditDialog({super.key, required this.props, required this.onSave});

  @override
  State<TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<TextEditDialog> {
  late TextEditingController _textController;
  late double _fontSize;
  late String _align;
  late bool _bold;
  late bool _italic;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.props.text);
    _fontSize = widget.props.fontSize;
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
    return AdaptiveEditScaffold(
      title: 'Edit Text',
      onSave: _handleSave,
      appleFormChildren: _buildAppleFormChildren(context),
      materialFormChildren: _buildMaterialFormChildren(),
    );
  }

  List<Widget> _buildAppleFormChildren(BuildContext context) {
    final alignLabels = {'left': 'Left', 'center': 'Center', 'right': 'Right'};

    return [
      CupertinoFormSection.insetGrouped(
        header: const Text('TEXT CONTENT'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: CupertinoTextField(
              controller: _textController,
              placeholder: 'Enter text content',
              maxLines: 5,
            ),
          ),
        ],
      ),
      CupertinoFormSection.insetGrouped(
        header: const Text('FORMATTING'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text('Font Size'),
                const SizedBox(width: 12),
                Text('${_fontSize.toInt()}'),
                Expanded(
                  child: CupertinoSlider(
                    value: _fontSize,
                    min: 4,
                    max: 36,
                    divisions: 28,
                    onChanged: (value) => setState(() => _fontSize = value),
                  ),
                ),
              ],
            ),
          ),
          _buildPickerRow(
            'Alignment',
            alignLabels[_align] ?? 'Left',
            () => _showAlignmentPicker(context),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text('Bold'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: CupertinoSwitch(
                  value: _bold,
                  onChanged: (value) => setState(() => _bold = value),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text('Italic'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: CupertinoSwitch(
                  value: _italic,
                  onChanged: (value) => setState(() => _italic = value),
                ),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  Widget _buildPickerRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(color: CupertinoColors.secondaryLabel),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAlignmentPicker(BuildContext context) {
    final alignments = ['left', 'center', 'right'];
    final labels = ['Left', 'Center', 'Right'];
    var selectedIndex = alignments.indexOf(_align).clamp(0, 2);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(popupContext),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () {
                    Navigator.of(popupContext).pop();
                    setState(() => _align = alignments[selectedIndex]);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                itemExtent: 32,
                onSelectedItemChanged: (index) => selectedIndex = index,
                children: labels.map((l) => Center(child: Text(l))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMaterialFormChildren() {
    return [
      TextField(
        controller: _textController,
        decoration: const InputDecoration(
          labelText: 'Text',
          hintText: 'Enter text content',
        ),
        maxLines: 5,
      ),
      const SizedBox(height: 12),
      Slider(
        value: _fontSize,
        min: 4,
        max: 36,
        divisions: 28,
        label: 'Font Size: ${_fontSize.toInt()}',
        onChanged: (value) => setState(() => _fontSize = value),
      ),
      const SizedBox(height: 8),
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
    ];
  }

  void _handleSave() {
    final updatedProps = TextProps(
      text: _textController.text.trim(),
      fontSize: _fontSize,
      align: _align,
      bold: _bold,
      italic: _italic,
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
