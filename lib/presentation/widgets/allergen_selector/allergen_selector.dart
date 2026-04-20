import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/presentation/widgets/allergen_selector/allergen_detail_chips.dart';

/// Widget for selecting UK allergens with details and may-contain options
///
/// Displays all 14 UK allergens as checkboxes. When an allergen is selected,
/// shows a "may contain" sub-checkbox. For gluten and nuts, also shows a
/// chip-based multi-select backed by a fixed dictionary so details are
/// consistent, typo-free, and stored in canonical sorted form.
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

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  void _initializeSelections() {
    _selections = {
      for (final allergen in UkAllergen.values)
        allergen: widget.initialSelection
            .where((a) => a.allergen == allergen)
            .firstOrNull,
    };
  }

  void _notifyChange() {
    final selected = _selections.values.whereType<AllergenInfo>().toList();
    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    if (isApplePlatform(context)) {
      return _buildAppleLayout();
    }
    return _buildMaterialLayout();
  }

  Widget _buildMaterialLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Allergens', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 3),
        ...UkAllergen.values.map(_buildMaterialTile),
      ],
    );
  }

  Widget _buildAppleLayout() {
    return CupertinoFormSection.insetGrouped(
      header: const Text('ALLERGENS'),
      children: UkAllergen.values.map(_buildAppleTile).toList(),
    );
  }

  Widget _buildAppleTile(UkAllergen allergen) {
    final isSelected = _selections[allergen] != null;
    final info = _selections[allergen];

    return Column(
      children: [
        GestureDetector(
          onTap: () => _toggleAllergen(allergen),
          child: Row(
            children: [
              _buildCheckbox(
                value: isSelected,
                onChanged: (_) => _toggleAllergen(allergen),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  allergen.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        if (isSelected) ...[
          Padding(
            padding: const EdgeInsets.only(left: 48, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: _buildCheckbox(
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
                if (allergen.supportsDetails) ...[
                  const SizedBox(height: 8),
                  _buildDetailsChips(allergen, info),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMaterialTile(UkAllergen allergen) {
    final isSelected = _selections[allergen] != null;
    final info = _selections[allergen];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCheckbox(
                  value: isSelected,
                  onChanged: (_) => _toggleAllergen(allergen),
                ),
                Expanded(
                  child: Text(
                    allergen.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 32,
                          child: _buildCheckbox(
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
                    if (allergen.supportsDetails) ...[
                      const SizedBox(height: 8),
                      _buildDetailsChips(allergen, info),
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

  void _toggleAllergen(UkAllergen allergen) {
    final isSelected = _selections[allergen] != null;
    setState(() {
      if (!isSelected) {
        _selections[allergen] = AllergenInfo(allergen: allergen);
      } else {
        _selections[allergen] = null;
      }
    });
    _notifyChange();
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    if (isApplePlatform(context)) {
      return CupertinoCheckbox(value: value, onChanged: onChanged);
    }
    return Checkbox(value: value, onChanged: onChanged);
  }

  Widget _buildDetailsChips(UkAllergen allergen, AllergenInfo? info) {
    return AllergenDetailChips(
      options: allergen.detailOptions,
      value: info?.details,
      onChanged: (value) {
        setState(() {
          _selections[allergen] = info?.copyWith(details: value);
        });
        _notifyChange();
      },
    );
  }
}
