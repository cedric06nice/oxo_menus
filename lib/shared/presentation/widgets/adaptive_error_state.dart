import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Platform-adaptive error state with icon, message, and retry button.
class AdaptiveErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdaptiveErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple = isApplePlatform(context);
    final displayText = 'Error: $message';
    final truncated = displayText.substring(
      0,
      displayText.length.clamp(0, 200),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isApple
                ? CupertinoIcons.exclamationmark_triangle
                : Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(truncated),
          const SizedBox(height: 16),
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
