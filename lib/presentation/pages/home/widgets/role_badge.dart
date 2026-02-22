import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final bool isAdmin;

  const RoleBadge({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isAdmin
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.secondaryContainer;
    final onColor = isAdmin
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            size: 16,
            color: onColor,
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? 'Admin' : 'User',
            style: theme.textTheme.labelMedium?.copyWith(color: onColor),
          ),
        ],
      ),
    );
  }
}
