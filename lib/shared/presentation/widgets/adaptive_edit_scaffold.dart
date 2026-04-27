import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Adaptive scaffold for edit dialogs.
///
/// On iOS/macOS, renders a [CupertinoPageScaffold] with a navigation bar
/// containing Cancel and Save buttons. On other platforms, renders a Material
/// [AlertDialog] with Cancel and Save action buttons.
class AdaptiveEditScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onSave;
  final List<Widget> appleFormChildren;
  final List<Widget> materialFormChildren;

  const AdaptiveEditScaffold({
    super.key,
    required this.title,
    required this.onSave,
    required this.appleFormChildren,
    required this.materialFormChildren,
  });

  @override
  Widget build(BuildContext context) {
    return isApplePlatform(context)
        ? _buildAppleForm(context)
        : _buildMaterialDialog(context);
  }

  Widget _buildAppleForm(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onSave,
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(child: ListView(children: appleFormChildren)),
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: materialFormChildren,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: onSave, child: const Text('Save')),
      ],
    );
  }
}
