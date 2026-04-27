import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

class DuplicateContainerUseCase {
  final ContainerRepository containerRepository;
  final ColumnRepository columnRepository;
  final WidgetRepository widgetRepository;

  DuplicateContainerUseCase({
    required this.containerRepository,
    required this.columnRepository,
    required this.widgetRepository,
  });

  Future<Result<Container, DomainError>> execute(int containerId) async {
    // 1. Fetch source container
    final containerResult = await containerRepository.getById(containerId);
    if (containerResult.isFailure) {
      return Failure(containerResult.errorOrNull!);
    }
    final source = containerResult.valueOrNull!;

    // 2. Fetch siblings and shift indices
    final siblingsResult = source.parentContainerId != null
        ? await containerRepository.getAllForContainer(
            source.parentContainerId!,
          )
        : await containerRepository.getAllForPage(source.pageId);
    if (siblingsResult.isFailure) {
      return Failure(siblingsResult.errorOrNull!);
    }

    final newIndex = source.index + 1;
    final siblings = siblingsResult.valueOrNull!;

    // Shift siblings with index >= newIndex (in descending order to avoid collisions)
    final toShift =
        siblings.where((c) => c.index >= newIndex && c.id != source.id).toList()
          ..sort((a, b) => b.index.compareTo(a.index));
    for (final sibling in toShift) {
      await containerRepository.reorder(sibling.id, sibling.index + 1);
    }

    // 3. Deep copy the container tree
    final createdContainerIds = <int>[];
    final createdColumnIds = <int>[];
    final createdWidgetIds = <int>[];

    final copyResult = await _copyContainerTree(
      source,
      source.pageId,
      source.parentContainerId,
      newIndex,
      createdContainerIds,
      createdColumnIds,
      createdWidgetIds,
    );

    if (copyResult.isFailure) {
      return Failure(copyResult.errorOrNull!);
    }

    return Success(copyResult.valueOrNull!);
  }

  Future<Result<Container, DomainError>> _copyContainerTree(
    Container source,
    int pageId,
    int? parentContainerId,
    int index,
    List<int> createdContainerIds,
    List<int> createdColumnIds,
    List<int> createdWidgetIds,
  ) async {
    // Create the new container
    final name = parentContainerId == source.parentContainerId
        ? _copyName(source.name)
        : source.name;

    final containerResult = await containerRepository.create(
      CreateContainerInput(
        pageId: pageId,
        index: index,
        direction: source.layout?.direction ?? 'row',
        name: name,
        parentContainerId: parentContainerId,
        layout: source.layout,
        styleConfig: source.styleConfig,
      ),
    );
    if (containerResult.isFailure) {
      await _rollback(createdContainerIds, createdColumnIds, createdWidgetIds);
      return Failure(containerResult.errorOrNull!);
    }
    final newContainer = containerResult.valueOrNull!;
    createdContainerIds.add(newContainer.id);

    // Copy columns
    final columnsResult = await columnRepository.getAllForContainer(source.id);
    if (columnsResult.isFailure) {
      await _rollback(createdContainerIds, createdColumnIds, createdWidgetIds);
      return Failure(columnsResult.errorOrNull!);
    }

    for (final sourceColumn in columnsResult.valueOrNull!) {
      final columnResult = await columnRepository.create(
        CreateColumnInput(
          containerId: newContainer.id,
          index: sourceColumn.index,
          flex: sourceColumn.flex,
          width: sourceColumn.width,
          styleConfig: sourceColumn.styleConfig,
          isDroppable: sourceColumn.isDroppable,
        ),
      );
      if (columnResult.isFailure) {
        await _rollback(
          createdContainerIds,
          createdColumnIds,
          createdWidgetIds,
        );
        return Failure(columnResult.errorOrNull!);
      }
      final newColumn = columnResult.valueOrNull!;
      createdColumnIds.add(newColumn.id);

      // Copy widgets in this column
      final widgetsResult = await widgetRepository.getAllForColumn(
        sourceColumn.id,
      );
      if (widgetsResult.isFailure) {
        await _rollback(
          createdContainerIds,
          createdColumnIds,
          createdWidgetIds,
        );
        return Failure(widgetsResult.errorOrNull!);
      }

      for (final sourceWidget in widgetsResult.valueOrNull!) {
        final widgetResult = await widgetRepository.create(
          CreateWidgetInput(
            columnId: newColumn.id,
            type: sourceWidget.type,
            version: sourceWidget.version,
            index: sourceWidget.index,
            props: Map<String, dynamic>.from(sourceWidget.props),
            style: sourceWidget.style,
            isTemplate: sourceWidget.isTemplate,
            lockedForEdition: sourceWidget.lockedForEdition,
          ),
        );
        if (widgetResult.isFailure) {
          await _rollback(
            createdContainerIds,
            createdColumnIds,
            createdWidgetIds,
          );
          return Failure(widgetResult.errorOrNull!);
        }
        createdWidgetIds.add(widgetResult.valueOrNull!.id);
      }
    }

    // Recursively copy child containers
    final childrenResult = await containerRepository.getAllForContainer(
      source.id,
    );
    if (childrenResult.isFailure) {
      await _rollback(createdContainerIds, createdColumnIds, createdWidgetIds);
      return Failure(childrenResult.errorOrNull!);
    }

    for (final child in childrenResult.valueOrNull!) {
      final childResult = await _copyContainerTree(
        child,
        pageId,
        newContainer.id,
        child.index,
        createdContainerIds,
        createdColumnIds,
        createdWidgetIds,
      );
      if (childResult.isFailure) {
        return Failure(childResult.errorOrNull!);
      }
    }

    return Success(newContainer);
  }

  String? _copyName(String? name) {
    if (name == null) return null;
    return '$name (copy)';
  }

  Future<void> _rollback(
    List<int> containerIds,
    List<int> columnIds,
    List<int> widgetIds,
  ) async {
    for (final id in widgetIds.reversed) {
      await widgetRepository.delete(id);
    }
    for (final id in columnIds.reversed) {
      await columnRepository.delete(id);
    }
    for (final id in containerIds.reversed) {
      await containerRepository.delete(id);
    }
  }
}
