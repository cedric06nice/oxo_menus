import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

class PageStyleSection extends StatefulWidget {
  final String title;
  final StyleConfig? styleConfig;
  final ValueChanged<StyleConfig> onStyleChanged;

  const PageStyleSection({
    super.key,
    this.title = 'Page Style',
    required this.styleConfig,
    required this.onStyleChanged,
  });

  @override
  State<PageStyleSection> createState() => _PageStyleSectionState();
}

class _PageStyleSectionState extends State<PageStyleSection> {
  late BorderType _selectedBorderType;
  late final TextEditingController _marginTopCtrl;
  late final TextEditingController _marginBottomCtrl;
  late final TextEditingController _marginLeftCtrl;
  late final TextEditingController _marginRightCtrl;
  late final TextEditingController _paddingTopCtrl;
  late final TextEditingController _paddingBottomCtrl;
  late final TextEditingController _paddingLeftCtrl;
  late final TextEditingController _paddingRightCtrl;

  @override
  void initState() {
    super.initState();
    _selectedBorderType = widget.styleConfig?.borderType ?? BorderType.none;
    _marginTopCtrl = TextEditingController(
      text: _formatValue(widget.styleConfig?.marginTop),
    );
    _marginBottomCtrl = TextEditingController(
      text: _formatValue(widget.styleConfig?.marginBottom),
    );
    _marginLeftCtrl = TextEditingController(
      text: _formatValue(widget.styleConfig?.marginLeft),
    );
    _marginRightCtrl = TextEditingController(
      text: _formatValue(widget.styleConfig?.marginRight),
    );
    _paddingTopCtrl = TextEditingController(
      text: _formatValue(widget.styleConfig?.paddingTop),
    );
    _paddingBottomCtrl = TextEditingController(
      text: _formatValue(widget.styleConfig?.paddingBottom),
    );
    _paddingLeftCtrl = TextEditingController(
      text: _formatValue(widget.styleConfig?.paddingLeft),
    );
    _paddingRightCtrl = TextEditingController(
      text: _formatValue(widget.styleConfig?.paddingRight),
    );
  }

  @override
  void dispose() {
    _marginTopCtrl.dispose();
    _marginBottomCtrl.dispose();
    _marginLeftCtrl.dispose();
    _marginRightCtrl.dispose();
    _paddingTopCtrl.dispose();
    _paddingBottomCtrl.dispose();
    _paddingLeftCtrl.dispose();
    _paddingRightCtrl.dispose();
    super.dispose();
  }

  String _formatValue(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  void _onFieldChanged() {
    final current = widget.styleConfig ?? const StyleConfig();
    widget.onStyleChanged(current.copyWith(
      marginTop: double.tryParse(_marginTopCtrl.text),
      marginBottom: double.tryParse(_marginBottomCtrl.text),
      marginLeft: double.tryParse(_marginLeftCtrl.text),
      marginRight: double.tryParse(_marginRightCtrl.text),
      paddingTop: double.tryParse(_paddingTopCtrl.text),
      paddingBottom: double.tryParse(_paddingBottomCtrl.text),
      paddingLeft: double.tryParse(_paddingLeftCtrl.text),
      paddingRight: double.tryParse(_paddingRightCtrl.text),
      borderType: _selectedBorderType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Margins', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildField('Top', _marginTopCtrl, 'margin_top'),
                const SizedBox(width: 8),
                _buildField('Bottom', _marginBottomCtrl, 'margin_bottom'),
                const SizedBox(width: 8),
                _buildField('Left', _marginLeftCtrl, 'margin_left'),
                const SizedBox(width: 8),
                _buildField('Right', _marginRightCtrl, 'margin_right'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Border', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<BorderType>(
              key: const Key('border_type'),
              initialValue: _selectedBorderType,
              decoration: const InputDecoration(
                labelText: 'Border Style',
              ),
              items: BorderType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBorderType = value;
                  });
                  _onFieldChanged();
                }
              },
            ),
            const SizedBox(height: 16),
            Text('Paddings', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildField('Top', _paddingTopCtrl, 'padding_top'),
                const SizedBox(width: 8),
                _buildField('Bottom', _paddingBottomCtrl, 'padding_bottom'),
                const SizedBox(width: 8),
                _buildField('Left', _paddingLeftCtrl, 'padding_left'),
                const SizedBox(width: 8),
                _buildField('Right', _paddingRightCtrl, 'padding_right'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String keyName) {
    return Expanded(
      child: TextField(
        key: Key(keyName),
        controller: ctrl,
        decoration: InputDecoration(labelText: label, suffixText: 'pt'),
        keyboardType: TextInputType.number,
        onChanged: (_) => _onFieldChanged(),
      ),
    );
  }
}
