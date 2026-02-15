import 'package:oxo_menus/domain/entities/widget_instance.dart';

/// Data class for drag operations in editor pages.
/// Represents either a new widget type dragged from the palette
/// or an existing widget being reordered.
class WidgetDragData {
  final String? newWidgetType;
  final WidgetInstance? existingWidget;
  final int? sourceColumnId;

  const WidgetDragData.newWidget(String type)
    : newWidgetType = type,
      existingWidget = null,
      sourceColumnId = null;

  const WidgetDragData.existing(WidgetInstance widget, int columnId)
    : newWidgetType = null,
      existingWidget = widget,
      sourceColumnId = columnId;

  bool get isNewWidget => newWidgetType != null;
  bool get isExistingWidget => existingWidget != null;
}
