import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';

/// Builds a [WidgetInstance] with sensible test defaults.
///
/// [props] defaults to an empty map.  Override the specific prop keys
/// relevant to the widget type under test:
/// ```dart
/// final widget = buildWidgetInstance(
///   type: 'dish',
///   props: {'name': 'Soup', 'price': 5.50},
/// );
/// ```
WidgetInstance buildWidgetInstance({
  int id = 1,
  int columnId = 1,
  String type = 'dish',
  String version = '1',
  int index = 0,
  Map<String, dynamic>? props,
  WidgetStyle? style,
  bool isTemplate = false,
  bool lockedForEdition = false,
  DateTime? dateCreated,
  DateTime? dateUpdated,
  String? editingBy,
  DateTime? editingSince,
}) {
  return WidgetInstance(
    id: id,
    columnId: columnId,
    type: type,
    version: version,
    index: index,
    props: props ?? {},
    style: style,
    isTemplate: isTemplate,
    lockedForEdition: lockedForEdition,
    dateCreated: dateCreated,
    dateUpdated: dateUpdated,
    editingBy: editingBy,
    editingSince: editingSince,
  );
}

/// Builds a [WidgetStyle] with all optional fields defaulting to null.
WidgetStyle buildWidgetStyle({
  String? fontFamily,
  double? fontSize,
  String? color,
  String? backgroundColor,
  String? border,
  double? padding,
}) {
  return WidgetStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    color: color,
    backgroundColor: backgroundColor,
    border: border,
    padding: padding,
  );
}
