import 'package:flutter/material.dart';

/// Shows a confirmation dialog for delete actions.
///
/// Returns `true` if the user confirms, `false` if they cancel, or `null`
/// if the dialog is dismissed.
Future<bool?> showDeleteConfirmation(BuildContext context, {String? itemType}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text(
        'Are you sure you want to delete this ${itemType ?? 'item'}?',
      ),
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
