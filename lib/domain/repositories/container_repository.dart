import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

part 'container_repository.freezed.dart';

/// Repository interface for Container operations
abstract class ContainerRepository {
  /// Create a new container
  Future<Result<Container, DomainError>> create(CreateContainerInput input);

  /// Get all top-level containers for a page (excludes nested children)
  Future<Result<List<Container>, DomainError>> getAllForPage(int pageId);

  /// Get all child containers for a parent container
  Future<Result<List<Container>, DomainError>> getAllForContainer(
    int containerId,
  );

  /// Get container by ID
  Future<Result<Container, DomainError>> getById(int id);

  /// Update an existing container
  Future<Result<Container, DomainError>> update(UpdateContainerInput input);

  /// Delete a container
  Future<Result<void, DomainError>> delete(int id);

  /// Reorder a container within its page
  Future<Result<void, DomainError>> reorder(int containerId, int newIndex);

  /// Move container to a different page
  Future<Result<void, DomainError>> moveTo(
    int containerId,
    int newPageId,
    int index,
  );
}

/// Input for creating a container
@freezed
abstract class CreateContainerInput with _$CreateContainerInput {
  const CreateContainerInput._();

  const factory CreateContainerInput({
    required int pageId,
    required int index,
    required String direction,
    String? name,
    int? parentContainerId,
    LayoutConfig? layout,
    StyleConfig? styleConfig,
  }) = _CreateContainerInput;
}

/// Input for updating a container
@freezed
abstract class UpdateContainerInput with _$UpdateContainerInput {
  const UpdateContainerInput._();

  const factory UpdateContainerInput({
    required int id,
    String? name,
    int? index,
    LayoutConfig? layout,
    StyleConfig? styleConfig,
  }) = _UpdateContainerInput;
}
