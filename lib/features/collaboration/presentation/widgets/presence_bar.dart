import 'package:flutter/material.dart';
import 'package:oxo_menus/core/di/app_scope.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';

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

    final container = AppScope.of(context).container;
    final baseUrl = container.directusBaseUrl ?? '';
    final token = container.directusAccessToken;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: activeOthers
          .map((p) => _buildAvatar(context, p, baseUrl, token))
          .toList(),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    MenuPresence presence,
    String baseUrl,
    String? token,
  ) {
    final theme = Theme.of(context);
    final initials = _getInitials(presence.userName);

    final initialsWidget = Text(
      initials,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onTertiary,
      ),
    );

    Widget avatarChild;
    if (presence.userAvatar != null) {
      final imageUrl = '$baseUrl/assets/${presence.userAvatar}';
      final headers = token != null
          ? <String, String>{'Authorization': 'Bearer $token'}
          : null;

      avatarChild = ClipOval(
        child: Image.network(
          imageUrl,
          headers: headers,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(child: initialsWidget);
          },
        ),
      );
    } else {
      avatarChild = initialsWidget;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: presence.userName ?? 'Unknown user',
        child: CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.tertiary,
          child: avatarChild,
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
