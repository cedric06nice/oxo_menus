import 'package:flutter/material.dart';
import 'package:oxo_menus/presentation/widgets/common/edge_insets_editor.dart';

class CompactEdgeInsetsEditor extends StatefulWidget {
  final String label;
  final String keyPrefix;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final void Function({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) onChanged;

  const CompactEdgeInsetsEditor({
    super.key,
    required this.label,
    required this.keyPrefix,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.onChanged,
  });

  @override
  State<CompactEdgeInsetsEditor> createState() =>
      _CompactEdgeInsetsEditorState();
}

class _CompactEdgeInsetsEditorState extends State<CompactEdgeInsetsEditor> {
  late EdgeInsetsEditMode _currentMode;
  late double? _top, _bottom, _left, _right;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _top = widget.top;
    _bottom = widget.bottom;
    _left = widget.left;
    _right = widget.right;
    _currentMode = EdgeInsetsEditor.detectMode(
      top: _top,
      bottom: _bottom,
      left: _left,
      right: _right,
    );
    _createControllers();
  }

  @override
  void didUpdateWidget(CompactEdgeInsetsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.top != widget.top ||
        oldWidget.bottom != widget.bottom ||
        oldWidget.left != widget.left ||
        oldWidget.right != widget.right) {
      _top = widget.top;
      _bottom = widget.bottom;
      _left = widget.left;
      _right = widget.right;
      _currentMode = EdgeInsetsEditor.detectMode(
        top: _top,
        bottom: _bottom,
        left: _left,
        right: _right,
      );
      _createControllers();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _createControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    switch (_currentMode) {
      case EdgeInsetsEditMode.all:
        _controllers.add(TextEditingController(text: _formatValue(_top)));
      case EdgeInsetsEditMode.symmetric:
        _controllers.add(TextEditingController(text: _formatValue(_top)));
        _controllers.add(TextEditingController(text: _formatValue(_left)));
      case EdgeInsetsEditMode.individual:
        _controllers.addAll([
          TextEditingController(text: _formatValue(_top)),
          TextEditingController(text: _formatValue(_bottom)),
          TextEditingController(text: _formatValue(_left)),
          TextEditingController(text: _formatValue(_right)),
        ]);
    }
  }

  String _formatValue(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  void _fireChanged() {
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  void _onAllChanged(String value) {
    final parsed = double.tryParse(value);
    _top = parsed;
    _bottom = parsed;
    _left = parsed;
    _right = parsed;
    _fireChanged();
  }

  void _onSymmetricVerticalChanged(String value) {
    final parsed = double.tryParse(value);
    _top = parsed;
    _bottom = parsed;
    _fireChanged();
  }

  void _onSymmetricHorizontalChanged(String value) {
    final parsed = double.tryParse(value);
    _left = parsed;
    _right = parsed;
    _fireChanged();
  }

  void _onIndividualChanged(int index, String value) {
    final parsed = double.tryParse(value);
    switch (index) {
      case 0:
        _top = parsed;
      case 1:
        _bottom = parsed;
      case 2:
        _left = parsed;
      case 3:
        _right = parsed;
    }
    _fireChanged();
  }

  void _switchToMode(EdgeInsetsEditMode? newMode) {
    if (newMode == null || newMode == _currentMode) return;

    switch (newMode) {
      case EdgeInsetsEditMode.all:
        final singleValue = _top ?? 0.0;
        _top = singleValue;
        _bottom = singleValue;
        _left = singleValue;
        _right = singleValue;
      case EdgeInsetsEditMode.symmetric:
        final vertical = _top ?? 0.0;
        final horizontal = _left ?? 0.0;
        _top = vertical;
        _bottom = vertical;
        _left = horizontal;
        _right = horizontal;
      case EdgeInsetsEditMode.individual:
        break;
    }

    setState(() {
      _currentMode = newMode;
      _createControllers();
    });

    _fireChanged();
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String keyName,
    void Function(String) onChanged,
  ) {
    return TextField(
      key: Key(keyName),
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'pt',
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 4),
            DropdownButton<EdgeInsetsEditMode>(
              key: Key('${widget.keyPrefix}_mode_dropdown'),
              value: _currentMode,
              isDense: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: EdgeInsetsEditMode.all,
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: EdgeInsetsEditMode.symmetric,
                  child: Text('Symmetric'),
                ),
                DropdownMenuItem(
                  value: EdgeInsetsEditMode.individual,
                  child: Text('Individual'),
                ),
              ],
              onChanged: _switchToMode,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildModeFields(),
      ],
    );
  }

  Widget _buildModeFields() {
    switch (_currentMode) {
      case EdgeInsetsEditMode.all:
        return _buildField(
          'All',
          _controllers[0],
          '${widget.keyPrefix}_all',
          _onAllChanged,
        );
      case EdgeInsetsEditMode.symmetric:
        return Column(
          children: [
            _buildField(
              'V',
              _controllers[0],
              '${widget.keyPrefix}_vertical',
              _onSymmetricVerticalChanged,
            ),
            const SizedBox(height: 4),
            _buildField(
              'H',
              _controllers[1],
              '${widget.keyPrefix}_horizontal',
              _onSymmetricHorizontalChanged,
            ),
          ],
        );
      case EdgeInsetsEditMode.individual:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'T',
                    _controllers[0],
                    '${widget.keyPrefix}_top',
                    (v) => _onIndividualChanged(0, v),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildField(
                    'B',
                    _controllers[1],
                    '${widget.keyPrefix}_bottom',
                    (v) => _onIndividualChanged(1, v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'L',
                    _controllers[2],
                    '${widget.keyPrefix}_left',
                    (v) => _onIndividualChanged(2, v),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildField(
                    'R',
                    _controllers[3],
                    '${widget.keyPrefix}_right',
                    (v) => _onIndividualChanged(3, v),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}
