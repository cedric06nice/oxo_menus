import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/helpers/status_helpers.dart';
import 'package:oxo_menus/presentation/widgets/common/status_badge.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

/// Menu list item widget with left accent strip and status badge pill.
class MenuListItem extends StatelessWidget {
  final Menu menu;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const MenuListItem({
    super.key,
    required this.menu,
    required this.isAdmin,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isApple = isApplePlatform(context);
    final accentColor = statusColor(menu.status, colorScheme);

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
                            menu.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          StatusBadge(status: menu.status),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v${menu.version}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isAdmin && menu.dateUpdated != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Updated ${_formatDate(menu.dateUpdated!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    // Action row (admin only)
                    if (isAdmin) ...[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: isApple
                            ? _buildAppleActions(colorScheme)
                            : _buildMaterialActions(colorScheme),
                      ),
                    ],
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
      if (onEdit != null)
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
          tooltip: 'Edit menu',
          iconSize: 20,
        ),
      if (onDuplicate != null)
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: onDuplicate,
          tooltip: 'Duplicate menu',
          iconSize: 20,
        ),
      if (onDelete != null)
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
          tooltip: 'Delete menu',
          iconSize: 20,
          color: colorScheme.error,
        ),
    ];
  }

  List<Widget> _buildAppleActions(ColorScheme colorScheme) {
    return [
      if (onEdit != null)
        CupertinoButton(
          padding: const EdgeInsets.all(8),
          onPressed: onEdit,
          child: const Icon(CupertinoIcons.pencil, size: 20),
        ),
      if (onDuplicate != null)
        CupertinoButton(
          padding: const EdgeInsets.all(8),
          onPressed: onDuplicate,
          child: const Icon(CupertinoIcons.doc_on_doc, size: 20),
        ),
      if (onDelete != null)
        CupertinoButton(
          padding: const EdgeInsets.all(8),
          onPressed: onDelete,
          child: Icon(
            CupertinoIcons.delete,
            size: 20,
            color: colorScheme.error,
          ),
        ),
    ];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      }
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('d MMM y').format(date);
    }
  }
}
