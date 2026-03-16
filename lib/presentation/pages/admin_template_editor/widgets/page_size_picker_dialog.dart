import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

/// Dialog that lists available page sizes and lets the user pick one.
class PageSizePickerDialog extends StatelessWidget {
  final List<domain.Size> sizes;
  final PageSize? currentPageSize;
  final void Function(domain.Size) onSelect;

  const PageSizePickerDialog({
    super.key,
    required this.sizes,
    required this.onSelect,
    this.currentPageSize,
  });

  @override
  Widget build(BuildContext context) {
    return isApplePlatform(context)
        ? _buildCupertinoDialog(context)
        : _buildMaterialDialog(context);
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Select Page Size'),
      content: Column(
        children: sizes.map((size) {
          final isSelected =
              currentPageSize != null && currentPageSize!.name == size.name;
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              onSelect(size);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          size.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${size.width} x ${size.height} mm (${size.direction})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      CupertinoIcons.checkmark_alt,
                      color: CupertinoColors.activeBlue,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Page Size'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sizes.length,
          itemBuilder: (context, index) {
            final size = sizes[index];
            final isSelected =
                currentPageSize != null && currentPageSize!.name == size.name;

            return ListTile(
              title: Text(size.name),
              subtitle: Text(
                '${size.width} x ${size.height} mm (${size.direction})',
              ),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.of(context).pop();
                onSelect(size);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
