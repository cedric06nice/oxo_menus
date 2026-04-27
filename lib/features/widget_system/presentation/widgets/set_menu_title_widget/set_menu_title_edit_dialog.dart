import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/set_menu_title/set_menu_title_props.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_edit_scaffold.dart';

/// Dialog for editing set menu title properties
class SetMenuTitleEditDialog extends StatefulWidget {
  final SetMenuTitleProps props;
  final void Function(SetMenuTitleProps) onSave;

  const SetMenuTitleEditDialog({
    super.key,
    required this.props,
    required this.onSave,
  });

  @override
  State<SetMenuTitleEditDialog> createState() => _SetMenuTitleEditDialogState();
}

class _SetMenuTitleEditDialogState extends State<SetMenuTitleEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _priceLabel1Controller;
  late TextEditingController _price1Controller;
  late TextEditingController _priceLabel2Controller;
  late TextEditingController _price2Controller;
  late bool _uppercase;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.props.title);
    _subtitleController = TextEditingController(
      text: widget.props.subtitle ?? '',
    );
    _priceLabel1Controller = TextEditingController(
      text: widget.props.priceLabel1 ?? '',
    );
    _price1Controller = TextEditingController(
      text: widget.props.price1?.toString() ?? '',
    );
    _priceLabel2Controller = TextEditingController(
      text: widget.props.priceLabel2 ?? '',
    );
    _price2Controller = TextEditingController(
      text: widget.props.price2?.toString() ?? '',
    );
    _uppercase = widget.props.uppercase;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _priceLabel1Controller.dispose();
    _price1Controller.dispose();
    _priceLabel2Controller.dispose();
    _price2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveEditScaffold(
      title: 'Edit Set Menu Title',
      onSave: _handleSave,
      appleFormChildren: _buildAppleFormChildren(),
      materialFormChildren: _buildMaterialFormChildren(),
    );
  }

  List<Widget> _buildAppleFormChildren() {
    return [
      CupertinoFormSection.insetGrouped(
        header: const Text('TITLE'),
        children: [
          CupertinoTextFormFieldRow(
            controller: _titleController,
            prefix: const Text('Title'),
            placeholder: 'Enter title',
          ),
          CupertinoTextFormFieldRow(
            controller: _subtitleController,
            prefix: const Text('Subtitle'),
            placeholder: 'Enter subtitle',
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
                  onChanged: (value) => setState(() => _uppercase = value),
                ),
              ),
            ],
          ),
        ],
      ),
      CupertinoFormSection.insetGrouped(
        header: const Text('PRICING'),
        children: [
          CupertinoTextFormFieldRow(
            controller: _priceLabel1Controller,
            prefix: const Text('Label 1'),
            placeholder: 'e.g. 3 Courses',
          ),
          CupertinoTextFormFieldRow(
            controller: _price1Controller,
            prefix: const Text('Price 1'),
            placeholder: 'Enter price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          CupertinoTextFormFieldRow(
            controller: _priceLabel2Controller,
            prefix: const Text('Label 2'),
            placeholder: 'e.g. 4 Courses',
          ),
          CupertinoTextFormFieldRow(
            controller: _price2Controller,
            prefix: const Text('Price 2'),
            placeholder: 'Enter price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMaterialFormChildren() {
    return [
      TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Title',
          hintText: 'Enter title',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _subtitleController,
        decoration: const InputDecoration(
          labelText: 'Subtitle (optional)',
          hintText: 'Enter subtitle',
        ),
      ),
      const SizedBox(height: 8),
      SwitchListTile(
        title: const Text('Uppercase'),
        value: _uppercase,
        onChanged: (value) => setState(() => _uppercase = value),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _priceLabel1Controller,
        decoration: const InputDecoration(
          labelText: 'Price label 1 (optional)',
          hintText: 'e.g. 3 Courses',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _price1Controller,
        decoration: const InputDecoration(
          labelText: 'Price 1',
          hintText: 'Enter price',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _priceLabel2Controller,
        decoration: const InputDecoration(
          labelText: 'Price label 2 (optional)',
          hintText: 'e.g. 4 Courses',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _price2Controller,
        decoration: const InputDecoration(
          labelText: 'Price 2',
          hintText: 'Enter price',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 8),
    ];
  }

  void _handleSave() {
    final label1 = _priceLabel1Controller.text.trim();
    final label2 = _priceLabel2Controller.text.trim();

    final updatedProps = SetMenuTitleProps(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      uppercase: _uppercase,
      priceLabel1: label1.isEmpty ? null : label1,
      price1: double.tryParse(_price1Controller.text),
      priceLabel2: label2.isEmpty ? null : label2,
      price2: double.tryParse(_price2Controller.text),
    );

    widget.onSave(updatedProps);
    Navigator.of(context).pop();
  }
}
