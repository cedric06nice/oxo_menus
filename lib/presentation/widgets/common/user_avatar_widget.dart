import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/user.dart';

/// Widget that displays user avatar or initials
///
/// Shows a CircleAvatar with:
/// - Network image if avatar URL is available
/// - Initials from first/last name if names are available
/// - First letter of email as fallback
/// - Consistent color generated from initials
class UserAvatarWidget extends StatelessWidget {
  final User? user;
  final double radius;

  const UserAvatarWidget({super.key, required this.user, this.radius = 20.0});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return CircleAvatar(radius: radius, child: const Icon(Icons.person));
    }

    final initials = _getInitials(user!);

    if (user!.avatar != null && user!.avatar!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: _getColorFromInitials(initials),
        child: ClipOval(
          child: Image.network(
            user!.avatar!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to initials if image fails to load
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
              // Show initials while loading
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
    // Generate consistent color from initials
    final hash = initials.codeUnitAt(0);
    return Colors.primaries[hash % Colors.primaries.length];
  }
}
