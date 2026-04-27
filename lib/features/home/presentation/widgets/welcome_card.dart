import 'package:flutter/material.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/home/presentation/widgets/role_badge.dart';
import 'package:oxo_menus/shared/presentation/widgets/user_avatar_widget.dart';

class WelcomeCard extends StatelessWidget {
  final User? user;
  final bool isAdmin;
  final String greeting;

  const WelcomeCard({
    super.key,
    required this.user,
    required this.isAdmin,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: const Key('welcome_card'),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.primaryContainer],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              UserAvatarWidget(user: user, radius: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome on your dashboard',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RoleBadge(isAdmin: isAdmin),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
