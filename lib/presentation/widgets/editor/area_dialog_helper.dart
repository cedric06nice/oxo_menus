import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_provider.dart';

/// Shows a dialog to select an area for a menu.
///
/// Loads areas from the notifier, then shows a [SimpleDialog] with options.
/// Calls [onAreaUpdated] with the selected [Area] (or null for "None").
Future<void> showAreaDialog({
  required BuildContext context,
  required WidgetRef ref,
  required int menuId,
  required void Function(Area?) onAreaUpdated,
}) async {
  final notifier = ref.read(menuSettingsProvider.notifier);
  await notifier.loadAreas();
  final state = ref.read(menuSettingsProvider);

  if (state.errorMessage != null) {
    if (context.mounted) {
      showThemedSnackBar(
        context,
        'Failed to load areas: ${state.errorMessage}',
        isError: true,
      );
    }
    return;
  }

  if (!context.mounted) return;

  final areas = state.areas;

  showDialog(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Select Area'),
      children: [
        SimpleDialogOption(
          onPressed: () async {
            Navigator.of(ctx).pop();
            final updateResult = await ref
                .read(menuSettingsProvider.notifier)
                .updateArea(menuId, null);
            if (updateResult.isSuccess) {
              onAreaUpdated(null);
            }
          },
          child: const Text('None'),
        ),
        ...areas.map(
          (area) => SimpleDialogOption(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final updateResult = await ref
                  .read(menuSettingsProvider.notifier)
                  .updateArea(menuId, area.id);
              if (updateResult.isSuccess) {
                onAreaUpdated(area);
              }
            },
            child: Text(area.name),
          ),
        ),
      ],
    ),
  );
}
