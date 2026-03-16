import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows a confirmation dialog for delete actions.
///
/// Returns `true` if the user confirms, `false` if they cancel, or `null`
/// if the dialog is dismissed.
Future<bool?> showDeleteConfirmation(
  BuildContext context, {
  String? itemType,
  String? title,
  String? message,
}) {
  final platform = Theme.of(context).platform;
  final isApple =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  final resolvedTitle = title ?? 'Confirm Delete';
  final content =
      message ?? 'Are you sure you want to delete this ${itemType ?? 'item'}?';

  if (isApple) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(resolvedTitle),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(resolvedTitle),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
