import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
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
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Flattened editor tree returned by [LoadTemplateForEditorUseCase].
///
/// Mirrors the shape the legacy `editor_tree` Riverpod state used so the
/// migrated screen can render with index-keyed lookups. Header / footer pages
/// are split out from the content pages so the UI can render the dedicated
/// header / footer slots without filtering on every rebuild.
class EditorTreeData {
  const EditorTreeData({
    required this.menu,
    required this.pages,
    required this.headerPage,
    required this.footerPage,
    required this.containers,
    required this.childContainers,
    required this.columns,
    required this.widgets,
  });

  final Menu menu;
  final List<entity.Page> pages;
  final entity.Page? headerPage;
  final entity.Page? footerPage;
  final Map<int, List<entity.Container>> containers;
  final Map<int, List<entity.Container>> childContainers;
  final Map<int, List<entity.Column>> columns;
  final Map<int, List<WidgetInstance>> widgets;
}

/// Loads the full template tree (menu → pages → containers → columns →
/// widgets) for the admin template editor.
///
/// Authorisation rule:
/// - **Admin** — performs the load.
/// - **Non-admin / anonymous** — returns [UnauthorizedError] without
///   touching any repository.
///
/// Pages are split into header / footer / content slots based on
/// [entity.PageType] so the screen can render the dedicated slots without
/// further filtering. Within each slot pages are sorted by index. Container
/// and column lookups are sorted by index too. If a child fetch fails the
/// parent is still returned with whatever children loaded successfully —
/// the UI can re-trigger a load to pick up missing pieces.
class LoadTemplateForEditorUseCase extends UseCase<int, EditorTreeData> {
  LoadTemplateForEditorUseCase({
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
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
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
