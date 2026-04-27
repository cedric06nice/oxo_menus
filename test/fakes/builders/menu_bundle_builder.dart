import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';

/// Builds a [MenuBundle] with sensible test defaults.
///
/// ```dart
/// final bundle = buildMenuBundle(name: 'Weekend Specials', menuIds: [1, 2, 3]);
/// ```
MenuBundle buildMenuBundle({
  int id = 1,
  String name = 'Test Bundle',
  List<int>? menuIds,
  String? pdfFileId,
  DateTime? dateCreated,
  DateTime? dateUpdated,
}) {
  return MenuBundle(
    id: id,
    name: name,
    menuIds: menuIds ?? [],
    pdfFileId: pdfFileId,
    dateCreated: dateCreated,
    dateUpdated: dateUpdated,
  );
}
