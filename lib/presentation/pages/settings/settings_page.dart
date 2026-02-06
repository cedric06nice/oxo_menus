import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/user_avatar_widget.dart';

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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User profile section
                  _buildProfileSection(user),
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
                    _buildDebugSection(ref),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection(User user) {
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    final displayName = fullName.isEmpty ? user.email : fullName;

    return Column(
      children: [
        UserAvatarWidget(user: user, radius: 50),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
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
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _handleLogout(context, ref),
          ),
        ),
      ],
    );
  }

  Widget _buildDebugSection(WidgetRef ref) {
    final viewAsUser = ref.watch(adminViewAsUserProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Debug',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.bug_report),
            title: const Text('Show as non-admin user'),
            subtitle: const Text('Preview the app as a regular user'),
            value: viewAsUser,
            onChanged: (value) {
              ref.read(adminViewAsUserProvider.notifier).state = value;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      // Router will automatically redirect to /login due to auth guard
    }
  }
}
