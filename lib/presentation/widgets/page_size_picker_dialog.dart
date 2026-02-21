import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;

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
