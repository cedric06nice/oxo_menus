import 'dart:async';

import 'package:flutter/gestures.dart';
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
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handlePointerEvent,
    );
    _stopScrolling();
    super.dispose();
  }

  void _handlePointerEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _onPointerMove(event);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _stopScrolling();
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final localPosition = renderBox.globalToLocal(event.position);
    final size = renderBox.size;

    // Ignore events outside our bounds (global route receives ALL pointer events)
    if (localPosition.dx < 0 ||
        localPosition.dx > size.width ||
        localPosition.dy < 0 ||
        localPosition.dy > size.height) {
      _stopScrolling();
      return;
    }

    final height = size.height;
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
  Widget build(BuildContext context) => widget.child;
}
