import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/widgets/page_size_picker_dialog.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

/// Shows a dialog to select a page size for a menu.
///
/// Loads sizes from the repository, then shows a [PageSizePickerDialog].
/// On selection, updates the menu and calls [onPageSizeUpdated].
Future<void> showPageSizeDialog({
  required BuildContext context,
  required WidgetRef ref,
  required int menuId,
  required PageSize? currentPageSize,
  required void Function(PageSize) onPageSizeUpdated,
}) async {
  final result = await ref.read(sizeRepositoryProvider).getAll();
  if (result.isFailure) {
    if (context.mounted) {
      showThemedSnackBar(
        context,
        'Failed to load sizes: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
    return;
  }

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (ctx) => PageSizePickerDialog(
      sizes: result.valueOrNull!,
      currentPageSize: currentPageSize,
      onSelect: (size) async {
        final pageSize = PageSize(
          name: size.name,
          width: size.width,
          height: size.height,
        );
        final updateResult = await ref
            .read(menuRepositoryProvider)
            .update(UpdateMenuInput(id: menuId, sizeId: size.id));
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
