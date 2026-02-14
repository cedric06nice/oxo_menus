import 'package:flutter/material.dart';

enum EdgeInsetsEditMode { all, symmetric, individual }

class EdgeInsetsEditor extends StatefulWidget {
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
  })
  onChanged;

  const EdgeInsetsEditor({
    super.key,
    required this.label,
    required this.keyPrefix,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.onChanged,
  });

  static EdgeInsetsEditMode detectMode({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final effectiveTop = top ?? 0.0;
    final effectiveBottom = bottom ?? 0.0;
    final effectiveLeft = left ?? 0.0;
    final effectiveRight = right ?? 0.0;

    if (effectiveTop == effectiveBottom &&
        effectiveBottom == effectiveLeft &&
        effectiveLeft == effectiveRight) {
      return EdgeInsetsEditMode.all;
    }

    if (effectiveTop == effectiveBottom && effectiveLeft == effectiveRight) {
      return EdgeInsetsEditMode.symmetric;
    }

    return EdgeInsetsEditMode.individual;
  }

  @override
  State<EdgeInsetsEditor> createState() => _EdgeInsetsEditorState();
}

class _EdgeInsetsEditorState extends State<EdgeInsetsEditor> {
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

  void _onAllChanged(String value) {
    final parsed = double.tryParse(value);
    _top = parsed;
    _bottom = parsed;
    _left = parsed;
    _right = parsed;
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  void _onSymmetricVerticalChanged(String value) {
    final parsed = double.tryParse(value);
    _top = parsed;
    _bottom = parsed;
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  void _onSymmetricHorizontalChanged(String value) {
    final parsed = double.tryParse(value);
    _left = parsed;
    _right = parsed;
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  void _onIndividualTopChanged(String value) {
    _top = double.tryParse(value);
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  void _onIndividualBottomChanged(String value) {
    _bottom = double.tryParse(value);
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  void _onIndividualLeftChanged(String value) {
    _left = double.tryParse(value);
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  void _onIndividualRightChanged(String value) {
    _right = double.tryParse(value);
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  void _switchToMode(EdgeInsetsEditMode newMode) {
    if (newMode == _currentMode) return;

    // Compute new values based on mode transition
    switch (newMode) {
      case EdgeInsetsEditMode.all:
        // Use top value as single value
        final singleValue = _top ?? 0.0;
        _top = singleValue;
        _bottom = singleValue;
        _left = singleValue;
        _right = singleValue;
      case EdgeInsetsEditMode.symmetric:
        // Use top as vertical, left as horizontal
        final vertical = _top ?? 0.0;
        final horizontal = _left ?? 0.0;
        _top = vertical;
        _bottom = vertical;
        _left = horizontal;
        _right = horizontal;
      case EdgeInsetsEditMode.individual:
        // Keep current values as-is
        break;
    }

    setState(() {
      _currentMode = newMode;
      _createControllers();
    });

    // Fire onChanged with new values
    widget.onChanged(top: _top, bottom: _bottom, left: _left, right: _right);
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String keyName,
    void Function(String) onChanged,
  ) {
    return Expanded(
      child: TextField(
        key: Key(keyName),
        controller: controller,
        decoration: InputDecoration(labelText: label, suffixText: 'pt'),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        SegmentedButton<EdgeInsetsEditMode>(
          key: Key('${widget.keyPrefix}_mode_selector'),
          segments: const [
            ButtonSegment(value: EdgeInsetsEditMode.all, label: Text('All')),
            ButtonSegment(
              value: EdgeInsetsEditMode.symmetric,
              label: Text('Symmetric'),
            ),
            ButtonSegment(
              value: EdgeInsetsEditMode.individual,
              label: Text('Individual'),
            ),
          ],
          selected: {_currentMode},
          onSelectionChanged: (Set<EdgeInsetsEditMode> newSelection) {
            if (newSelection.isNotEmpty) {
              _switchToMode(newSelection.first);
            }
          },
        ),
        const SizedBox(height: 8),
        _buildModeFields(),
      ],
    );
  }

  Widget _buildModeFields() {
    switch (_currentMode) {
      case EdgeInsetsEditMode.all:
        return Row(
          children: [
            _buildField(
              'All',
              _controllers[0],
              '${widget.keyPrefix}_all',
              _onAllChanged,
            ),
          ],
        );
      case EdgeInsetsEditMode.symmetric:
        return Row(
          children: [
            _buildField(
              'Vertical',
              _controllers[0],
              '${widget.keyPrefix}_vertical',
              _onSymmetricVerticalChanged,
            ),
            const SizedBox(width: 8),
            _buildField(
              'Horizontal',
              _controllers[1],
              '${widget.keyPrefix}_horizontal',
              _onSymmetricHorizontalChanged,
            ),
          ],
        );
      case EdgeInsetsEditMode.individual:
        return Row(
          children: [
            _buildField(
              'Top',
              _controllers[0],
              '${widget.keyPrefix}_top',
              _onIndividualTopChanged,
            ),
            const SizedBox(width: 8),
            _buildField(
              'Bottom',
              _controllers[1],
              '${widget.keyPrefix}_bottom',
              _onIndividualBottomChanged,
            ),
            const SizedBox(width: 8),
            _buildField(
              'Left',
              _controllers[2],
              '${widget.keyPrefix}_left',
              _onIndividualLeftChanged,
            ),
            const SizedBox(width: 8),
            _buildField(
              'Right',
              _controllers[3],
              '${widget.keyPrefix}_right',
              _onIndividualRightChanged,
            ),
          ],
        );
    }
  }
}
