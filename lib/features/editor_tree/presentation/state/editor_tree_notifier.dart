import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/features/editor_tree/presentation/state/editor_tree_state.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/editor_tree_loader_provider.dart';

class EditorTreeNotifier extends Notifier<EditorTreeState> {
  EditorTreeNotifier(this.menuId);

  final int menuId;

  @override
  EditorTreeState build() => const EditorTreeState();

  Future<void> loadTree({bool separateHeaderFooter = false}) async {
    final isInitialLoad = state.menu == null;
    state = state.copyWith(isLoading: isInitialLoad, errorMessage: null);

    final loader = ref.read(editorTreeLoaderProvider);

    final result = await loader.loadTree(menuId);

    if (result.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorOrNull?.message ?? 'Failed to load tree',
      );
      return;
    }

    final tree = result.valueOrNull!;

    if (separateHeaderFooter) {
      entity.Page? headerPage;
      entity.Page? footerPage;
      final contentPages = <entity.Page>[];

      for (final page in tree.pages) {
        switch (page.type) {
          case entity.PageType.header:
            headerPage = page;
          case entity.PageType.footer:
            footerPage = page;
          case entity.PageType.content:
            contentPages.add(page);
        }
      }

      state = state.copyWith(
        menu: tree.menu,
        pages: contentPages,
        headerPage: headerPage,
        footerPage: footerPage,
        containers: tree.containers,
        childContainers: tree.childContainers,
        columns: tree.columns,
        widgets: tree.widgets,
        isLoading: false,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(
        menu: tree.menu,
        pages: tree.pages,
        headerPage: null,
        footerPage: null,
        containers: tree.containers,
        childContainers: tree.childContainers,
        columns: tree.columns,
        widgets: tree.widgets,
        isLoading: false,
        errorMessage: null,
      );
    }
  }

  void updateHoverIndex(int columnId, int index) {
    state = state.copyWith(hoverIndex: {...state.hoverIndex, columnId: index});
  }

  void updateMenuLocally(Menu menu) {
    state = state.copyWith(menu: menu);
  }

  void updateContainerStyleLocally(int containerId, StyleConfig style) {
    final updated = <int, List<entity.Container>>{};
    for (final entry in state.containers.entries) {
      updated[entry.key] = entry.value.map((c) {
        if (c.id == containerId) return c.copyWith(styleConfig: style);
        return c;
      }).toList();
    }
    final updatedChildren = <int, List<entity.Container>>{};
    for (final entry in state.childContainers.entries) {
      updatedChildren[entry.key] = entry.value.map((c) {
        if (c.id == containerId) return c.copyWith(styleConfig: style);
        return c;
      }).toList();
    }
    state = state.copyWith(
      containers: updated,
      childContainers: updatedChildren,
    );
  }

  void updateContainerLayoutLocally(
    int containerId,
    entity.LayoutConfig layout,
  ) {
    final updated = <int, List<entity.Container>>{};
    for (final entry in state.containers.entries) {
      updated[entry.key] = entry.value.map((c) {
        if (c.id == containerId) return c.copyWith(layout: layout);
        return c;
      }).toList();
    }
    final updatedChildren = <int, List<entity.Container>>{};
    for (final entry in state.childContainers.entries) {
      updatedChildren[entry.key] = entry.value.map((c) {
        if (c.id == containerId) return c.copyWith(layout: layout);
        return c;
      }).toList();
    }
    state = state.copyWith(
      containers: updated,
      childContainers: updatedChildren,
    );
  }

  void updateColumnStyleLocally(int columnId, StyleConfig style) {
    final updated = <int, List<entity.Column>>{};
    for (final entry in state.columns.entries) {
      updated[entry.key] = entry.value.map((c) {
        if (c.id == columnId) return c.copyWith(styleConfig: style);
        return c;
      }).toList();
    }
    state = state.copyWith(columns: updated);
  }

  void updateColumnDroppableLocally(int columnId, bool droppable) {
    final updated = <int, List<entity.Column>>{};
    for (final entry in state.columns.entries) {
      updated[entry.key] = entry.value.map((c) {
        if (c.id == columnId) return c.copyWith(isDroppable: droppable);
        return c;
      }).toList();
    }
    state = state.copyWith(columns: updated);
  }

