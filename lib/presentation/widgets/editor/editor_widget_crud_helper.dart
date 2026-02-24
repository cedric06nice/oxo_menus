import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';

/// Helper class for widget CRUD operations in editors.
///
/// Provides shared logic for creating, updating, deleting, and moving widgets
/// in both AdminTemplateEditorPage and MenuEditorPage.
///
/// Key differences between pages are handled via constructor parameters:
/// - `isTemplate`: true for admin (creates template widgets), false for menu
/// - `onReload`: callback to refresh page data after operations
/// - `onMessage`: callback to show messages to user (replaces ScaffoldMessenger)
class EditorWidgetCrudHelper {
  final WidgetRepository widgetRepository;
  final WidgetRegistry widgetRegistry;
  final Future<void> Function() onReload;
  final bool isTemplate;
  final void Function(String message, {bool isError})? onMessage;
  final String? currentUserId;

  const EditorWidgetCrudHelper({
    required this.widgetRepository,
    required this.widgetRegistry,
    required this.onReload,
    required this.isTemplate,
    this.onMessage,
    this.currentUserId,
  });

  /// Handle dropping a new widget at a specific index
  Future<void> handleWidgetDropAtIndex(
    String widgetType,
    int columnId,
    int index,
  ) async {
    try {
      final definition = widgetRegistry.getDefinition(widgetType);
      if (definition == null) {
        onMessage?.call('Unknown widget type: $widgetType', isError: true);
        return;
      }

      final propsJson =
          (definition.defaultProps as dynamic).toJson() as Map<String, dynamic>;

      final result = await widgetRepository.create(
        CreateWidgetInput(
          columnId: columnId,
          type: widgetType,
          version: definition.version,
          index: index,
          props: propsJson,
          isTemplate: isTemplate,
        ),
      );

      if (result.isSuccess) {
        await onReload();
      } else {
        onMessage?.call(
          'Failed to create widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
          isError: true,
        );
      }
    } catch (e) {
      onMessage?.call('Error creating widget: $e', isError: true);
    }
  }

  /// Handle updating widget props
  Future<void> handleWidgetUpdate(
    int widgetId,
    Map<String, dynamic> updatedProps,
  ) async {
    final result = await widgetRepository.update(
      UpdateWidgetInput(id: widgetId, props: updatedProps),
    );

    if (result.isSuccess) {
      await onReload();
    }
  }

  /// Perform widget deletion (without confirmation)
  Future<void> performWidgetDelete(int widgetId) async {
    final result = await widgetRepository.delete(widgetId);

    if (result.isSuccess) {
      await onReload();
    } else {
      onMessage?.call(
        'Failed to delete widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  /// Handle moving/reordering a widget
  Future<void> handleWidgetMoveToIndex(
    WidgetInstance widget,
    int sourceColumnId,
    int targetColumnId,
    int targetIndex,
  ) async {
    try {
      if (sourceColumnId == targetColumnId) {
        // Reordering within the same column
        // Adjust index if moving down (since removing the widget shifts indices)
        final adjustedIndex = targetIndex > widget.index
            ? targetIndex - 1
            : targetIndex;

        final result = await widgetRepository.reorder(widget.id, adjustedIndex);

        if (result.isSuccess) {
          await onReload();
        } else {
          onMessage?.call(
            'Failed to reorder widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
            isError: true,
          );
        }
      } else {
        // Moving to a different column
        final result = await widgetRepository.moveTo(
          widget.id,
          targetColumnId,
          targetIndex,
        );

        if (result.isSuccess) {
          await onReload();
        } else {
          onMessage?.call(
            'Failed to move widget: ${result.errorOrNull?.message ?? 'Unknown error'}',
            isError: true,
          );
        }
      }
    } catch (e) {
      onMessage?.call('Error moving widget: $e', isError: true);
    }
  }

  /// Lock a widget for editing by the current user
  Future<void> lockWidget(int widgetId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await widgetRepository.lockForEditing(widgetId, userId);
  }

  /// Unlock a widget after editing
  Future<void> unlockWidget(int widgetId) async {
    await widgetRepository.unlockEditing(widgetId);
  }
}
