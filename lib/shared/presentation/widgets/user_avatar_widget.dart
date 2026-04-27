import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/widgets/user_avatar_view.dart';

/// Riverpod-bound wrapper that resolves the Directus base URL and access
/// token, then defers rendering to [UserAvatarView].
///
/// Used by legacy go_router screens; MVVM screens render [UserAvatarView]
/// directly with values plumbed through their view model.
class UserAvatarWidget extends ConsumerWidget {
  final User? user;
  final double radius;

  const UserAvatarWidget({super.key, required this.user, this.radius = 20.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = this.user;
    if (user == null || user.avatar == null || user.avatar!.isEmpty) {
      return UserAvatarView(user: user, radius: radius);
    }
    final baseUrl = ref.watch(directusBaseUrlProvider);
    final token = ref.watch(directusAccessTokenProvider);
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
