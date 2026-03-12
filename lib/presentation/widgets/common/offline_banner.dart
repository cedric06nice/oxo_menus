import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(color: theme.colorScheme.errorContainer),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isApple ? CupertinoIcons.wifi_slash : Icons.wifi_off,
            size: 16,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'You are offline',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
