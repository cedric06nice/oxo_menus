import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/settings/presentation/state/settings_state.dart';
import 'package:oxo_menus/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/user_avatar_view.dart';

/// Function used by [SettingsScreen] to confirm the logout action.
///
/// Tests inject a fake confirmer that returns a canned `bool`; production
/// uses [defaultLogoutConfirmer] which shows the platform-appropriate
/// dialog.
typedef LogoutConfirmer = Future<bool?> Function(BuildContext context);

/// Default production logout confirmer — Cupertino on Apple platforms,
/// Material elsewhere.
Future<bool?> defaultLogoutConfirmer(BuildContext context) {
  if (isApplePlatform(context)) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
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
  }
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: <Widget>[
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

/// MVVM-stack settings screen.
///
/// Pure widget — owns no Riverpod providers and no navigation. Reads display
/// state from the injected [SettingsViewModel] and forwards user actions
/// back to it. The [confirmLogout] indirection lets widget tests bypass the
/// platform dialog.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.viewModel,
    this.confirmLogout = defaultLogoutConfirmer,
  });

  final SettingsViewModel viewModel;
  final LogoutConfirmer confirmLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PasswordResetOutcome _lastSeenOutcome = PasswordResetOutcome.idle;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) {
      return;
    }
    final outcome = widget.viewModel.state.passwordResetOutcome;
    if (outcome != _lastSeenOutcome && outcome != PasswordResetOutcome.idle) {
      _lastSeenOutcome = outcome;
      _showPasswordResetFeedback(widget.viewModel.state);
    } else if (outcome == PasswordResetOutcome.idle) {
      _lastSeenOutcome = outcome;
    }
    setState(() {});
  }

  void _showPasswordResetFeedback(SettingsState state) {
    final message = state.passwordResetMessage ?? '';
    if (message.isEmpty) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(message)));
    widget.viewModel.acknowledgePasswordReset();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    final user = state.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: BackButton(onPressed: widget.viewModel.goBack),
      ),
      body: user == null
          ? const Center(child: AdaptiveLoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  _ProfileSection(user: user),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _AccountSection(
                    onResetPassword: () =>
                        widget.viewModel.requestPasswordReset(),
                    onLogout: _handleLogout,
                  ),
                  if (state.isAdmin) ...<Widget>[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _DebugSection(
                      viewAsUser: state.viewAsUser,
                      onChanged: widget.viewModel.setViewAsUser,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _AboutSection(version: state.version),
                ],
              ),
            ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await widget.confirmLogout(context);
    if (confirmed != true || !mounted) {
      return;
    }
    await widget.viewModel.logout();
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    final displayName = fullName.isEmpty ? user.email : fullName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            UserAvatarView(user: user, radius: 50),
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
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.onResetPassword,
    required this.onLogout,
  });

  final VoidCallback onResetPassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Account', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Reset Password'),
                subtitle: const Text('Send a reset link to your email'),
                onTap: onResetPassword,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DebugSection extends StatelessWidget {
  const _DebugSection({required this.viewAsUser, required this.onChanged});

  final bool viewAsUser;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Debug', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.bug_report),
            title: const Text('Show as non-admin user'),
            subtitle: const Text('Preview the app as a regular user'),
            value: viewAsUser,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (version) {
      null => 'Version ...',
      'unknown' => 'Version unknown',
      final v => 'Version $v',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('About', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(label),
          ),
        ),
      ],
    );
  }
}
