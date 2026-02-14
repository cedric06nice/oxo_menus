import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/widgets/common/edge_insets_editor.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedBorderType = widget.styleConfig?.borderType ?? BorderType.none;
  }

  void _onBorderTypeChanged(BorderType? newType) {
    if (newType != null) {
      setState(() {
        _selectedBorderType = newType;
      });
      final current = widget.styleConfig ?? const StyleConfig();
      widget.onStyleChanged(current.copyWith(borderType: _selectedBorderType));
    }
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
            EdgeInsetsEditor(
              label: 'Margins',
              keyPrefix: 'margin',
              top: widget.styleConfig?.marginTop,
              bottom: widget.styleConfig?.marginBottom,
              left: widget.styleConfig?.marginLeft,
              right: widget.styleConfig?.marginRight,
              onChanged: ({top, bottom, left, right}) {
                final current = widget.styleConfig ?? const StyleConfig();
                widget.onStyleChanged(
                  current.copyWith(
                    marginTop: top,
                    marginBottom: bottom,
                    marginLeft: left,
                    marginRight: right,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Border', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<BorderType>(
              key: const Key('border_type'),
              initialValue: _selectedBorderType,
              decoration: const InputDecoration(labelText: 'Border Style'),
              items: BorderType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: _onBorderTypeChanged,
            ),
            const SizedBox(height: 16),
            EdgeInsetsEditor(
              label: 'Paddings',
              keyPrefix: 'padding',
              top: widget.styleConfig?.paddingTop,
              bottom: widget.styleConfig?.paddingBottom,
              left: widget.styleConfig?.paddingLeft,
              right: widget.styleConfig?.paddingRight,
              onChanged: ({top, bottom, left, right}) {
                final current = widget.styleConfig ?? const StyleConfig();
                widget.onStyleChanged(
                  current.copyWith(
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
      ),
    );
  }
}
