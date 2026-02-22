import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_helpers.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/widgets/template_status_indicator.dart';

/// A rich template card with platform-adaptive interactions.
///
/// Displays status indicator, template name, version, date,
/// and edit/delete action buttons.
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

  bool _isApple(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isApple = _isApple(context);
    final containerColor = statusContainerColor(template.status, colorScheme);

    final cardContent = Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: containerColor,
            child: TemplateStatusIndicator(status: template.status),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
          const Divider(height: 1),
          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: isApple
                  ? _buildAppleActions(colorScheme)
                  : _buildMaterialActions(colorScheme),
            ),
          ),
        ],
      ),
    );

    if (isApple) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: cardContent,
      );
    }

    return InkWell(onTap: onTap, child: cardContent);
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
