import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/user_avatar_widget.dart';

/// Scaffold wrapper for authenticated pages with consistent navigation
///
/// Features:
/// - Persistent AppBar with user avatar button
/// - Avatar button navigates to Settings page
/// - Accepts custom actions and floating action button
/// - Uses currentUserProvider to get user info
class AuthenticatedScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AuthenticatedScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Add custom actions first
          if (actions != null) ...actions!,
          // Avatar button always last
          IconButton(
            icon: UserAvatarWidget(user: user, radius: 16),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
