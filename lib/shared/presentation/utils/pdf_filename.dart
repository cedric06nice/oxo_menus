import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';

String generatePdfFilename(
  String menuName,
  MenuDisplayOptions options, {
  DateTime? now,
}) {
  final date = now ?? DateTime.now();
  final datePart =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  final suffixes = <String>[
    if (options.showAllergens) 'Allergy',
    if (!options.showPrices) 'No Prices',
  ];

  final suffix = suffixes.isEmpty ? '' : ' - ${suffixes.join(' - ')}';

  return '$menuName$suffix ($datePart).pdf';
}
