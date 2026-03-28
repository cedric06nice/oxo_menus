import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

class OfflineErrorPage extends StatelessWidget {
  final VoidCallback onRetry;

  const OfflineErrorPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple = isApplePlatform(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isApple ? CupertinoIcons.wifi_slash : Icons.wifi_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('You are offline', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'This page requires an active internet connection.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (isApple)
            CupertinoButton.filled(
              onPressed: onRetry,
              child: const Text('Retry'),
            )
          else
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
