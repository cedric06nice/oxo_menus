import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/collaboration/presentation/widgets/editing_user_badge.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/canvas/widget_renderer.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/editor/widget_drag_data.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

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
  final String? editingUserName;
  final String? editingUserAvatar;
  final ValueChanged<Map<String, dynamic>>? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onEditStarted;
  final VoidCallback? onEditEnded;
  final Future<bool?> Function()? onConfirmDismiss;
  final ValueChanged<int>? onDismissed;
  final bool showLockToggle;
  final bool isLockedForEdition;
  final ValueChanged<bool>? onLockToggle;

  const DraggableWidgetItem({
    super.key,
    required this.widgetInstance,
    required this.columnId,
    this.isEditable = true,
    this.isLocked = false,
    this.currentUserId,
    this.editingUserName,
    this.editingUserAvatar,
    this.onUpdate,
    this.onDelete,
    this.onEditStarted,
    this.onEditEnded,
    this.onConfirmDismiss,
    this.onDismissed,
    this.showLockToggle = false,
    this.isLockedForEdition = false,
    this.onLockToggle,
  });

  /// Whether this widget is currently being edited by another user.
  bool get _isEditingLocked {
    final editingBy = widgetInstance.editingBy;
    if (editingBy == null || editingBy == currentUserId) return false;

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
    final isApple = isApplePlatform(context);

    if (_isEditingLocked) {
      return SizedBox(
        width: double.infinity,
        child: Container(
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
                child: EditingUserBadge(
                  userName: editingUserName,
                  userAvatar: editingUserAvatar,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isLocked) {
      return SizedBox(
        width: double.infinity,
        child: Container(
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
        ),
      );
    }

    final widgetContent = SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        child: WidgetRenderer(
          widgetInstance: widgetInstance,
          isEditable: isEditable,
          onUpdate: onUpdate,
          onDelete: onDelete,
          onEditStarted: onEditStarted,
          onEditEnded: onEditEnded,
        ),
      ),
    );

    final draggable = LongPressDraggable<WidgetDragData>(
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

    if (!showLockToggle) return draggable;

    return Stack(
      children: [
        draggable,
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            key: Key('widget_lock_toggle_${widgetInstance.id}'),
            icon: Icon(
              isLockedForEdition
                  ? (isApple ? CupertinoIcons.lock : Icons.lock)
                  : (isApple ? CupertinoIcons.lock_open : Icons.lock_open),
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: isLockedForEdition
                ? 'Unlock for user edition'
                : 'Lock for user edition',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            onPressed: onLockToggle == null
                ? null
                : () => onLockToggle!(!isLockedForEdition),
          ),
        ),
      ],
    );
  }
}
