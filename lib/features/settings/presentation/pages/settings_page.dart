import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/providers/app_version_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/features/auth/presentation/providers/password_reset_provider.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/authenticated_scaffold.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/shared/presentation/widgets/user_avatar_widget.dart';

/// Settings page with user profile and logout functionality
///
/// Features:
/// - Display user profile information (avatar, name, email, role)
/// - Logout button with confirmation dialog
/// - Future: Theme preferences, language selection
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return AuthenticatedScaffold(
      title: 'Settings',
      body: user == null
          ? const Center(child: AdaptiveLoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User profile section
                  _buildProfileSection(context, user),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Account section
                  _buildAccountSection(context, ref),

                  // Debug section (admin only)
                  if (user.role == UserRole.admin) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDebugSection(context, ref),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // About section
                  _buildAboutSection(context, ref),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection(BuildContext context, User user) {
    final theme = Theme.of(context);
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    final displayName = fullName.isEmpty ? user.email : fullName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            UserAvatarWidget(user: user, radius: 50),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(user.role == UserRole.admin ? 'Admin' : 'User'),
              avatar: Icon(
                user.role == UserRole.admin
                    ? Icons.admin_panel_settings
                    : Icons.person,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Account', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Reset Password'),
                subtitle: const Text('Send a reset link to your email'),
                onTap: () => _handleResetPassword(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => _handleLogout(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebugSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewAsUser = ref.watch(adminViewAsUserProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Debug', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.bug_report),
            title: const Text('Show as non-admin user'),
            subtitle: const Text('Preview the app as a regular user'),
            value: viewAsUser,
            onChanged: (value) {
              ref.read(adminViewAsUserProvider.notifier).set(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final versionAsync = ref.watch(appVersionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('About', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: versionAsync.when(
              data: (version) => Text('Version $version'),
              loading: () => const Text('Version ...'),
              error: (_, _) => const Text('Version unknown'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleResetPassword(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(passwordResetProvider.notifier).requestReset(user.email);

    if (!context.mounted) return;

    final state = ref.read(passwordResetProvider);
    final isApple = isApplePlatform(context);

    state.maybeWhen(
      emailSent: () {
        if (isApple) {
          showCupertinoDialog(
            context: context,
            builder: (dialogContext) => CupertinoAlertDialog(
              title: const Text('Reset Link Sent'),
              content: Text(
                'A password reset link has been sent to ${user.email}.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'A password reset link has been sent to ${user.email}.',
              ),
            ),
          );
        }
      },
      error: (message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      orElse: () {},
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final isApple = isApplePlatform(context);

    final bool? confirmed;
    if (isApple) {
      confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    }

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      // Router will automatically redirect to /login due to auth guard
    }
  }
}
