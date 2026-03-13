import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

/// Shows a dialog to select an area for a menu.
///
/// Loads areas from the repository, then shows a [SimpleDialog] with options.
/// Calls [onAreaUpdated] with the selected [Area] (or null for "None").
Future<void> showAreaDialog({
  required BuildContext context,
  required WidgetRef ref,
  required int menuId,
  required void Function(Area?) onAreaUpdated,
}) async {
  final result = await ref.read(areaRepositoryProvider).getAll();
  if (result.isFailure) {
    if (context.mounted) {
      showThemedSnackBar(
        context,
        'Failed to load areas: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
    return;
  }

  if (!context.mounted) return;

  final areas = result.valueOrNull!;

  showDialog(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Select Area'),
      children: [
        SimpleDialogOption(
          onPressed: () async {
            Navigator.of(ctx).pop();
            final updateResult = await ref
                .read(menuRepositoryProvider)
                .update(UpdateMenuInput(id: menuId, areaId: null));
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
                  .read(menuRepositoryProvider)
                  .update(UpdateMenuInput(id: menuId, areaId: area.id));
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
