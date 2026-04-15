import 'package:intl/intl.dart';

typedef PriceParts = ({String integer, String decimal});

final NumberFormat _integerFormat = NumberFormat('#,##0', 'en_GB');

/// Splits a price into integer and decimal parts for decimal-aligned rendering.
///
/// Integer half is `£` + thousands-separated whole number.
/// Decimal half is empty when there are no fractional pence; otherwise it is
/// the dot followed by 1-2 digits with trailing zeros stripped (but leading
/// zeros preserved so 1.05 stays ".05" and never collapses to ".5").
PriceParts formatPriceParts(double price) {
  final integer = price.truncate();
  final cents = ((price - integer) * 100).round();
  final integerText = '£${_integerFormat.format(integer)}';
  if (cents == 0) {
    return (integer: integerText, decimal: '');
  }
  var decimal = cents.toString().padLeft(2, '0');
  decimal = decimal.replaceFirst(RegExp(r'0+$'), '');
  return (integer: integerText, decimal: '.$decimal');
}

/// Single-string price formatter for non-justified rendering.
String formatPrice(double price) {
  final parts = formatPriceParts(price);
  return '${parts.integer}${parts.decimal}';
}
