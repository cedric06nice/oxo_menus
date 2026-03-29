import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/models/editor_selection.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/state/template_editor_state.dart';
import 'package:oxo_menus/presentation/pages/editor/state/editor_tree_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class TemplateEditorNotifier extends Notifier<TemplateEditorState> {
  TemplateEditorNotifier(this.menuId);

  final int menuId;
  Timer? _styleDebounceTimer;

  @override
  TemplateEditorState build() {
    ref.onDispose(() => _styleDebounceTimer?.cancel());
    return const TemplateEditorState();
  }

  // Structure CRUD

  Future<void> addPage(int pageCount) async {
    final result = await ref
        .read(pageRepositoryProvider)
        .create(
          CreatePageInput(
            menuId: menuId,
            name: 'Page ${pageCount + 1}',
            index: pageCount,
          ),
        );
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> deletePage(int pageId) async {
    final result = await ref.read(pageRepositoryProvider).delete(pageId);
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> addHeader() async {
    final result = await ref
        .read(pageRepositoryProvider)
        .create(
          CreatePageInput(
            menuId: menuId,
            name: 'Header',
            index: 0,
            type: entity.PageType.header,
          ),
        );
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> deleteHeader(int pageId) async {
    final result = await ref.read(pageRepositoryProvider).delete(pageId);
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> addFooter() async {
    final result = await ref
        .read(pageRepositoryProvider)
        .create(
          CreatePageInput(
            menuId: menuId,
            name: 'Footer',
            index: 0,
            type: entity.PageType.footer,
          ),
        );
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> deleteFooter(int pageId) async {
    final result = await ref.read(pageRepositoryProvider).delete(pageId);
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> addContainer(int pageId, int containerCount) async {
    final result = await ref
        .read(containerRepositoryProvider)
        .create(
          CreateContainerInput(
            pageId: pageId,
            index: containerCount,
            direction: 'portrait',
          ),
        );
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> addChildContainer(int parentContainerId, int childCount) async {
    // Find the pageId from the parent container
    final treeState = ref.read(editorTreeProvider(menuId));
    int? pageId;
    for (final entry in treeState.containers.entries) {
      for (final container in entry.value) {
        if (container.id == parentContainerId) {
          pageId = container.pageId;
          break;
        }
      }
      if (pageId != null) break;
    }
    // Also search in childContainers
    if (pageId == null) {
      for (final entry in treeState.childContainers.entries) {
        for (final container in entry.value) {
          if (container.id == parentContainerId) {
            pageId = container.pageId;
            break;
          }
        }
        if (pageId != null) break;
      }
    }
    if (pageId == null) return;

    final result = await ref
        .read(containerRepositoryProvider)
        .create(
          CreateContainerInput(
            pageId: pageId,
            index: childCount,
            direction: 'column',
            parentContainerId: parentContainerId,
          ),
        );
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> deleteContainer(int containerId) async {
    final result = await ref
        .read(containerRepositoryProvider)
        .delete(containerId);
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> addColumn(int containerId, int columnCount) async {
    final result = await ref
        .read(columnRepositoryProvider)
        .create(
          CreateColumnInput(
            containerId: containerId,
            index: columnCount,
            flex: 1,
          ),
        );
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> deleteColumn(int columnId) async {
    final result = await ref.read(columnRepositoryProvider).delete(columnId);
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  // Style management

  void onSidePanelStyleChanged(StyleConfig style, EditorSelection selection) {
    final treeNotifier = ref.read(editorTreeProvider(menuId).notifier);

    switch (selection.type) {
      case EditorElementType.menu:
        final currentMenu = ref.read(editorTreeProvider(menuId)).menu;
        if (currentMenu != null) {
          treeNotifier.updateMenuLocally(
            currentMenu.copyWith(styleConfig: style),
          );
        }
      case EditorElementType.container:
        treeNotifier.updateContainerStyleLocally(selection.id, style);
        _debounceStyleSave(() async {
          await ref
              .read(containerRepositoryProvider)
              .update(
                UpdateContainerInput(id: selection.id, styleConfig: style),
              );
        });
      case EditorElementType.column:
        treeNotifier.updateColumnStyleLocally(selection.id, style);
        _debounceStyleSave(() async {
          await ref
              .read(columnRepositoryProvider)
              .update(UpdateColumnInput(id: selection.id, styleConfig: style));
        });
    }
  }

  void _debounceStyleSave(Future<void> Function() apiCall) {
    _styleDebounceTimer?.cancel();
    _styleDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      apiCall();
    });
  }

  void updateContainerLayout(int containerId, LayoutConfig layout) {
    final treeNotifier = ref.read(editorTreeProvider(menuId).notifier);
    treeNotifier.updateContainerLayoutLocally(containerId, layout);
    _debounceStyleSave(() async {
      await ref
          .read(containerRepositoryProvider)
          .update(UpdateContainerInput(id: containerId, layout: layout));
    });
  }

  void flushStyleDebounce() {
    _styleDebounceTimer?.cancel();
    _styleDebounceTimer = null;
  }

  // Template operations

  Future<void> saveTemplate() async {
    state = state.copyWith(isSaving: true);
    final menu = ref.read(editorTreeProvider(menuId)).menu;
    await ref
        .read(menuRepositoryProvider)
        .update(UpdateMenuInput(id: menuId, styleConfig: menu?.styleConfig));
    state = state.copyWith(isSaving: false);
  }

  Future<void> publishTemplate() async {
    final result = await ref
        .read(menuRepositoryProvider)
        .update(UpdateMenuInput(id: menuId, status: Status.published));
    if (result.isSuccess) {
      await _reloadTree();
    }
  }

  Future<void> updateAllowedWidgetTypes(List<String> types) async {
    final result = await ref
        .read(menuRepositoryProvider)
        .update(UpdateMenuInput(id: menuId, allowedWidgetTypes: types));
    if (result.isSuccess) {
      final currentMenu = ref.read(editorTreeProvider(menuId)).menu;
      if (currentMenu != null) {
        ref
            .read(editorTreeProvider(menuId).notifier)
            .updateMenuLocally(currentMenu.copyWith(allowedWidgetTypes: types));
      }
    }
  }

  Future<void> updateColumnDroppable(int columnId, bool isDroppable) async {
    await ref
        .read(columnRepositoryProvider)
        .update(UpdateColumnInput(id: columnId, isDroppable: isDroppable));
    ref
        .read(editorTreeProvider(menuId).notifier)
        .updateColumnDroppableLocally(columnId, isDroppable);
  }

  Future<void> _reloadTree() async {
    await ref
        .read(editorTreeProvider(menuId).notifier)
        .loadTree(separateHeaderFooter: true);
  }
}
