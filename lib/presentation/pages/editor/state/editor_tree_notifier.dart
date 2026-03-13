import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_tree_loader.dart';

class EditorTreeNotifier extends Notifier<EditorTreeState> {
  EditorTreeNotifier(this.menuId);

  final int menuId;

  @override
  EditorTreeState build() => const EditorTreeState();

  Future<void> loadTree({bool separateHeaderFooter = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final loader = EditorTreeLoader(
      menuRepository: ref.read(menuRepositoryProvider),
      pageRepository: ref.read(pageRepositoryProvider),
      containerRepository: ref.read(containerRepositoryProvider),
      columnRepository: ref.read(columnRepositoryProvider),
      widgetRepository: ref.read(widgetRepositoryProvider),
    );

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
    state = state.copyWith(containers: updated);
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

  Future<void> createWidget(
    String type,
    int columnId,
    int index, {
    bool isTemplate = false,
  }) async {
    final registry = ref.read(widgetRegistryProvider);
    final definition = registry.getDefinition(type);
    if (definition == null) return;

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
  }

  Future<void> updateWidgetProps(
    int widgetId,
    Map<String, dynamic> props,
  ) async {
    final result = await ref
        .read(widgetRepositoryProvider)
        .update(UpdateWidgetInput(id: widgetId, props: props));

    if (result.isSuccess) {
      await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
    }
  }

  Future<void> deleteWidget(int widgetId) async {
    final result = await ref.read(widgetRepositoryProvider).delete(widgetId);

    if (result.isSuccess) {
      await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
    }
  }

  Future<void> moveWidget(
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
    } else {
      final result = await widgetRepo.moveTo(widget.id, targetCol, index);
      if (result.isSuccess) {
        await loadTree(separateHeaderFooter: _hasSeparateHeaderFooter);
      }
    }
  }

  bool get _hasSeparateHeaderFooter =>
      state.headerPage != null || state.footerPage != null;
}
