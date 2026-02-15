import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_drag_data.dart';
import 'package:oxo_menus/presentation/widgets/widget_renderer.dart';

/// A draggable and dismissible widget item for the editor.
///
/// Supports two modes:
/// - **Editable**: Full drag-and-drop with swipe-to-delete
/// - **Locked**: Read-only with lock icon (for template widgets)
class DraggableWidgetItem extends StatelessWidget {
  final WidgetInstance widgetInstance;
  final int columnId;
  final bool isEditable;
  final bool isLocked;
  final ValueChanged<Map<String, dynamic>>? onUpdate;
  final VoidCallback? onDelete;
  final Future<bool?> Function()? onConfirmDismiss;
  final ValueChanged<int>? onDismissed;

  const DraggableWidgetItem({
    super.key,
    required this.widgetInstance,
    required this.columnId,
    this.isEditable = true,
    this.isLocked = false,
    this.onUpdate,
    this.onDelete,
    this.onConfirmDismiss,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return Container(
        key: Key('template_widget_${widgetInstance.id}'),
        margin: const EdgeInsets.only(bottom: 8),
        child: Stack(
          children: [
            WidgetRenderer(widgetInstance: widgetInstance, isEditable: false),
            Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.lock, size: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final widgetContent = Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: WidgetRenderer(
        widgetInstance: widgetInstance,
        isEditable: isEditable,
        onUpdate: onUpdate,
        onDelete: onDelete,
      ),
    );

    return LongPressDraggable<WidgetDragData>(
      key: Key('widget_${widgetInstance.id}'),
      data: WidgetDragData.existing(widgetInstance, columnId),
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Text(
            widgetInstance.type.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: widgetContent),
      child: Dismissible(
        key: Key('dismissible_${widgetInstance.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: onConfirmDismiss != null
            ? (_) => onConfirmDismiss!()
            : null,
        onDismissed: onDismissed != null
            ? (_) => onDismissed!(widgetInstance.id)
            : null,
        background: Container(
          margin: const EdgeInsets.only(bottom: 8),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: widgetContent,
      ),
    );
  }
}
