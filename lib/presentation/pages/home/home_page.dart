import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/presentation/pages/home/home_helpers.dart';
import 'package:oxo_menus/presentation/pages/home/widgets/quick_action_card.dart';
import 'package:oxo_menus/presentation/pages/home/widgets/welcome_card.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';

class HomePage extends ConsumerWidget {
  final DateTime? now;

  const HomePage({super.key, this.now});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final theme = Theme.of(context);
    final name = user?.firstName ?? user?.email.split('@')[0] ?? 'User';
    final greeting = buildGreeting(name, now ?? DateTime.now());

    return AuthenticatedScaffold(
      title: 'Home',
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeCard(user: user, isAdmin: isAdmin, greeting: greeting),
                  const SizedBox(height: 24),
                  Text('Quick Actions', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = computeGridColumns(constraints.maxWidth);
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          QuickActionCard(
                            icon: Icons.restaurant_menu,
                            title: 'OXO Menus',
                            subtitle: 'Browse and manage menus',
                            onTap: () => context.push('/menus'),
                          ),
                          if (isAdmin)
                            QuickActionCard(
                              icon: Icons.dashboard,
                              title: 'Manage Templates',
                              subtitle: 'Edit and organise templates',
                              onTap: () => context.push('/admin/templates'),
                            ),
                          if (isAdmin)
                            QuickActionCard(
                              icon: Icons.add_box,
                              title: 'Create Template',
                              subtitle: 'Start a new template',
                              onTap: () =>
                                  context.push('/admin/templates/create'),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
