import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/helpers/status_helpers.dart';
import 'package:oxo_menus/presentation/widgets/common/status_badge.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

/// A template card with left accent strip and status badge pill.
class TemplateCard extends StatelessWidget {
  final Menu template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isApple = isApplePlatform(context);
    final accentColor = statusColor(template.status, colorScheme);

    final cardContent = Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent strip
            Container(width: 4, color: accentColor),
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: name + badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: template.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v${template.version}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (template.dateUpdated != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Updated: ${_formatDate(template.dateUpdated!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    // Action row
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: isApple
                          ? _buildAppleActions(colorScheme)
                          : _buildMaterialActions(colorScheme),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isApple) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: cardContent,
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: cardContent,
    );
  }

  List<Widget> _buildMaterialActions(ColorScheme colorScheme) {
    return [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEdit,
        tooltip: 'Edit',
        iconSize: 20,
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
        tooltip: 'Delete',
        iconSize: 20,
        color: colorScheme.error,
      ),
    ];
  }

  List<Widget> _buildAppleActions(ColorScheme colorScheme) {
    return [
      CupertinoButton(
        padding: const EdgeInsets.all(8),
        onPressed: onEdit,
        child: const Icon(CupertinoIcons.pencil, size: 20),
      ),
      CupertinoButton(
        padding: const EdgeInsets.all(8),
        onPressed: onDelete,
        child: Icon(CupertinoIcons.delete, size: 20, color: colorScheme.error),
      ),
    ];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
