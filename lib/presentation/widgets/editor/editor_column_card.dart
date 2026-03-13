import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_drop_zone.dart';

/// Reusable column card for both AdminTemplateEditorPage and MenuEditorPage.
///
/// Renders a column with drop zones, widgets, and empty states.
/// Page-specific widget rendering is delegated to [widgetItemBuilder].
class EditorColumnCard extends StatelessWidget {
  final entity.Column column;
  final List<WidgetInstance> widgets;
  final int hoverIndex;
  final WidgetRegistry registry;
  final bool isSelected;
  final Widget? header;
  final VoidCallback? onTap;
  final ValueChanged<int> onHoverIndexChanged;
  final Future<void> Function(String type, int columnId, int index)
  onWidgetDrop;
  final Future<void> Function(
    WidgetInstance widget,
    int sourceColumnId,
    int targetColumnId,
    int targetIndex,
  )
  onWidgetMove;
  final Widget Function(WidgetInstance widget, int columnId) widgetItemBuilder;

  const EditorColumnCard({
    super.key,
    required this.column,
    required this.widgets,
    required this.hoverIndex,
    required this.registry,
    this.isSelected = false,
    this.header,
    this.onTap,
    required this.onHoverIndexChanged,
    required this.onWidgetDrop,
    required this.onWidgetMove,
    required this.widgetItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Container(
      key: Key('column_${column.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
      constraints: const BoxConstraints(minHeight: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?header,
          if (column.isDroppable) ...[
            _buildDroppableContent(theme),
          ] else ...[
            _buildNonDroppableContent(theme),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }

  Widget _buildDroppableContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i <= widgets.length; i++) ...[
          EditorDropZone(
            columnId: column.id,
            index: i,
            isHovering: hoverIndex == i,
            registry: registry,
            onHoverIndexChanged: onHoverIndexChanged,
            onAccept: (dragData) {
              if (dragData.isNewWidget) {
                onWidgetDrop(dragData.newWidgetType!, column.id, i);
              } else if (dragData.isExistingWidget) {
                onWidgetMove(
                  dragData.existingWidget!,
                  dragData.sourceColumnId!,
                  column.id,
                  i,
                );
              }
            },
          ),
          if (i < widgets.length) widgetItemBuilder(widgets[i], column.id),
        ],
        if (widgets.isEmpty && hoverIndex == -1)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Drop widgets here',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNonDroppableContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final widget in widgets) widgetItemBuilder(widget, column.id),
        if (widgets.isEmpty)
          Center(
            child: Icon(
              Icons.lock,
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ),
      ],
    );
  }
}
