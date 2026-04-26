import 'package:oxo_menus/domain/entities/page.dart';

/// Builds a [Page] with sensible test defaults.
///
/// ```dart
/// final page = buildPage(menuId: 10, index: 0);
/// ```
Page buildPage({
  int id = 1,
  int menuId = 1,
  String name = 'Page 1',
  int index = 0,
  PageType type = PageType.content,
  DateTime? dateCreated,
  DateTime? dateUpdated,
}) {
  return Page(
    id: id,
    menuId: menuId,
    name: name,
    index: index,
    type: type,
    dateCreated: dateCreated,
    dateUpdated: dateUpdated,
  );
}
