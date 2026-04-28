import 'package:flutter/material.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/presentation/theme/app_colors.dart';

/// Unified pill-shaped status badge with icon and uppercase text.
///
/// Replaces `MenuStatusIndicator`, `TemplateStatusIndicator`,
/// and inline `_StatusBadge` with a single shared component.
class StatusBadge extends StatelessWidget {
  final Status status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final color = _statusColor(status, colorScheme, isLight);
    final icon = _statusIcon(status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              status.name.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _statusColor(
    Status status,
    ColorScheme colorScheme,
    bool isLight,
  ) {
    return switch (status) {
      Status.draft => colorScheme.tertiary,
      Status.published =>
        isLight ? AppColors.statusGreen : AppColors.statusGreenDark,
      Status.archived => colorScheme.outline,
    };
  }

  static IconData _statusIcon(Status status) {
    return switch (status) {
      Status.draft => Icons.edit_note,
      Status.published => Icons.check_circle_outline,
      Status.archived => Icons.archive_outlined,
    };
  }
}
