import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';

/// Displays avatar chips for other users currently editing the same menu.
class PresenceBar extends StatelessWidget {
  final List<MenuPresence> presences;
  final String currentUserId;

  const PresenceBar({
    super.key,
    required this.presences,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final activeOthers = presences.where((p) {
      if (p.userId == currentUserId) return false;
      // Filter stale presences (>2 minutes)
      final elapsed = now.difference(p.lastSeen);
      if (elapsed.inMinutes >= 2) return false;
      return true;
    }).toList();

    if (activeOthers.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: activeOthers.map((p) => _buildAvatar(context, p)).toList(),
    );
  }

  Widget _buildAvatar(BuildContext context, MenuPresence presence) {
    final theme = Theme.of(context);
    final initials = _getInitials(presence.userName);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: presence.userName ?? 'Unknown user',
        child: CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.tertiary,
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onTertiary,
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}
