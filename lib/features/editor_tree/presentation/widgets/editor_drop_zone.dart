import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/widget_drag_data.dart';

/// A drop zone for accepting widget drag operations in the editor.
///
/// Features:
/// - Shows "Drop widgets here" text when idle
/// - Visual feedback (blue line when hovering, grey for no-op drops)
/// - No-op detection (prevents dropping widget at its current position)
class EditorDropZone extends StatefulWidget {
  final int columnId;
  final int index;
  final PresentableWidgetRegistry registry;
  final void Function(WidgetDragData) onAccept;
  final double idleHeight;

  const EditorDropZone({
    super.key,
    required this.columnId,
    required this.index,
    required this.registry,
    required this.onAccept,
    this.idleHeight = 24,
  });

  /// Check if dropping at this position would be a no-op (widget already at this position)
  static bool isNoOpDrop(WidgetDragData dragData, int columnId, int index) {
    if (!dragData.isExistingWidget) return false;
    if (dragData.sourceColumnId != columnId) return false;

    final currentIndex = dragData.existingWidget!.index;
    // Dropping at current position or the position right after is a no-op
    return index == currentIndex || index == currentIndex + 1;
  }

  @override
  State<EditorDropZone> createState() => _EditorDropZoneState();
}

class _EditorDropZoneState extends State<EditorDropZone> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<WidgetDragData>(
      key: Key('drop_zone_${widget.columnId}_${widget.index}'),
      onWillAcceptWithDetails: (details) {
        final dragData = details.data;
        if (dragData.isNewWidget) {
          return widget.registry.getDefinition(dragData.newWidgetType!) != null;
        } else if (dragData.isExistingWidget) {
          // Always accept to show the indicator, but check for no-op in onAccept
          return true;
        }
        return false;
      },
      onAcceptWithDetails: (details) {
        final dragData = details.data;

        // Skip no-op drops (widget already at this position)
        if (EditorDropZone.isNoOpDrop(
          dragData,
          widget.columnId,
          widget.index,
        )) {
          return;
        }

        widget.onAccept(dragData);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        // Show a muted color for no-op positions
        final isNoOp =
            isHovering &&
            candidateData.first != null &&
            EditorDropZone.isNoOpDrop(
              candidateData.first!,
              widget.columnId,
              widget.index,
            );

        final theme = Theme.of(context);

        if (isHovering) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isNoOp
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.idleHeight,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text(
              'Drop widgets here',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      },
    );
  }
}
