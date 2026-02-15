import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';

/// Menu list item widget
///
/// Displays a menu in a list with its name, status, version, and last updated date.
/// Admin users can see a delete button to remove the menu.
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        title: Text(
          menu.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: isAdmin
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatusChip(context),
                      const SizedBox(width: 8),
                      Text(
                        'v${menu.version}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (menu.dateUpdated != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Updated ${_formatDate(menu.dateUpdated!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              )
            : null,
        trailing: isAdmin && onDelete != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                    tooltip: 'Edit menu',
                  ),
                  if (onDuplicate != null)
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: onDuplicate,
                      tooltip: 'Duplicate menu',
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                    tooltip: 'Delete menu',
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    switch (menu.status) {
      case Status.published:
        chipColor = Colors.green;
        break;
      case Status.draft:
        chipColor = Colors.orange;
        break;
      case Status.archived:
        chipColor = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        menu.status.name.toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
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
