import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';

part 'column_repository.freezed.dart';

/// Repository interface for Column operations
abstract class ColumnRepository {
  /// Create a new column
  Future<Result<Column, DomainError>> create(CreateColumnInput input);

  /// Get all columns for a container
  Future<Result<List<Column>, DomainError>> getAllForContainer(int containerId);

  /// Get column by ID
  Future<Result<Column, DomainError>> getById(int id);

  /// Update an existing column
  Future<Result<Column, DomainError>> update(UpdateColumnInput input);

  /// Delete a column
  Future<Result<void, DomainError>> delete(int id);

  /// Reorder a column within its container
  Future<Result<void, DomainError>> reorder(int columnId, int newIndex);
}

/// Input for creating a column
@freezed
abstract class CreateColumnInput with _$CreateColumnInput {
  const CreateColumnInput._();

  const factory CreateColumnInput({
    required int containerId,
    required int index,
    int? flex,
    double? width,
    StyleConfig? styleConfig,
    bool? isDroppable,
  }) = _CreateColumnInput;
}

/// Input for updating a column
@freezed
abstract class UpdateColumnInput with _$UpdateColumnInput {
  const UpdateColumnInput._();

  const factory UpdateColumnInput({
    required int id,
    int? index,
    int? flex,
    double? width,
    StyleConfig? styleConfig,
    bool? isDroppable,
  }) = _UpdateColumnInput;
}
