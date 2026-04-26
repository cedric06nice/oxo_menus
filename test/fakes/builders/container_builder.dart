import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

/// Builds a [Container] with sensible test defaults.
///
/// ```dart
/// final container = buildContainer(pageId: 5, index: 0);
/// ```
Container buildContainer({
  int id = 1,
  int pageId = 1,
  int index = 0,
  String? name,
  int? parentContainerId,
  LayoutConfig? layout,
  StyleConfig? styleConfig,
  DateTime? dateCreated,
  DateTime? dateUpdated,
}) {
  return Container(
    id: id,
    pageId: pageId,
    index: index,
    name: name,
    parentContainerId: parentContainerId,
    layout: layout,
    styleConfig: styleConfig,
    dateCreated: dateCreated,
    dateUpdated: dateUpdated,
  );
}

/// Builds a [LayoutConfig] with all optional fields defaulting to null.
LayoutConfig buildLayoutConfig({
  String? direction,
  String? alignment,
  String? mainAxisAlignment,
  double? spacing,
}) {
  return LayoutConfig(
    direction: direction,
    alignment: alignment,
    mainAxisAlignment: mainAxisAlignment,
    spacing: spacing,
  );
}
