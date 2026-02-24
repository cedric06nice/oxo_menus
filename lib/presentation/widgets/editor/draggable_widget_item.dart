import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_drag_data.dart';
import 'package:oxo_menus/presentation/widgets/canvas/widget_renderer.dart';

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
  final String? currentUserId;
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
    this.currentUserId,
    this.onUpdate,
    this.onDelete,
    this.onConfirmDismiss,
    this.onDismissed,
  });

  /// Whether this widget is currently being edited by another user.
  bool get _isEditingLocked {
    final editingBy = widgetInstance.editingBy;
    if (editingBy == null || editingBy == currentUserId) return false;

    // Ignore stale locks (>2 minutes old)
    final editingSince = widgetInstance.editingSince;
    if (editingSince != null) {
      final elapsed = DateTime.now().difference(editingSince);
      if (elapsed.inMinutes >= 2) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;

    // Editing lock overlay: another user is editing this widget
    if (_isEditingLocked) {
      return Container(
        key: Key('editing_lock_overlay_${widgetInstance.id}'),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Opacity(
              opacity: 0.5,
              child: WidgetRenderer(
                widgetInstance: widgetInstance,
                isEditable: false,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isApple ? CupertinoIcons.pencil : Icons.edit,
                      size: 12,
                      color: theme.colorScheme.onTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Editing...',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

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
              child: Icon(
                isApple ? CupertinoIcons.lock : Icons.lock,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary, width: 2),
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
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isApple ? CupertinoIcons.delete : Icons.delete,
            color: theme.colorScheme.onError,
          ),
        ),
        child: widgetContent,
      ),
    );
  }
}
