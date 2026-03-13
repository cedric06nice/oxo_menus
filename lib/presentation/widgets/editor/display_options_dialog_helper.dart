import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/menu_display_options_dialog.dart';

void showDisplayOptionsDialog({
  required BuildContext context,
  required WidgetRef ref,
  required int menuId,
  required Menu? menu,
  required void Function(Menu?) onMenuUpdated,
}) {
  showDialog(
    context: context,
    builder: (ctx) => MenuDisplayOptionsDialog(
      displayOptions: menu?.displayOptions,
      onSave: (options) async {
        final result = await ref
            .read(menuRepositoryProvider)
            .update(UpdateMenuInput(id: menuId, displayOptions: options));
        if (result.isSuccess) {
          onMenuUpdated(menu?.copyWith(displayOptions: options));
          ref.read(menuDisplayOptionsProvider.notifier).set(options);
          if (context.mounted) {
            showThemedSnackBar(context, 'Display options saved');
          }
        }
      },
    ),
  );
}
