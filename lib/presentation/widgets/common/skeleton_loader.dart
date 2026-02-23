import 'package:flutter/material.dart';
import 'package:oxo_menus/presentation/theme/app_spacing.dart';

/// Single skeleton card with pulsing opacity animation.
class SkeletonCard extends StatefulWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 120});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: 0.3 + (_controller.value * 0.4),
          duration: const Duration(milliseconds: 150),
          child: child,
        );
      },
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 10,
                width: 120,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 10,
                width: 80,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid of skeleton cards for loading states.
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const SkeletonGrid({super.key, this.itemCount = 6, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.6,
        children: List.generate(itemCount, (index) => const SkeletonCard()),
      ),
    );
  }
}
