import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows a Cupertino picker wheel in a bottom modal popup.
///
/// [items] — list of items to display.
/// [currentValue] — the currently selected value (scrolls to this index).
/// [labelBuilder] — converts item to display string.
/// [onSelected] — called with the chosen item when Done is tapped.
void showCupertinoPicker<T>(
  BuildContext context, {
  required List<T> items,
  required T currentValue,
  required String Function(T) labelBuilder,
  required ValueChanged<T> onSelected,
}) {
  final initialIndex = items.indexOf(currentValue).clamp(0, items.length - 1);
  var selectedIndex = initialIndex;

  showCupertinoModalPopup<void>(
    context: context,
    builder: (popupContext) {
      final brightness = Theme.of(context).brightness;
      final backgroundColor = brightness == Brightness.dark
          ? CupertinoColors.darkBackgroundGray
          : CupertinoColors.systemBackground;

      return Container(
        height: 260,
        color: backgroundColor,
        child: Column(
          children: [
            // Toolbar with Done button
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(popupContext),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.of(popupContext).pop();
                      onSelected(items[selectedIndex]);
                    },
                  ),
                ],
              ),
            ),
            // Picker wheel
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialIndex,
                ),
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: items
                    .map((item) => Center(child: Text(labelBuilder(item))))
                    .toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
