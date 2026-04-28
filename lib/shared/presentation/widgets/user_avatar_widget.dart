import 'package:flutter/material.dart';
import 'package:oxo_menus/core/di/app_scope.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/widgets/user_avatar_view.dart';

/// AppScope-bound wrapper that resolves the Directus base URL and access
/// token, then defers rendering to [UserAvatarView].
class UserAvatarWidget extends StatelessWidget {
  final User? user;
  final double radius;

  const UserAvatarWidget({super.key, required this.user, this.radius = 20.0});

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    if (user == null || user.avatar == null || user.avatar!.isEmpty) {
      return UserAvatarView(user: user, radius: radius);
    }
    final container = AppScope.of(context).container;
    final baseUrl = container.directusBaseUrl ?? '';
    final token = container.directusAccessToken;
    return UserAvatarView(
      user: user,
      radius: radius,
      imageUrl: '$baseUrl/assets/${user.avatar}',
      imageHeaders: token != null
          ? <String, String>{'Authorization': 'Bearer $token'}
          : null,
    );
  }
}
