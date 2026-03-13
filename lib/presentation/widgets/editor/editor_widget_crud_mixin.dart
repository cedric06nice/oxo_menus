import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_helper.dart';

/// Mixin providing shared widget CRUD delegation methods for editor pages.
///
/// Both AdminTemplateEditorPage and MenuEditorPage delegate widget operations
/// to [EditorWidgetCrudHelper]. This mixin eliminates the identical wrapper
/// methods that both pages define.
///
/// The mixing class must provide [crudHelper].
mixin EditorWidgetCrudMixin {
  EditorWidgetCrudHelper get crudHelper;

  Future<void> handleWidgetUpdate(
    int widgetId,
    Map<String, dynamic> updatedProps,
  ) async {
    await crudHelper.handleWidgetUpdate(widgetId, updatedProps);
  }

  Future<void> performWidgetDelete(int widgetId) async {
    await crudHelper.performWidgetDelete(widgetId);
  }

  Future<void> handleWidgetMoveToIndex(
    WidgetInstance widget,
    int sourceColumnId,
    int targetColumnId,
    int targetIndex,
  ) async {
    await crudHelper.handleWidgetMoveToIndex(
      widget,
      sourceColumnId,
      targetColumnId,
      targetIndex,
    );
  }
}
