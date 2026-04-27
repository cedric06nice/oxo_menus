import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/features/home/presentation/helpers/home_helpers.dart';
import 'package:oxo_menus/features/home/presentation/widgets/quick_action_card.dart';
import 'package:oxo_menus/features/home/presentation/widgets/welcome_card.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/shared/presentation/widgets/authenticated_scaffold.dart';

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
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeCard(user: user, isAdmin: isAdmin, greeting: greeting),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Quick Actions', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 200,
                        child: QuickActionCard(
                          icon: Icons.restaurant_menu,
                          title: 'OXO Menus',
                          subtitle: 'Browse and manage menus',
                          onTap: () => context.go(AppRoutes.menus),
                        ),
                      ),
                      if (isAdmin)
                        SizedBox(
                          width: 200,
                          child: QuickActionCard(
                            icon: Icons.dashboard,
                            title: 'Manage Templates',
                            subtitle: 'Edit and organise templates',
                            onTap: () => context.go(AppRoutes.adminTemplates),
                          ),
                        ),
                      if (isAdmin)
                        SizedBox(
                          width: 200,
                          child: QuickActionCard(
                            icon: Icons.add_box,
                            title: 'Create Template',
                            subtitle: 'Start a new template',
                            onTap: () =>
                                context.go(AppRoutes.adminTemplateCreate),
                          ),
                        ),
                      if (isAdmin)
                        SizedBox(
                          width: 200,
                          child: QuickActionCard(
                            icon: Icons.picture_as_pdf,
                            title: 'Exportable Menus',
                            subtitle: 'Compose public PDF bundles',
                            onTap: () =>
                                context.go(AppRoutes.adminExportableMenus),
                          ),
                        ),
                    ],
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