  // Widget CRUD

  Future<Result<WidgetInstance, DomainError>?> createWidget(
    String type,
    int columnId,
    int index, {
    bool isTemplate = false,
  }) async {
    final registry = ref.read(widgetRegistryProvider);
    final definition = registry.getDefinition(type);
    if (definition == null) return null;

    final propsJson =
        (definition.defaultProps as dynamic).toJson() as Map<String, dynamic>;

    final result = await ref
        .read(widgetRepositoryProvider)
        .create(
          CreateWidgetInput(
            columnId: columnId,
            type: type,
            version: definition.version,
            index: index,
            props: propsJson,
            isTemplate: isTemplate,
          ),
        );

    if (result.isSuccess) {
      await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
    }
    return result;
  }

  Future<Result<WidgetInstance, DomainError>> updateWidgetProps(
    int widgetId,
    Map<String, dynamic> props,
  ) async {
    final result = await ref
        .read(widgetRepositoryProvider)
        .update(UpdateWidgetInput(id: widgetId, props: props));

    if (result.isSuccess) {
      await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
    }
    return result;
  }

  Future<Result<WidgetInstance, DomainError>> updateWidgetLockForEdition(
    int widgetId,
    bool locked,
  ) async {
    final result = await ref
        .read(widgetRepositoryProvider)
        .update(UpdateWidgetInput(id: widgetId, lockedForEdition: locked));

    if (result.isSuccess) {
      final updated = <int, List<WidgetInstance>>{};
      for (final entry in state.widgets.entries) {
        updated[entry.key] = entry.value.map((w) {
          if (w.id == widgetId) return w.copyWith(lockedForEdition: locked);
          return w;
        }).toList();
      }
      state = state.copyWith(widgets: updated);
    }
    return result;
  }

  Future<Result<void, DomainError>> deleteWidget(int widgetId) async {
    // Optimistic removal: update state immediately so the Dismissible
    // animation doesn't conflict with the widget still being in the tree.
    final updatedWidgets = {
      for (final entry in state.widgets.entries)
        entry.key: entry.value.where((w) => w.id != widgetId).toList(),
    };
    state = state.copyWith(widgets: updatedWidgets);

    final result = await ref.read(widgetRepositoryProvider).delete(widgetId);

    // Reload tree to sync with server (also rolls back on failure).
    await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);

    return result;
  }

  Future<Result<void, DomainError>> moveWidget(
    WidgetInstance widget,
    int sourceCol,
    int targetCol,
    int index,
  ) async {
    final widgetRepo = ref.read(widgetRepositoryProvider);

    if (sourceCol == targetCol) {
      final adjustedIndex = index > widget.index ? index - 1 : index;
      final result = await widgetRepo.reorder(widget.id, adjustedIndex);
      if (result.isSuccess) {
        await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
      }
      return result;
    } else {
      final result = await widgetRepo.moveTo(widget.id, targetCol, index);
      if (result.isSuccess) {
        await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
      }
      return result;
    }
  }

  bool get _hasSeparateHeaderFooter =>
      state.headerPage != null || state.footerPage != null;

  // Container operations

  Future<Result<void, DomainError>> reorderContainer(
    int containerId,
    ReorderDirection direction,
  ) async {
    final useCase = ref.read(reorderContainerUseCaseProvider);
    final result = await useCase.execute(containerId, direction);
    if (result.isSuccess) {
      await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
    }
    return result;
  }

  Future<Result<entity.Container, DomainError>> duplicateContainer(
    int containerId,
  ) async {
    final useCase = ref.read(duplicateContainerUseCaseProvider);
    final result = await useCase.execute(containerId);
    if (result.isSuccess) {
      await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
    }
    return result;
  }

  // Widget locking

  Future<void> lockWidget(int widgetId, String userId) async {
    await ref.read(widgetRepositoryProvider).lockForEditing(widgetId, userId);
  }

  Future<void> unlockWidget(int widgetId) async {
    await ref.read(widgetRepositoryProvider).unlockEditing(widgetId);
  }
}
