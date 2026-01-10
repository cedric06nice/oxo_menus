import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/container.dart';

part 'container_repository.freezed.dart';

/// Repository interface for Container operations
abstract class ContainerRepository {
  /// Create a new container
  Future<Result<Container, DomainError>> create(CreateContainerInput input);

  /// Get all containers for a page
  Future<Result<List<Container>, DomainError>> getAllForPage(String pageId);

  /// Get container by ID
  Future<Result<Container, DomainError>> getById(String id);

  /// Update an existing container
  Future<Result<Container, DomainError>> update(UpdateContainerInput input);

  /// Delete a container
  Future<Result<void, DomainError>> delete(String id);

  /// Reorder a container within its page
  Future<Result<void, DomainError>> reorder(String containerId, int newIndex);

  /// Move container to a different page
  Future<Result<void, DomainError>> moveTo(
    String containerId,
    String newPageId,
    int index,
  );
}

/// Input for creating a container
@freezed
class CreateContainerInput with _$CreateContainerInput {
  const factory CreateContainerInput({
    required String pageId,
    required int index,
    String? name,
    LayoutConfig? layout,
  }) = _CreateContainerInput;
}

/// Input for updating a container
@freezed
class UpdateContainerInput with _$UpdateContainerInput {
  const factory UpdateContainerInput({
    required String id,
    String? name,
    int? index,
    LayoutConfig? layout,
  }) = _UpdateContainerInput;
}
