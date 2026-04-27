import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';

enum ReorderDirection { up, down }

class ReorderContainerUseCase {
  final ContainerRepository containerRepository;

  ReorderContainerUseCase({required this.containerRepository});

  Future<Result<void, DomainError>> execute(
    int containerId,
    ReorderDirection direction,
  ) async {
    // 1. Fetch the container
    final containerResult = await containerRepository.getById(containerId);
    if (containerResult.isFailure) {
      return Failure(containerResult.errorOrNull!);
    }
    final container = containerResult.valueOrNull!;

    // 2. Fetch siblings (from parent container or page)
    final Result<List<dynamic>, DomainError> siblingsResult;
    if (container.parentContainerId != null) {
      siblingsResult = await containerRepository.getAllForContainer(
        container.parentContainerId!,
      );
    } else {
      siblingsResult = await containerRepository.getAllForPage(
        container.pageId,
      );
    }
    if (siblingsResult.isFailure) {
      return Failure(siblingsResult.errorOrNull!);
    }

    final siblings = List.of(siblingsResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));

    // 3. Find position in sorted list
    final currentPosition = siblings.indexWhere((c) => c.id == containerId);

    // 4. Validate bounds
    if (direction == ReorderDirection.up && currentPosition <= 0) {
      return const Failure(
        ValidationError('Container is already at the first position'),
      );
    }
    if (direction == ReorderDirection.down &&
        currentPosition >= siblings.length - 1) {
      return const Failure(
        ValidationError('Container is already at the last position'),
      );
    }

    // 5. Find adjacent sibling and swap indices
    final adjacentPosition = direction == ReorderDirection.up
        ? currentPosition - 1
        : currentPosition + 1;
    final adjacent = siblings[adjacentPosition];

    final currentIndex = container.index;
    final adjacentIndex = adjacent.index;

    // Swap: move current to adjacent's index, adjacent to current's index
    final firstResult = await containerRepository.reorder(
      containerId,
      adjacentIndex,
    );
    if (firstResult.isFailure) {
      return Failure(firstResult.errorOrNull!);
    }

    final secondResult = await containerRepository.reorder(
      adjacent.id,
      currentIndex,
    );
    if (secondResult.isFailure) {
      return Failure(secondResult.errorOrNull!);
    }

    return const Success(null);
  }
}
