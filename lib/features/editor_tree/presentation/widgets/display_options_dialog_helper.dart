import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_display_options_provider.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_settings/menu_settings_provider.dart';
import 'package:oxo_menus/features/menu_editor/presentation/widgets/menu_display_options_dialog.dart';

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
            .read(menuSettingsProvider.notifier)
            .updateDisplayOptions(menuId, options);
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
