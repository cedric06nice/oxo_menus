import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

/// Widget that displays user avatar or initials
///
/// Shows a CircleAvatar with:
/// - Network image if avatar UUID is available (authenticated via Bearer token)
/// - Initials from first/last name if names are available
/// - First letter of email as fallback
/// - Consistent color generated from initials
class UserAvatarWidget extends ConsumerWidget {
  final User? user;
  final double radius;

  const UserAvatarWidget({super.key, required this.user, this.radius = 20.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user == null) {
      return CircleAvatar(radius: radius, child: const Icon(Icons.person));
    }

    final initials = _getInitials(user!);

    if (user!.avatar != null && user!.avatar!.isNotEmpty) {
      final baseUrl = ref.watch(directusBaseUrlProvider);
      final token = ref.watch(directusAccessTokenProvider);
      final imageUrl = '$baseUrl/assets/${user!.avatar}';
      final headers = token != null
          ? <String, String>{'Authorization': 'Bearer $token'}
          : null;

      return CircleAvatar(
        radius: radius,
        backgroundColor: _getColorFromInitials(initials),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            headers: headers,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.8,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.8,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: _getColorFromInitials(initials),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }

  String _getInitials(User user) {
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      final first = user.firstName![0].toUpperCase();
      final last = user.lastName?.isNotEmpty == true
          ? user.lastName![0].toUpperCase()
          : '';
      return '$first$last';
    }
    return user.email[0].toUpperCase();
  }

  Color _getColorFromInitials(String initials) {
    final hash = initials.codeUnitAt(0);
    return Colors.primaries[hash % Colors.primaries.length];
  }
}
