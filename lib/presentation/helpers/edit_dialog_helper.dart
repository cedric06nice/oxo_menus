import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows an edit dialog using the appropriate platform style.
///
/// On iOS/macOS, pushes a fullscreen [CupertinoPageRoute].
/// On other platforms, shows a Material [showDialog].
///
/// Returns a [Future] that completes when the dialog is dismissed.
Future<void> showEditDialog(BuildContext context, Widget dialog) {
  final platform = Theme.of(context).platform;
  final isApple =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  if (isApple) {
    return Navigator.of(context).push(
      CupertinoPageRoute<void>(fullscreenDialog: true, builder: (_) => dialog),
    );
  } else {
    return showDialog<void>(context: context, builder: (_) => dialog);
  }
}
