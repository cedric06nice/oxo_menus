import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Result of loading a full editor tree (menu → pages → containers → columns → widgets).
class EditorTree {
  final Menu menu;
  final List<entity.Page> pages;
  final Map<int, List<entity.Container>> containers;
  final Map<int, List<entity.Container>> childContainers;
  final Map<int, List<entity.Column>> columns;
  final Map<int, List<WidgetInstance>> widgets;

  const EditorTree({
    required this.menu,
    required this.pages,
    required this.containers,
    this.childContainers = const {},
    required this.columns,
    required this.widgets,
  });
}

/// Loads the full menu tree used by both AdminTemplateEditorPage and MenuEditorPage.
///
/// Fetches menu → pages → containers → columns → widgets in sequence,
/// sorting each level by index. If a child fetch fails, it is skipped
/// (the parent still loads successfully).
class EditorTreeLoader {
  final MenuRepository menuRepository;
  final PageRepository pageRepository;
  final ContainerRepository containerRepository;
  final ColumnRepository columnRepository;
  final WidgetRepository widgetRepository;

  const EditorTreeLoader({
    required this.menuRepository,
    required this.pageRepository,
    required this.containerRepository,
    required this.columnRepository,
    required this.widgetRepository,
  });

  Future<Result<EditorTree, DomainError>> loadTree(int menuId) async {
    // Load menu
    final menuResult = await menuRepository.getById(menuId);
    if (menuResult.isFailure) {
      return Failure(menuResult.errorOrNull!);
    }
    final menu = menuResult.valueOrNull!;

    // Load pages
    final pagesResult = await pageRepository.getAllForMenu(menuId);
    if (pagesResult.isFailure) {
      return Failure(pagesResult.errorOrNull!);
    }
    final pages = List<entity.Page>.from(pagesResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));

    // Load containers, columns, widgets
    final containers = <int, List<entity.Container>>{};
    final childContainers = <int, List<entity.Container>>{};
    final columns = <int, List<entity.Column>>{};
    final widgets = <int, List<WidgetInstance>>{};

    for (final page in pages) {
      final containersResult = await containerRepository.getAllForPage(page.id);
      if (containersResult.isFailure) continue;

      final pageContainers = List<entity.Container>.from(
        containersResult.valueOrNull!,
      )..sort((a, b) => a.index.compareTo(b.index));
      containers[page.id] = pageContainers;

      for (final container in pageContainers) {
        await _loadContainerContents(
          container,
          childContainers,
          columns,
          widgets,
        );
      }
    }

    return Success(
      EditorTree(
        menu: menu,
        pages: pages,
        containers: containers,
        childContainers: childContainers,
        columns: columns,
        widgets: widgets,
      ),
    );
  }

  Future<void> _loadContainerContents(
    entity.Container container,
    Map<int, List<entity.Container>> childContainers,
    Map<int, List<entity.Column>> columns,
    Map<int, List<WidgetInstance>> widgets,
  ) async {
    // Load columns for this container
    final columnsResult = await columnRepository.getAllForContainer(
      container.id,
    );
    if (columnsResult.isSuccess) {
      final containerColumns = List<entity.Column>.from(
        columnsResult.valueOrNull!,
      )..sort((a, b) => a.index.compareTo(b.index));
      columns[container.id] = containerColumns;

      for (final column in containerColumns) {
        final widgetsResult = await widgetRepository.getAllForColumn(column.id);
        if (widgetsResult.isFailure) continue;

        widgets[column.id] = List<WidgetInstance>.from(
          widgetsResult.valueOrNull!,
        )..sort((a, b) => a.index.compareTo(b.index));
      }
    }

    // Load child containers recursively
    final childResult = await containerRepository.getAllForContainer(
      container.id,
    );
    if (childResult.isSuccess) {
      final children = List<entity.Container>.from(childResult.valueOrNull!)
        ..sort((a, b) => a.index.compareTo(b.index));

      if (children.isNotEmpty) {
        childContainers[container.id] = children;

        for (final child in children) {
          await _loadContainerContents(
            child,
            childContainers,
            columns,
            widgets,
          );
        }
      }
    }
  }
}
