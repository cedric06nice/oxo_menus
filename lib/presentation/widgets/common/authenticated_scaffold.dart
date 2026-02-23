import 'package:flutter/material.dart';

/// Simple page scaffold providing AppBar with title and optional actions.
///
/// Used inside the [AppShell] navigation shell. Provides only the
/// page-level AppBar — navigation is handled by the shell.
class AuthenticatedScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AuthenticatedScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions != null
            ? [...actions!, const SizedBox(width: 8)]
            : null,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
