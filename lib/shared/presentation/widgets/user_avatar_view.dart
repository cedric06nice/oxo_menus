import 'package:flutter/material.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Pure avatar widget — takes the user, an optional fully-resolved network
/// URL, and optional auth headers, and decides what to draw.
///
/// Lives in `shared` because both the legacy Riverpod-bound
/// [UserAvatarWidget] and the migrated MVVM screens render it. Holds no
/// Riverpod dependencies so MVVM screens can use it directly.
class UserAvatarView extends StatelessWidget {
  const UserAvatarView({
    super.key,
    required this.user,
    this.radius = 20.0,
    this.imageUrl,
    this.imageHeaders,
  });

  final User? user;
  final double radius;

  /// Fully-resolved URL to fetch the avatar image from. `null` falls back to
  /// initials/icon rendering.
  final String? imageUrl;

  /// Optional headers attached to the avatar request (e.g. an
  /// `Authorization: Bearer …` header for Directus assets).
  final Map<String, String>? imageHeaders;

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    if (user == null) {
      return CircleAvatar(radius: radius, child: const Icon(Icons.person));
    }

    final initials = _initialsFor(user);
    final url = imageUrl;

    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: _colorFor(initials),
        child: ClipOval(
          child: Image.network(
            url,
            headers: imageHeaders,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _initialsLabel(initials),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _initialsLabel(initials),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: _colorFor(initials),
      child: _initialsLabel(initials),
    );
  }

  Widget _initialsLabel(String initials) {
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
  }

  static String _initialsFor(User user) {
    final first = user.firstName;
    if (first != null && first.isNotEmpty) {
      final lastInitial = (user.lastName?.isNotEmpty ?? false)
          ? user.lastName![0].toUpperCase()
          : '';
      return '${first[0].toUpperCase()}$lastInitial';
    }
    return user.email[0].toUpperCase();
  }

  static Color _colorFor(String initials) {
    final hash = initials.codeUnitAt(0);
    return Colors.primaries[hash % Colors.primaries.length];
  }
}
