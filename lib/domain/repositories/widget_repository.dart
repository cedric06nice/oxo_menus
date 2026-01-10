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
    String columnId,
  );

  /// Get widget instance by ID
  Future<Result<WidgetInstance, DomainError>> getById(String id);

  /// Update an existing widget instance
  Future<Result<WidgetInstance, DomainError>> update(UpdateWidgetInput input);

  /// Delete a widget instance
  Future<Result<void, DomainError>> delete(String id);

  /// Reorder a widget within its column
  Future<Result<void, DomainError>> reorder(String widgetId, int newIndex);

  /// Move widget to a different column
  Future<Result<void, DomainError>> moveTo(
    String widgetId,
    String newColumnId,
    int index,
  );
}

/// Input for creating a widget instance
@freezed
class CreateWidgetInput with _$CreateWidgetInput {
  const factory CreateWidgetInput({
    required String columnId,
    required String type,
    required String version,
    required int index,
    required Map<String, dynamic> props,
    WidgetStyle? style,
  }) = _CreateWidgetInput;
}

/// Input for updating a widget instance
@freezed
class UpdateWidgetInput with _$UpdateWidgetInput {
  const factory UpdateWidgetInput({
    required String id,
    String? type,
    String? version,
    int? index,
    Map<String, dynamic>? props,
    WidgetStyle? style,
  }) = _UpdateWidgetInput;
}
