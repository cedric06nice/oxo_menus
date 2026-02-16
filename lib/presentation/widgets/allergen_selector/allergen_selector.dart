import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

/// Widget for selecting UK allergens with details and may-contain options
///
/// Displays all 14 UK allergens as checkboxes. When an allergen is selected,
/// shows a "may contain" sub-checkbox. For gluten and nuts, also shows a
/// text field to specify details (e.g., which cereals or which nuts).
class AllergenSelector extends StatefulWidget {
  final List<AllergenInfo> initialSelection;
  final ValueChanged<List<AllergenInfo>> onChanged;

  const AllergenSelector({
    super.key,
    required this.initialSelection,
    required this.onChanged,
  });

  @override
  State<AllergenSelector> createState() => _AllergenSelectorState();
}

class _AllergenSelectorState extends State<AllergenSelector> {
  late Map<UkAllergen, AllergenInfo?> _selections;
  late Map<UkAllergen, TextEditingController> _detailsControllers;

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  void _initializeSelections() {
    _selections = {};
    _detailsControllers = {};

    for (final allergen in UkAllergen.values) {
      final existing = widget.initialSelection
          .where((a) => a.allergen == allergen)
          .firstOrNull;
      _selections[allergen] = existing;

      if (allergen.supportsDetails) {
        _detailsControllers[allergen] = TextEditingController(
          text: existing?.details ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _detailsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _notifyChange() {
    final selected = _selections.values.whereType<AllergenInfo>().toList();
    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Allergens', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 3),
        ...UkAllergen.values.map((allergen) => _buildAllergenTile(allergen)),
      ],
    );
  }

  Widget _buildAllergenTile(UkAllergen allergen) {
    final isSelected = _selections[allergen] != null;
    final info = _selections[allergen];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox and allergen name
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selections[allergen] = AllergenInfo(
                          allergen: allergen,
                          mayContain: false,
                          details:
                              _detailsControllers[allergen]?.text.isEmpty ==
                                  true
                              ? null
                              : _detailsControllers[allergen]?.text,
                        );
                      } else {
                        _selections[allergen] = null;
                        // Clear details when deselected
                        _detailsControllers[allergen]?.clear();
                      }
                    });
                    _notifyChange();
                  },
                ),
                Expanded(
                  child: Text(
                    allergen.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            // May contain toggle and details (when selected)
            if (isSelected) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // May contain checkbox
                    Row(
                      children: [
                        SizedBox(
                          height: 32,
                          child: Checkbox(
                            value: info?.mayContain ?? false,
                            onChanged: (checked) {
                              setState(() {
                                _selections[allergen] = info?.copyWith(
                                  mayContain: checked ?? false,
                                );
                              });
                              _notifyChange();
                            },
                          ),
                        ),
                        const Text(
                          'May contain (trace amounts)',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),

                    // Details field for gluten and nuts
                    if (allergen.supportsDetails) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _detailsControllers[allergen],
                        decoration: InputDecoration(
                          labelText: 'Specify details',
                          hintText: allergen.detailsHint,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selections[allergen] = info?.copyWith(
                              details: value.isEmpty ? null : value,
                            );
                          });
                          _notifyChange();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
