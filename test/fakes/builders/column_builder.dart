import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

/// Builds a [Column] with sensible test defaults.
///
/// ```dart
/// final column = buildColumn(containerId: 3, index: 0);
/// ```
Column buildColumn({
  int id = 1,
  int containerId = 1,
  int index = 0,
  int? flex,
  double? width,
  StyleConfig? styleConfig,
  bool isDroppable = true,
  DateTime? dateCreated,
  DateTime? dateUpdated,
}) {
  return Column(
    id: id,
    containerId: containerId,
    index: index,
    flex: flex,
    width: width,
    styleConfig: styleConfig,
    isDroppable: isDroppable,
    dateCreated: dateCreated,
    dateUpdated: dateUpdated,
  );
}
