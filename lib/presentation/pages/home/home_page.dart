import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';

/// Home page with welcome message and quick action cards
///
/// Features:
/// - Welcome message with user's first name
/// - Role badge (Admin/User)
/// - Quick action cards based on user role:
///   - Regular users: Browse Templates, My Menus
///   - Admin users: additional Create Template, Manage Templates cards
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return AuthenticatedScaffold(
      title: 'Home',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(user),
            const SizedBox(height: 24),
            _buildQuickActions(context, isAdmin),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(User? user) {
    final name = user?.firstName ?? user?.email.split('@')[0] ?? 'User';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $name!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(user?.role == UserRole.admin ? 'Admin' : 'User'),
          avatar: Icon(
            user?.role == UserRole.admin
                ? Icons.admin_panel_settings
                : Icons.person,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _QuickActionCard(
              icon: Icons.restaurant_menu,
              title: isAdmin ? 'Manage Templates' : 'Browse Templates',
              onTap: () => context.push(
                isAdmin ? '/admin/templates' : '/admin/templates',
              ),
            ),
            _QuickActionCard(
              icon: Icons.list,
              title: 'My Menus',
              onTap: () => context.push('/menus'),
            ),
            if (isAdmin) ...[
              _QuickActionCard(
                icon: Icons.add_box,
                title: 'Create Template',
                onTap: () => context.push('/admin/templates/create'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
