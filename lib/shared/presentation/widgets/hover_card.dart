import 'package:flutter/material.dart';

/// Hover elevation wrapper for web/desktop.
///
/// Wraps child in a `MouseRegion` + `AnimatedContainer` that
/// subtly elevates on hover. No-op visual effect on touch devices.
class HoverCard extends StatefulWidget {
  final Widget child;
  final double baseElevation;
  final double hoverElevation;
  final Duration duration;
  final BorderRadius? borderRadius;

  const HoverCard({
    super.key,
    required this.child,
    this.baseElevation = 0,
    this.hoverElevation = 4,
    this.duration = const Duration(milliseconds: 200),
    this.borderRadius,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(12);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: widget.duration,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: [
            if (_isHovering)
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: widget.hoverElevation * 2,
                offset: Offset(0, widget.hoverElevation / 2),
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
