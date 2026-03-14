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
  final WidgetRegistry registry;
  final bool isSelected;
  final Widget? header;
  final VoidCallback? onTap;
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
    required this.registry,
    this.isSelected = false,
    this.header,
    this.onTap,
    required this.onWidgetDrop,
    required this.onWidgetMove,
    required this.widgetItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Container(
      key: Key('column_${column.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
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
      constraints: const BoxConstraints(minHeight: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?header,
          if (column.isDroppable) ...[
            _buildDroppableContent(),
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

  Widget _buildDroppableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i <= widgets.length; i++) ...[
          EditorDropZone(
            columnId: column.id,
            index: i,
            registry: registry,
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
