import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';

part 'widget_repository.freezed.dart';

/// Repository interface for WidgetInstance operations
abstract class WidgetRepository {
  /// Create a new widget instance
  Future<Result<WidgetInstance, DomainError>> create(CreateWidgetInput input);

  /// Get all widget instances for a column
  Future<Result<List<WidgetInstance>, DomainError>> getAllForColumn(
    int columnId,
  );

  /// Get widget instance by ID
  Future<Result<WidgetInstance, DomainError>> getById(int id);

  /// Update an existing widget instance
  Future<Result<WidgetInstance, DomainError>> update(UpdateWidgetInput input);

  /// Delete a widget instance
  Future<Result<void, DomainError>> delete(int id);

  /// Reorder a widget within its column
  Future<Result<void, DomainError>> reorder(int widgetId, int newIndex);

  /// Move widget to a different column
  Future<Result<void, DomainError>> moveTo(
    int widgetId,
    int newColumnId,
    int index,
  );

  /// Lock a widget for editing by a user
  Future<Result<void, DomainError>> lockForEditing(int widgetId, String userId);

  /// Unlock a widget after editing
  Future<Result<void, DomainError>> unlockEditing(int widgetId);
}

/// Input for creating a widget instance
@freezed
abstract class CreateWidgetInput with _$CreateWidgetInput {
  const CreateWidgetInput._();

  const factory CreateWidgetInput({
    required int columnId,
    required String type,
    required String version,
    required int index,
    required Map<String, dynamic> props,
    WidgetStyle? style,
    @Default(false) bool isTemplate,
    @Default(false) bool lockedForEdition,
  }) = _CreateWidgetInput;
}

/// Input for updating a widget instance
@freezed
abstract class UpdateWidgetInput with _$UpdateWidgetInput {
  const UpdateWidgetInput._();

  const factory UpdateWidgetInput({
    required int id,
    String? type,
    String? version,
    int? index,
    Map<String, dynamic>? props,
    WidgetStyle? style,
    bool? lockedForEdition,
  }) = _UpdateWidgetInput;
}
