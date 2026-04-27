import 'package:flutter/material.dart';

/// Multi-select chip picker for allergen detail values.
///
/// The UI is backed by a fixed dictionary (`options`). Selection is serialized
/// to a single plain-text string — lowercase, comma-separated, ascending
/// alphabetical — matching the format stored in `AllergenInfo.details`.
///
/// Emits `null` when no chips are selected so callers can drop the details
/// field entirely.
class AllergenDetailChips extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  const AllergenDetailChips({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  Set<String> _parseSelected() {
    final raw = value;
    if (raw == null || raw.trim().isEmpty) return const <String>{};
    final tokens = raw
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();
    return tokens.where(options.contains).toSet();
  }

  String? _serialize(Set<String> selected) {
    if (selected.isEmpty) return null;
    final sorted = selected.toList()..sort();
    return sorted.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final selected = _parseSelected();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (isSelected) {
              final next = {...selected};
              if (isSelected) {
                next.add(option);
              } else {
                next.remove(option);
              }
              onChanged(_serialize(next));
            },
          ),
      ],
    );
  }
}
