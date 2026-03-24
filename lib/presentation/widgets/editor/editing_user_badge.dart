import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

/// Badge showing the avatar/initials of the user currently editing a widget,
/// with a small edit icon.
class EditingUserBadge extends ConsumerWidget {
  final String? userName;
  final String? userAvatar;

  const EditingUserBadge({super.key, this.userName, this.userAvatar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isApple = isApplePlatform(context);
    final baseUrl = ref.watch(directusBaseUrlProvider);
    final token = ref.watch(directusAccessTokenProvider);
    final initials = _getInitials(userName);

    final initialsWidget = Text(
      initials,
      style: TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onTertiary,
      ),
    );

    Widget avatarChild;
    if (userAvatar != null) {
      final imageUrl = '$baseUrl/assets/$userAvatar';
      final headers = token != null
          ? <String, String>{'Authorization': 'Bearer $token'}
          : null;

      avatarChild = ClipOval(
        child: Image.network(
          imageUrl,
          headers: headers,
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(child: initialsWidget);
          },
        ),
      );
    } else {
      avatarChild = initialsWidget;
    }

    return Tooltip(
      message: userName ?? 'Unknown user',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: theme.colorScheme.tertiary,
              child: avatarChild,
            ),
            const SizedBox(width: 2),
            Icon(
              isApple ? CupertinoIcons.pencil : Icons.edit,
              size: 12,
              color: theme.colorScheme.onTertiary,
            ),
          ],
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
