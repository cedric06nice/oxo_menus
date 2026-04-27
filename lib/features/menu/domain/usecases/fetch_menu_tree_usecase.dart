import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

part 'fetch_menu_tree_usecase.freezed.dart';

/// Use case to fetch a complete menu tree with all hierarchical data
class FetchMenuTreeUseCase {
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
  Future<Result<MenuTree, DomainError>> execute(int menuId) async {
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

    // 3. Build tree with parallel fetches at each level
    try {
      final pagesWithContainers = await Future.wait(pages.map(_buildPageTree));

      // 4. Separate pages by type
      PageWithContainers? headerPage;
      PageWithContainers? footerPage;
      final contentPages = <PageWithContainers>[];

      for (final pageWithContainers in pagesWithContainers) {
        switch (pageWithContainers.page.type) {
          case PageType.header:
            headerPage = pageWithContainers;
            break;
          case PageType.footer:
            footerPage = pageWithContainers;
            break;
          case PageType.content:
            contentPages.add(pageWithContainers);
            break;
        }
      }

      return Success(
        MenuTree(
          menu: menu,
          pages: contentPages,
          headerPage: headerPage,
          footerPage: footerPage,
        ),
      );
    } on DomainError catch (e) {
      return Failure(e);
    }
  }

  Future<PageWithContainers> _buildPageTree(Page page) async {
    final result = await containerRepository.getAllForPage(page.id);
    if (result.isFailure) throw result.errorOrNull!;
    final containers = List<Container>.from(result.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));
    final withColumns = await Future.wait(containers.map(_buildContainerTree));
    return PageWithContainers(page: page, containers: withColumns);
  }

  Future<ContainerWithColumns> _buildContainerTree(Container container) async {
    final columnResult = await columnRepository.getAllForContainer(
      container.id,
    );
    if (columnResult.isFailure) throw columnResult.errorOrNull!;
    final columns = List<Column>.from(columnResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));
    final withWidgets = await Future.wait(columns.map(_buildColumnTree));

    // Fetch child containers recursively
    final childResult = await containerRepository.getAllForContainer(
      container.id,
    );
    if (childResult.isFailure) throw childResult.errorOrNull!;
    final childContainers = List<Container>.from(childResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));
    final withChildren = await Future.wait(
      childContainers.map(_buildContainerTree),
    );

    return ContainerWithColumns(
      container: container,
      columns: withWidgets,
      children: withChildren,
    );
  }

  Future<ColumnWithWidgets> _buildColumnTree(Column column) async {
    final result = await widgetRepository.getAllForColumn(column.id);
    if (result.isFailure) throw result.errorOrNull!;
    final widgets = List<WidgetInstance>.from(result.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));
    return ColumnWithWidgets(column: column, widgets: widgets);
  }
}

/// Complete menu tree with all hierarchical data
@freezed
abstract class MenuTree with _$MenuTree {
  const MenuTree._();

  const factory MenuTree({
    required Menu menu,
    required List<PageWithContainers> pages,
    PageWithContainers? headerPage,
    PageWithContainers? footerPage,
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
    @Default([]) List<ContainerWithColumns> children,
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
