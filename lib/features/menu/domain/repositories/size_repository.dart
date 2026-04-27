import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

part 'size_repository.freezed.dart';

/// Repository interface for Size operations
abstract class SizeRepository {
  /// Get all available sizes
  Future<Result<List<Size>, DomainError>> getAll();

  /// Get size by ID
  Future<Result<Size, DomainError>> getById(int id);

  /// Create a new size
  Future<Result<Size, DomainError>> create(CreateSizeInput input);

  /// Update an existing size
  Future<Result<Size, DomainError>> update(UpdateSizeInput input);

  /// Delete a size by ID
  Future<Result<void, DomainError>> delete(int id);
}

/// Input for creating a size
@freezed
abstract class CreateSizeInput with _$CreateSizeInput {
  const CreateSizeInput._();

  const factory CreateSizeInput({
    required String name,
    required double width,
    required double height,
    required Status status,
    required String direction,
  }) = _CreateSizeInput;
}

/// Input for updating a size
@freezed
abstract class UpdateSizeInput with _$UpdateSizeInput {
  const UpdateSizeInput._();

  const factory UpdateSizeInput({
    required int id,
    String? name,
    double? width,
    double? height,
    Status? status,
    String? direction,
  }) = _UpdateSizeInput;
}
