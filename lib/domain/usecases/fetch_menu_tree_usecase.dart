import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

part 'fetch_menu_tree_usecase.freezed.dart';

/// Use case to fetch a complete menu tree with all hierarchical data
abstract class FetchMenuTreeUseCase {
  final MenuRepository menuRepository;
  final PageRepository pageRepository;
  final ContainerRepository containerRepository;
  final ColumnRepository columnRepository;
  final WidgetRepository widgetRepository;

  const FetchMenuTreeUseCase({
    required this.menuRepository,
    required this.pageRepository,
    required this.containerRepository,
    required this.columnRepository,
    required this.widgetRepository,
  });

  /// Execute the use case to fetch menu tree by ID
  Future<Result<MenuTree, DomainError>> execute(String menuId) async {
    // 1. Fetch menu
    final menuResult = await menuRepository.getById(menuId);
    if (menuResult.isFailure) {
      return Failure(menuResult.errorOrNull!);
    }
    final menu = menuResult.valueOrNull!;

    // 2. Fetch pages for menu, sorted by index
    final pagesResult = await pageRepository.getAllForMenu(menuId);
    if (pagesResult.isFailure) {
      return Failure(pagesResult.errorOrNull!);
    }
    final pages = List<Page>.from(pagesResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));

    // 3. For each page, fetch containers
    final List<PageWithContainers> pagesWithContainers = [];
    for (final page in pages) {
      final containersResult =
          await containerRepository.getAllForPage(page.id);
      if (containersResult.isFailure) {
        return Failure(containersResult.errorOrNull!);
      }
      final containers = List<Container>.from(containersResult.valueOrNull!)
        ..sort((a, b) => a.index.compareTo(b.index));

      // 4. For each container, fetch columns
      final List<ContainerWithColumns> containersWithColumns = [];
      for (final container in containers) {
        final columnsResult =
            await columnRepository.getAllForContainer(container.id);
        if (columnsResult.isFailure) {
          return Failure(columnsResult.errorOrNull!);
        }
        final columns = List<Column>.from(columnsResult.valueOrNull!)
          ..sort((a, b) => a.index.compareTo(b.index));

        // 5. For each column, fetch widgets
        final List<ColumnWithWidgets> columnsWithWidgets = [];
        for (final column in columns) {
          final widgetsResult =
              await widgetRepository.getAllForColumn(column.id);
          if (widgetsResult.isFailure) {
            return Failure(widgetsResult.errorOrNull!);
          }
          final widgets = List<WidgetInstance>.from(widgetsResult.valueOrNull!)
            ..sort((a, b) => a.index.compareTo(b.index));

          columnsWithWidgets.add(ColumnWithWidgets(
            column: column,
            widgets: widgets,
          ));
        }

        containersWithColumns.add(ContainerWithColumns(
          container: container,
          columns: columnsWithWidgets,
        ));
      }

      pagesWithContainers.add(PageWithContainers(
        page: page,
        containers: containersWithColumns,
      ));
    }

    return Success(MenuTree(
      menu: menu,
      pages: pagesWithContainers,
    ));
  }
}

/// Complete menu tree with all hierarchical data
@freezed
abstract class MenuTree with _$MenuTree {
  const MenuTree._();

  const factory MenuTree({
    required Menu menu,
    required List<PageWithContainers> pages,
  }) = _MenuTree;
}

/// Page with its containers
@freezed
abstract class PageWithContainers with _$PageWithContainers {
  const PageWithContainers._();

  const factory PageWithContainers({
    required Page page,
    required List<ContainerWithColumns> containers,
  }) = _PageWithContainers;
}

/// Container with its columns
@freezed
abstract class ContainerWithColumns with _$ContainerWithColumns {
  const ContainerWithColumns._();

  const factory ContainerWithColumns({
    required Container container,
    required List<ColumnWithWidgets> columns,
  }) = _ContainerWithColumns;
}

/// Column with its widgets
@freezed
abstract class ColumnWithWidgets with _$ColumnWithWidgets {
  const ColumnWithWidgets._();

  const factory ColumnWithWidgets({
    required Column column,
    required List<WidgetInstance> widgets,
  }) = _ColumnWithWidgets;
}
