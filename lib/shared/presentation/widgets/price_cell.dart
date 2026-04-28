import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/price_formatter.dart';

/// Two-cell price row that anchors decimal points on the same x across rows.
///
/// Integer cell is right-aligned in a fixed width so the dot always lands at
/// the same x. Decimal cell is left-aligned in a fixed width to reserve space
/// regardless of "" / ".5" / ".25" / ".05".
class PriceCell extends StatelessWidget {
  final double price;
  final TextStyle style;
  final double integerWidth;
  final double decimalWidth;

  const PriceCell({
    super.key,
    required this.price,
    required this.style,
    this.integerWidth = 64,
    this.decimalWidth = 36,
  });

  @override
  Widget build(BuildContext context) {
    final parts = formatPriceParts(price);
    final tabular = style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: integerWidth,
          child: Text(parts.integer, style: tabular, textAlign: TextAlign.end),
        ),
        SizedBox(
          width: decimalWidth,
          child: Text(
            parts.decimal,
            style: tabular,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
