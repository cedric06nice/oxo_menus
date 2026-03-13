import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/widgets/page_size_picker_dialog.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_provider.dart';

/// Shows a dialog to select a page size for a menu.
///
/// Loads sizes from the notifier, then shows a [PageSizePickerDialog].
/// On selection, updates the menu and calls [onPageSizeUpdated].
Future<void> showPageSizeDialog({
  required BuildContext context,
  required WidgetRef ref,
  required int menuId,
  required PageSize? currentPageSize,
  required void Function(PageSize) onPageSizeUpdated,
}) async {
  final notifier = ref.read(menuSettingsProvider.notifier);
  await notifier.loadSizes();
  final state = ref.read(menuSettingsProvider);

  if (state.errorMessage != null) {
    if (context.mounted) {
      showThemedSnackBar(
        context,
        'Failed to load sizes: ${state.errorMessage}',
        isError: true,
      );
    }
    return;
  }

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (ctx) => PageSizePickerDialog(
      sizes: state.sizes,
      currentPageSize: currentPageSize,
      onSelect: (size) async {
        final pageSize = PageSize(
          name: size.name,
          width: size.width,
          height: size.height,
        );
        final updateResult = await ref
            .read(menuSettingsProvider.notifier)
            .updatePageSize(menuId, size.id);
        if (updateResult.isSuccess) {
          onPageSizeUpdated(pageSize);
          if (context.mounted) {
            showThemedSnackBar(context, 'Page size updated');
          }
        }
      },
    ),
  );
}
