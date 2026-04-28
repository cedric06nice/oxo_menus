import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple = isApplePlatform(context);

    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding + 6,
        bottom: 6,
        left: 16,
        right: 16,
      ),
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
