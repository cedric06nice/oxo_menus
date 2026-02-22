import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that auto-scrolls a [ScrollController] when a pointer moves
/// near the top or bottom edges during a drag operation.
///
/// Wrap this around a scrollable area to enable auto-scroll during drag-and-drop.
class AutoScrollListener extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  /// Distance from the edge (in pixels) that triggers auto-scroll.
  final double edgeThreshold;

  /// Maximum scroll speed in pixels per tick.
  final double maxScrollSpeed;

  const AutoScrollListener({
    super.key,
    required this.scrollController,
    required this.child,
    this.edgeThreshold = 80,
    this.maxScrollSpeed = 10,
  });

  @override
  State<AutoScrollListener> createState() => _AutoScrollListenerState();
}

class _AutoScrollListenerState extends State<AutoScrollListener> {
  Timer? _scrollTimer;

  @override
  void dispose() {
    _stopScrolling();
    super.dispose();
  }

  void _onPointerMove(PointerMoveEvent event) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(event.position);
    final height = renderBox.size.height;
    final threshold = widget.edgeThreshold;

    if (localPosition.dy < threshold) {
      // Near top edge — scroll up
      final proximity = 1.0 - (localPosition.dy / threshold);
      _startScrolling(-widget.maxScrollSpeed * proximity);
    } else if (localPosition.dy > height - threshold) {
      // Near bottom edge — scroll down
      final proximity = 1.0 - ((height - localPosition.dy) / threshold);
      _startScrolling(widget.maxScrollSpeed * proximity);
    } else {
      _stopScrolling();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _stopScrolling();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _stopScrolling();
  }

  void _startScrolling(double delta) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final controller = widget.scrollController;
      if (!controller.hasClients) return;

      final newOffset = (controller.offset + delta).clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );
      controller.jumpTo(newOffset);
    });
  }

  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}
