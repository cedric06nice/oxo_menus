import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/editor_tree_data.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Loads the full menu tree (menu → pages → containers → columns → widgets)
/// for the consumer-facing menu editor.
///
/// Authorisation rule:
/// - **Authenticated user** — performs the load.
/// - **Anonymous viewer** — returns [UnauthorizedError] without touching any
///   repository.
///
/// Pages, containers, and columns are sorted by index. Header / footer pages
/// are split out from the content pages so the screen can render them in
/// dedicated slots without filtering on every rebuild — same shape the admin
/// template editor receives so both screens share the data model. If a child
/// fetch fails the parent is still returned with whatever children loaded
/// successfully.
class LoadMenuForEditorUseCase extends UseCase<int, EditorTreeData> {
  LoadMenuForEditorUseCase({
    required AuthGateway authGateway,
    required MenuRepository menuRepository,
    required PageRepository pageRepository,
    required ContainerRepository containerRepository,
    required ColumnRepository columnRepository,
    required WidgetRepository widgetRepository,
  }) : _authGateway = authGateway,
       _menuRepository = menuRepository,
       _pageRepository = pageRepository,
       _containerRepository = containerRepository,
       _columnRepository = columnRepository,
       _widgetRepository = widgetRepository;

  final AuthGateway _authGateway;
  final MenuRepository _menuRepository;
  final PageRepository _pageRepository;
  final ContainerRepository _containerRepository;
  final ColumnRepository _columnRepository;
  final WidgetRepository _widgetRepository;

  @override
  Future<Result<EditorTreeData, DomainError>> execute(int menuId) async {
    if (_authGateway.currentUser == null) {
      return const Failure<EditorTreeData, DomainError>(UnauthorizedError());
    }

    final menuResult = await _menuRepository.getById(menuId);
    if (menuResult.isFailure) {
      return Failure<EditorTreeData, DomainError>(menuResult.errorOrNull!);
    }

    final pagesResult = await _pageRepository.getAllForMenu(menuId);
    if (pagesResult.isFailure) {
      return Failure<EditorTreeData, DomainError>(pagesResult.errorOrNull!);
    }
    final allPages = List<entity.Page>.from(pagesResult.valueOrNull!)
      ..sort((a, b) => a.index.compareTo(b.index));

    entity.Page? headerPage;
    entity.Page? footerPage;
    final contentPages = <entity.Page>[];
    for (final page in allPages) {
      switch (page.type) {
        case entity.PageType.header:
          headerPage = page;
        case entity.PageType.footer:
          footerPage = page;
        case entity.PageType.content:
          contentPages.add(page);
      }
    }

    final containers = <int, List<entity.Container>>{};
    final childContainers = <int, List<entity.Container>>{};
    final columns = <int, List<entity.Column>>{};
    final widgets = <int, List<WidgetInstance>>{};

    for (final page in allPages) {
      final pageContainersResult = await _containerRepository.getAllForPage(
        page.id,
      );
      if (pageContainersResult.isFailure) {
        continue;
      }
      final pageContainers = List<entity.Container>.from(
        pageContainersResult.valueOrNull!,
      )..sort((a, b) => a.index.compareTo(b.index));
      containers[page.id] = pageContainers;
      for (final container in pageContainers) {
        await _loadContainerContents(
          container,
          childContainers: childContainers,
          columns: columns,
          widgets: widgets,
        );
      }
    }

    return Success<EditorTreeData, DomainError>(
      EditorTreeData(
        menu: menuResult.valueOrNull!,
        pages: contentPages,
        headerPage: headerPage,
        footerPage: footerPage,
        containers: containers,
        childContainers: childContainers,
        columns: columns,
        widgets: widgets,
      ),
    );
  }

  Future<void> _loadContainerContents(
    entity.Container container, {
    required Map<int, List<entity.Container>> childContainers,
    required Map<int, List<entity.Column>> columns,
    required Map<int, List<WidgetInstance>> widgets,
  }) async {
    final columnsResult = await _columnRepository.getAllForContainer(
      container.id,
    );
    if (columnsResult.isSuccess) {
      final containerColumns = List<entity.Column>.from(
        columnsResult.valueOrNull!,
      )..sort((a, b) => a.index.compareTo(b.index));
      columns[container.id] = containerColumns;
      for (final column in containerColumns) {
        final widgetsResult = await _widgetRepository.getAllForColumn(
          column.id,
        );
        if (widgetsResult.isFailure) {
          continue;
        }
        widgets[column.id] = List<WidgetInstance>.from(
          widgetsResult.valueOrNull!,
        )..sort((a, b) => a.index.compareTo(b.index));
      }
    }

    final childResult = await _containerRepository.getAllForContainer(
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
            childContainers: childContainers,
            columns: columns,
            widgets: widgets,
          );
        }
      }
    }
  }
}
