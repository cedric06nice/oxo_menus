import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/editor/widget_drag_data.dart';

/// A drop zone for accepting widget drag operations in the editor.
///
/// Features:
/// - Visual feedback (blue line when hovering, grey for no-op drops)
/// - No-op detection (prevents dropping widget at its current position)
/// - Delayed hover leave (prevents flickering when moving between zones)
class EditorDropZone extends StatefulWidget {
  final int columnId;
  final int index;
  final bool isHovering;
  final WidgetRegistry registry;
  final ValueChanged<int> onHoverIndexChanged;
  final void Function(WidgetDragData) onAccept;

  const EditorDropZone({
    super.key,
    required this.columnId,
    required this.index,
    required this.isHovering,
    required this.registry,
    required this.onHoverIndexChanged,
    required this.onAccept,
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
        widget.onHoverIndexChanged(-1);
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
      onMove: (details) {
        widget.onHoverIndexChanged(widget.index);
      },
      onLeave: (data) {
        // Small delay to prevent flickering when moving between zones
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            widget.onHoverIndexChanged(-1);
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        final showLine = widget.isHovering && candidateData.isNotEmpty;
        // Show a muted color for no-op positions
        final isNoOp =
            candidateData.isNotEmpty &&
            candidateData.first != null &&
            EditorDropZone.isNoOpDrop(
              candidateData.first!,
              widget.columnId,
              widget.index,
            );

        final theme = Theme.of(context);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: showLine ? 6 : 20,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: showLine
                ? (isNoOp
                      ? theme.colorScheme.outline
                      : theme.colorScheme.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}
