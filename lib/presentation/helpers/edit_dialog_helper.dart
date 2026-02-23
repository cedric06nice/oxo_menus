import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows an edit dialog using the appropriate platform style.
///
/// On iOS/macOS, pushes a fullscreen [CupertinoPageRoute].
/// On other platforms, shows a Material [showDialog].
void showEditDialog(BuildContext context, Widget dialog) {
  final platform = Theme.of(context).platform;
  final isApple =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  if (isApple) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(fullscreenDialog: true, builder: (_) => dialog),
    );
  } else {
    showDialog<void>(context: context, builder: (_) => dialog);
  }
}
