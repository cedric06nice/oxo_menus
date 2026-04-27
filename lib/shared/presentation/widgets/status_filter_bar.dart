import 'package:flutter/material.dart';

/// Reusable status filter bar with All/Draft/Published/Archived chips.
class StatusFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const StatusFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const _filters = ['all', 'draft', 'published', 'archived'];
  static const _labels = ['All', 'Draft', 'Published', 'Archived'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (i) {
            return Padding(
              padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
              child: ChoiceChip(
                label: Text(_labels[i]),
                selected: selectedFilter == _filters[i],
                onSelected: (_) => onFilterChanged(_filters[i]),
              ),
            );
          }),
        ),
      ),
    );
  }
}
