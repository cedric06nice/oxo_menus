import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';

part 'column_repository.freezed.dart';

/// Repository interface for Column operations
abstract class ColumnRepository {
  /// Create a new column
  Future<Result<Column, DomainError>> create(CreateColumnInput input);

  /// Get all columns for a container
  Future<Result<List<Column>, DomainError>> getAllForContainer(
    String containerId,
  );

  /// Get column by ID
  Future<Result<Column, DomainError>> getById(String id);

  /// Update an existing column
  Future<Result<Column, DomainError>> update(UpdateColumnInput input);

  /// Delete a column
  Future<Result<void, DomainError>> delete(String id);

  /// Reorder a column within its container
  Future<Result<void, DomainError>> reorder(String columnId, int newIndex);
}

/// Input for creating a column
@freezed
class CreateColumnInput with _$CreateColumnInput {
  const factory CreateColumnInput({
    required String containerId,
    required int index,
    int? flex,
    double? width,
  }) = _CreateColumnInput;
}

/// Input for updating a column
@freezed
class UpdateColumnInput with _$UpdateColumnInput {
  const factory UpdateColumnInput({
    required String id,
    int? index,
    int? flex,
    double? width,
  }) = _UpdateColumnInput;
}
