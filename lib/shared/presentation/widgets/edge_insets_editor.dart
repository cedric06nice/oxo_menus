import 'package:flutter/material.dart';

enum EdgeInsetsEditMode { all, symmetric, individual }

class EdgeInsetsEditor extends StatefulWidget {
  final String label;
  final String keyPrefix;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final bool isCompact;
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
    this.isCompact = false,
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
  void didUpdateWidget(EdgeInsetsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.top != widget.top ||
        oldWidget.bottom != widget.bottom ||
        oldWidget.left != widget.left ||
        oldWidget.right != widget.right) {
      final needsRecreation =
          _top != widget.top ||
          _bottom != widget.bottom ||
          _left != widget.left ||
          _right != widget.right;
      _top = widget.top;
      _bottom = widget.bottom;
      _left = widget.left;
      _right = widget.right;
      final newMode = EdgeInsetsEditor.detectMode(
        top: _top,
        bottom: _bottom,
        left: _left,
        right: _right,
      );
      if (needsRecreation || newMode != _currentMode) {
        _currentMode = newMode;
        _createControllers();
      }
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
    final field = TextField(
      key: Key(keyName),
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'pt',
        isDense: widget.isCompact ? true : null,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
    return widget.isCompact ? field : Expanded(child: field);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isCompact)
          Row(
            children: [
              Flexible(
                child: Text(widget.label, overflow: TextOverflow.ellipsis),
              ),
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
          )
        else ...[
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
        ],
        SizedBox(height: widget.isCompact ? 4 : 8),
        _buildModeFields(),
      ],
    );
  }

  Widget _buildModeFields() {
    final compact = widget.isCompact;
    switch (_currentMode) {
      case EdgeInsetsEditMode.all:
        if (compact) {
          return _buildField(
            'All',
            _controllers[0],
            '${widget.keyPrefix}_all',
            _onAllChanged,
          );
        }
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
        if (compact) {
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
        }
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
        if (compact) {
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
        return Row(
          children: [
            _buildField(
              'Top',
              _controllers[0],
              '${widget.keyPrefix}_top',
              (v) => _onIndividualChanged(0, v),
            ),
            const SizedBox(width: 8),
            _buildField(
              'Bottom',
              _controllers[1],
              '${widget.keyPrefix}_bottom',
              (v) => _onIndividualChanged(1, v),
            ),
            const SizedBox(width: 8),
            _buildField(
              'Left',
              _controllers[2],
              '${widget.keyPrefix}_left',
              (v) => _onIndividualChanged(2, v),
            ),
            const SizedBox(width: 8),
            _buildField(
              'Right',
              _controllers[3],
              '${widget.keyPrefix}_right',
              (v) => _onIndividualChanged(3, v),
            ),
          ],
        );
    }
  }
}
