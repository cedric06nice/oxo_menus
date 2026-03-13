import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/widgets/common/edge_insets_editor.dart';

class SidePanelStyleEditor extends StatefulWidget {
  final EditorElementType type;
  final StyleConfig? styleConfig;
  final StyleConfig? clipboardStyle;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final ValueChanged<StyleConfig> onStyleChanged;
  final bool? isDroppable;
  final ValueChanged<bool>? onDroppableChanged;
  final PageSize? pageSize;
  final VoidCallback? onPageSizePressed;

  const SidePanelStyleEditor({
    super.key,
    required this.type,
    required this.styleConfig,
    required this.clipboardStyle,
    required this.onCopy,
    required this.onPaste,
    required this.onStyleChanged,
    this.isDroppable,
    this.onDroppableChanged,
    this.pageSize,
    this.onPageSizePressed,
  });

  @override
  State<SidePanelStyleEditor> createState() => _SidePanelStyleEditorState();
}

class _SidePanelStyleEditorState extends State<SidePanelStyleEditor> {
  late BorderType _selectedBorderType;

  @override
  void initState() {
    super.initState();
    _selectedBorderType = widget.styleConfig?.borderType ?? BorderType.none;
  }

  @override
  void didUpdateWidget(SidePanelStyleEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.styleConfig?.borderType != widget.styleConfig?.borderType) {
      _selectedBorderType = widget.styleConfig?.borderType ?? BorderType.none;
    }
  }

  String get _title => switch (widget.type) {
    EditorElementType.menu => 'Menu Style',
    EditorElementType.container => 'Container Style',
    EditorElementType.column => 'Column Style',
  };

  StyleConfig get _style => widget.styleConfig ?? const StyleConfig();

  void _onBorderTypeChanged(BorderType? newType) {
    if (newType != null) {
      setState(() {
        _selectedBorderType = newType;
      });
      widget.onStyleChanged(_style.copyWith(borderType: newType));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + copy/paste buttons
          Row(
            children: [
              Expanded(
                child: Text(
                  _title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                key: const Key('copy_style_button'),
                icon: const Icon(Icons.copy, size: 18),
                onPressed: widget.onCopy,
                tooltip: 'Copy Style',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                key: const Key('paste_style_button'),
                icon: const Icon(Icons.paste, size: 18),
                onPressed: widget.clipboardStyle != null
                    ? widget.onPaste
                    : null,
                tooltip: 'Paste Style',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Page Size (menu only)
          if (widget.type == EditorElementType.menu)
            ListTile(
              key: const Key('page_size_tile'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Page Size'),
              subtitle: Text(widget.pageSize?.name ?? 'Not set'),
              trailing: IconButton(
                key: const Key('change_page_size_button'),
                icon: const Icon(Icons.edit, size: 18),
                onPressed: widget.onPageSizePressed,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ),

          // Droppable switch (column only)
          if (widget.type == EditorElementType.column &&
              widget.isDroppable != null &&
              widget.onDroppableChanged != null)
            SwitchListTile.adaptive(
              title: const Text('Allow Widget Drops'),
              value: widget.isDroppable!,
              onChanged: widget.onDroppableChanged,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

          // Margins
          EdgeInsetsEditor(
            isCompact: true,
            label: 'Margins',
            keyPrefix: 'side_margin',
            top: _style.marginTop,
            bottom: _style.marginBottom,
            left: _style.marginLeft,
            right: _style.marginRight,
            onChanged: ({top, bottom, left, right}) {
              widget.onStyleChanged(
                _style.copyWith(
                  marginTop: top,
                  marginBottom: bottom,
                  marginLeft: left,
                  marginRight: right,
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Border
          Text('Border', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          DropdownButtonFormField<BorderType>(
            key: const Key('side_border_type'),
            initialValue: _selectedBorderType,
            decoration: const InputDecoration(isDense: true),
            isExpanded: true,
            items: BorderType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
                )
                .toList(),
            onChanged: _onBorderTypeChanged,
          ),
          const SizedBox(height: 12),

          // Paddings
          EdgeInsetsEditor(
            isCompact: true,
            label: 'Paddings',
            keyPrefix: 'side_padding',
            top: _style.paddingTop,
            bottom: _style.paddingBottom,
            left: _style.paddingLeft,
            right: _style.paddingRight,
            onChanged: ({top, bottom, left, right}) {
              widget.onStyleChanged(
                _style.copyWith(
                  paddingTop: top,
                  paddingBottom: bottom,
                  paddingLeft: left,
                  paddingRight: right,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
