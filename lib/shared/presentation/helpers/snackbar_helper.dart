import 'package:flutter/material.dart';

/// Themed snackbar helper with floating, rounded styling.
void showThemedSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? colorScheme.error : null,
    ),
  );
}
