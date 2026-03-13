import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

/// Platform-adaptive loading indicator.
///
/// Shows [CupertinoActivityIndicator] on Apple platforms,
/// [CircularProgressIndicator] on others.
class AdaptiveLoadingIndicator extends StatelessWidget {
  const AdaptiveLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return isApplePlatform(context)
        ? const CupertinoActivityIndicator()
        : const CircularProgressIndicator();
  }
}
