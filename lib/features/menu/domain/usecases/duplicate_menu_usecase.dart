import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';

/// Use case for duplicating a menu with all its pages, containers, columns, and widgets
class DuplicateMenuUseCase {
  final FetchMenuTreeUseCase fetchMenuTreeUseCase;
  final MenuRepository menuRepository;
  final PageRepository pageRepository;
  final ContainerRepository containerRepository;
  final ColumnRepository columnRepository;
  final WidgetRepository widgetRepository;
  final SizeRepository sizeRepository;

  DuplicateMenuUseCase({
    required this.fetchMenuTreeUseCase,
    required this.menuRepository,
    required this.pageRepository,
    required this.containerRepository,
    required this.columnRepository,
    required this.widgetRepository,
    required this.sizeRepository,
  });

  Future<Result<Menu, DomainError>> execute(int sourceMenuId) async {
    // Fetch source tree
    final treeResult = await fetchMenuTreeUseCase.execute(sourceMenuId);
    if (treeResult.isFailure) {
      return Failure(treeResult.errorOrNull!);
    }
    final tree = treeResult.valueOrNull!;
    final sourceMenu = tree.menu;

    // Resolve sizeId if pageSize is present
    final sizeIdResult = await _resolveSizeId(sourceMenu.pageSize);
    if (sizeIdResult.isFailure) {
      return Failure(sizeIdResult.errorOrNull!);
    }
    final sizeId = sizeIdResult.valueOrNull;

    // Create new menu with " (copy)" suffix
    final menuResult = await menuRepository.create(
      CreateMenuInput(
        name: '${sourceMenu.name} (copy)',
        version: sourceMenu.version,
        status: Status.draft,
        styleConfig: sourceMenu.styleConfig,
        sizeId: sizeId,
        areaId: sourceMenu.area?.id,
        displayOptions: sourceMenu.displayOptions,
      ),
    );
    if (menuResult.isFailure) {
      return Failure(menuResult.errorOrNull!);
    }
    final newMenu = menuResult.valueOrNull!;

    // Track created entity IDs for rollback
    final createdPageIds = <int>[];
    final createdContainerIds = <int>[];
    final createdColumnIds = <int>[];
    final createdWidgetIds = <int>[];

    // Collect all pages to copy (content + header + footer)
    final allSourcePages = <PageWithContainers>[
      ...tree.pages,
      if (tree.headerPage != null) tree.headerPage!,
      if (tree.footerPage != null) tree.footerPage!,
    ];

    // Copy pages with nested containers, columns, and widgets
    for (final pageWithContainers in allSourcePages) {
      final sourcePage = pageWithContainers.page;

      final pageResult = await pageRepository.create(
        CreatePageInput(
          menuId: newMenu.id,
          name: sourcePage.name,
          index: sourcePage.index,
          type: sourcePage.type,
        ),
      );
      if (pageResult.isFailure) {
        await _rollback(
          menuId: newMenu.id,
          pageIds: createdPageIds,
          containerIds: createdContainerIds,
          columnIds: createdColumnIds,
          widgetIds: createdWidgetIds,
        );
        return Failure(pageResult.errorOrNull!);
      }
      final newPage = pageResult.valueOrNull!;
      createdPageIds.add(newPage.id);

      // Copy containers for this page
      for (final containerWithColumns in pageWithContainers.containers) {
        final copyResult = await _copyContainerTree(
          containerWithColumns,
          newPage.id,
          null,
          newMenu.id,
          createdContainerIds,
          createdColumnIds,
          createdWidgetIds,
          createdPageIds,
        );
        if (copyResult.isFailure) {
          return Failure(copyResult.errorOrNull!);
        }
      }
    }

    return Success(newMenu);
  }

  Future<Result<void, DomainError>> _copyContainerTree(
    ContainerWithColumns containerWithColumns,
    int newPageId,
    int? parentContainerId,
    int menuId,
    List<int> createdContainerIds,
    List<int> createdColumnIds,
    List<int> createdWidgetIds,
    List<int> createdPageIds,
  ) async {
    final sourceContainer = containerWithColumns.container;

    final containerResult = await containerRepository.create(
      CreateContainerInput(
        pageId: newPageId,
        index: sourceContainer.index,
        direction: sourceContainer.layout?.direction ?? 'row',
        name: sourceContainer.name,
        parentContainerId: parentContainerId,
        layout: sourceContainer.layout,
        styleConfig: sourceContainer.styleConfig,
      ),
    );
    if (containerResult.isFailure) {
      await _rollback(
        menuId: menuId,
        pageIds: createdPageIds,
        containerIds: createdContainerIds,
        columnIds: createdColumnIds,
        widgetIds: createdWidgetIds,
      );
      return Failure(containerResult.errorOrNull!);
    }
    final newContainer = containerResult.valueOrNull!;
    createdContainerIds.add(newContainer.id);

    // Copy columns for this container
    for (final columnWithWidgets in containerWithColumns.columns) {
      final sourceColumn = columnWithWidgets.column;

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
          menuId: menuId,
          pageIds: createdPageIds,
          containerIds: createdContainerIds,
          columnIds: createdColumnIds,
          widgetIds: createdWidgetIds,
        );
        return Failure(columnResult.errorOrNull!);
      }
      final newColumn = columnResult.valueOrNull!;
      createdColumnIds.add(newColumn.id);

      // Copy widgets for this column
      for (final sourceWidget in columnWithWidgets.widgets) {
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
            menuId: menuId,
            pageIds: createdPageIds,
            containerIds: createdContainerIds,
            columnIds: createdColumnIds,
            widgetIds: createdWidgetIds,
          );
          return Failure(widgetResult.errorOrNull!);
        }
        final newWidget = widgetResult.valueOrNull!;
        createdWidgetIds.add(newWidget.id);
      }
    }

    // Recursively copy child containers
    for (final childContainer in containerWithColumns.children) {
      final childResult = await _copyContainerTree(
        childContainer,
        newPageId,
        newContainer.id,
        menuId,
        createdContainerIds,
        createdColumnIds,
        createdWidgetIds,
        createdPageIds,
      );
      if (childResult.isFailure) {
        return childResult;
      }
    }

    return const Success(null);
  }

  Future<void> _rollback({
    required int menuId,
    required List<int> pageIds,
    required List<int> containerIds,
    required List<int> columnIds,
    required List<int> widgetIds,
  }) async {
    // Delete in reverse order: widgets → columns → containers → pages → menu
    // Best-effort: ignore individual delete failures

    for (final widgetId in widgetIds.reversed) {
      await widgetRepository.delete(widgetId);
    }

    for (final columnId in columnIds.reversed) {
      await columnRepository.delete(columnId);
    }

    for (final containerId in containerIds.reversed) {
      await containerRepository.delete(containerId);
    }

    for (final pageId in pageIds.reversed) {
      await pageRepository.delete(pageId);
    }

    await menuRepository.delete(menuId);
  }

  Future<Result<int?, DomainError>> _resolveSizeId(PageSize? pageSize) async {
    if (pageSize == null) {
      return const Success(null);
    }

    final sizesResult = await sizeRepository.getAll();
    if (sizesResult.isFailure) {
      return Failure(sizesResult.errorOrNull!);
    }

    final sizes = sizesResult.valueOrNull!;
    final matchingSize = sizes
        .where(
          (s) =>
              s.name == pageSize.name &&
              s.width == pageSize.width &&
              s.height == pageSize.height,
        )
        .firstOrNull;

    return Success(matchingSize?.id);
  }
}
