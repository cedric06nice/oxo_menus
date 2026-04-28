import 'dart:async';

import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_page_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_page_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/duplicate_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_areas_for_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_sizes_for_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/load_template_for_editor_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/move_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/reorder_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_template_menu_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_router.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/admin_template_editor_screen_state.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/editor_selection.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/editor_tree_data.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Default debounce delay for side-panel style writes. Mirrors the legacy
/// `template_editor_notifier` behaviour so user-perceived latency is identical.
const _kStyleDebounceDelay = Duration(milliseconds: 500);

/// View model owning the migrated admin template editor state.
///
/// Pulls the tree on construction (admin only), exposes every CRUD action the
/// legacy `template_editor_notifier` + `editor_tree_notifier` +
/// `editor_selection_notifier` triplet covered, and runs a 500 ms debounce
/// timer for side-panel style writes. Connectivity-restore replays the load
/// only when the previous load surfaced an error so steady-state edits don't
/// bounce the screen back into a spinner.
///
/// Knows nothing about widgets, `BuildContext`, or Riverpod — navigation is
/// delegated to [AdminTemplateEditorRouter].
class AdminTemplateEditorViewModel
    extends ViewModel<AdminTemplateEditorScreenState> {
  AdminTemplateEditorViewModel({
    required int menuId,
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    required AdminTemplateEditorRouter router,
    required PresentableWidgetRegistry registry,
    required LoadTemplateForEditorUseCase loadTemplate,
    required CreatePageInTemplateUseCase createPage,
    required DeletePageInTemplateUseCase deletePage,
    required CreateContainerInTemplateUseCase createContainer,
    required UpdateContainerInTemplateUseCase updateContainer,
    required DeleteContainerInTemplateUseCase deleteContainer,
    required ReorderContainerInTemplateUseCase reorderContainer,
    required DuplicateContainerInTemplateUseCase duplicateContainer,
    required CreateColumnInTemplateUseCase createColumn,
    required UpdateColumnInTemplateUseCase updateColumn,
    required DeleteColumnInTemplateUseCase deleteColumn,
    required CreateWidgetInTemplateUseCase createWidget,
    required UpdateWidgetInTemplateUseCase updateWidget,
    required DeleteWidgetInTemplateUseCase deleteWidget,
    required MoveWidgetInTemplateUseCase moveWidget,
    required UpdateTemplateMenuUseCase updateMenu,
    required ListAreasForTemplateUseCase listAreas,
    required ListSizesForTemplateUseCase listSizes,
    ImageGateway? imageGateway,
  }) : _menuId = menuId,
       _connectivityGateway = connectivityGateway,
       _router = router,
       _registry = registry,
       _imageGateway = imageGateway,
       _loadTemplate = loadTemplate,
       _createPage = createPage,
       _deletePage = deletePage,
       _createContainer = createContainer,
       _updateContainer = updateContainer,
       _deleteContainer = deleteContainer,
       _reorderContainer = reorderContainer,
       _duplicateContainer = duplicateContainer,
       _createColumn = createColumn,
       _updateColumn = updateColumn,
       _deleteColumn = deleteColumn,
       _createWidget = createWidget,
       _updateWidget = updateWidget,
       _deleteWidget = deleteWidget,
       _moveWidget = moveWidget,
       _updateMenu = updateMenu,
       _listAreas = listAreas,
       _listSizes = listSizes,
       _lastConnectivity = connectivityGateway.currentStatus,
       super(_initialStateFor(authGateway)) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
    unawaited(_load());
  }

  final int _menuId;
  final ConnectivityGateway _connectivityGateway;
  final AdminTemplateEditorRouter _router;
  final PresentableWidgetRegistry _registry;
  final ImageGateway? _imageGateway;

  /// Registry the screen passes to `WidgetRenderer`/`DraggableWidgetItem` so
  /// they can look up widget definitions without reaching into Riverpod.
  PresentableWidgetRegistry get registry => _registry;

  /// Gateway used by the `image` widget type for byte loading. Optional.
  ImageGateway? get imageGateway => _imageGateway;

  final LoadTemplateForEditorUseCase _loadTemplate;
  final CreatePageInTemplateUseCase _createPage;
  final DeletePageInTemplateUseCase _deletePage;
  final CreateContainerInTemplateUseCase _createContainer;
  final UpdateContainerInTemplateUseCase _updateContainer;
  final DeleteContainerInTemplateUseCase _deleteContainer;
  final ReorderContainerInTemplateUseCase _reorderContainer;
  final DuplicateContainerInTemplateUseCase _duplicateContainer;
  final CreateColumnInTemplateUseCase _createColumn;
  final UpdateColumnInTemplateUseCase _updateColumn;
  final DeleteColumnInTemplateUseCase _deleteColumn;
  final CreateWidgetInTemplateUseCase _createWidget;
  final UpdateWidgetInTemplateUseCase _updateWidget;
  final DeleteWidgetInTemplateUseCase _deleteWidget;
  final MoveWidgetInTemplateUseCase _moveWidget;
  final UpdateTemplateMenuUseCase _updateMenu;
  final ListAreasForTemplateUseCase _listAreas;
  final ListSizesForTemplateUseCase _listSizes;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _lastConnectivity;
  Timer? _styleDebounceTimer;
  Future<void> Function()? _pendingStyleWrite;

  static AdminTemplateEditorScreenState _initialStateFor(AuthGateway gateway) {
    final user = gateway.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    return AdminTemplateEditorScreenState(isAdmin: isAdmin);
  }

  /// Reload the editor tree. Used by the retry button and by the
  /// connectivity-restore listener.
  Future<void> reload() => _load();

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    emit(state.copyWith(errorMessage: null));
  }

  // ----------------------------------------------------------- Selection

  void selectMenu() {
    flushStyleDebounce();
    final menu = state.tree?.menu;
    final style = menu?.styleConfig;
    emit(
      state.copyWith(
        selection: const EditorSelection.menu(),
        currentStyle: style,
        originalStyle: style,
      ),
    );
  }

  void selectContainer(int containerId) {
    flushStyleDebounce();
    final style = _findContainerStyle(containerId);
    emit(
      state.copyWith(
        selection: EditorSelection.container(containerId),
        currentStyle: style,
        originalStyle: style,
      ),
    );
  }

  void selectColumn(int columnId) {
    flushStyleDebounce();
    final style = _findColumnStyle(columnId);
    emit(
      state.copyWith(
        selection: EditorSelection.column(columnId),
        currentStyle: style,
        originalStyle: style,
      ),
    );
  }

  void deselect() {
    flushStyleDebounce();
    emit(
      state.copyWith(selection: null, currentStyle: null, originalStyle: null),
    );
  }

  void copyStyle() {
    if (state.selection == null) {
      return;
    }
    emit(state.copyWith(clipboardStyle: state.currentStyle));
  }

  /// Returns the clipboard style; the caller is responsible for forwarding it
  /// through [updateSelectedStyle] if a paste is desired. The legacy notifier
  /// did the same so the screen can decide whether the paste should debounce.
  StyleConfig? pasteStyle() => state.clipboardStyle;

  /// Updates the currently selected element's style. The local tree reflects
  /// the change immediately; persistence is debounced by 500 ms so rapid drag
  /// adjustments don't flood the API.
  void updateSelectedStyle(StyleConfig style) {
    final selection = state.selection;
    if (selection == null) {
      return;
    }
    final tree = state.tree;
    AdminTemplateEditorScreenState next = state.copyWith(currentStyle: style);
    if (tree != null) {
      switch (selection.type) {
        case EditorElementType.menu:
          final menu = tree.menu;
          next = next.copyWith(
            tree: _withMenu(tree, menu.copyWith(styleConfig: style)),
          );
        case EditorElementType.container:
          next = next.copyWith(
            tree: _withContainerStyle(tree, selection.id, style),
          );
        case EditorElementType.column:
          next = next.copyWith(
            tree: _withColumnStyle(tree, selection.id, style),
          );
      }
    }
    emit(next);
    _scheduleStyleWrite(selection, style);
  }

  /// Cancels any pending debounced style write. Called when the user
  /// deselects or when an explicit Save is issued.
  void flushStyleDebounce() {
    _styleDebounceTimer?.cancel();
    _styleDebounceTimer = null;
    _pendingStyleWrite = null;
  }

  // ----------------------------------------------------------- Page CRUD

  Future<void> addPage() => _runAndReload(() async {
    final tree = state.tree;
    final index = tree?.pages.length ?? 0;
    return _createPage.execute(
      CreatePageInput(menuId: _menuId, name: 'Page ${index + 1}', index: index),
    );
  });

  Future<void> addHeader() => _runAndReload(
    () => _createPage.execute(
      CreatePageInput(
        menuId: _menuId,
        name: 'Header',
        index: 0,
        type: entity.PageType.header,
      ),
    ),
  );

  Future<void> addFooter() => _runAndReload(
    () => _createPage.execute(
      CreatePageInput(
        menuId: _menuId,
        name: 'Footer',
        index: 0,
        type: entity.PageType.footer,
      ),
    ),
  );

  Future<void> deletePage(int pageId) =>
      _runAndReload(() => _deletePage.execute(pageId));

  // ----------------------------------------------------------- Container CRUD

  Future<void> addContainer(int pageId) => _runAndReload(() async {
    final containers = state.tree?.containers[pageId] ?? const [];
    return _createContainer.execute(
      CreateContainerInput(
        pageId: pageId,
        index: containers.length,
        direction: 'portrait',
      ),
    );
  });

  Future<void> addChildContainer(int parentContainerId) =>
      _runAndReload(() async {
        final tree = state.tree;
        if (tree == null) {
          return const Failure<entity.Container, DomainError>(
            ValidationError('Tree not loaded'),
          );
        }
        final parent = _findContainer(tree, parentContainerId);
        if (parent == null) {
          return const Failure<entity.Container, DomainError>(
            NotFoundError('Parent container not found'),
          );
        }
        final children = tree.childContainers[parentContainerId] ?? const [];
        return _createContainer.execute(
          CreateContainerInput(
            pageId: parent.pageId,
            index: children.length,
            direction: 'column',
            parentContainerId: parentContainerId,
          ),
        );
      });

  Future<void> deleteContainer(int containerId) =>
      _runAndReload(() => _deleteContainer.execute(containerId));

  Future<void> reorderContainer(int containerId, ReorderDirection direction) =>
      _runAndReload(
        () => _reorderContainer.execute(
          ReorderContainerInput(containerId: containerId, direction: direction),
        ),
      );

  Future<void> duplicateContainer(int containerId) =>
      _runAndReload(() => _duplicateContainer.execute(containerId));

  /// Update a container's layout (direction, alignment) — local-first with
  /// debounced persistence so the same drag gesture that drives style edits
  /// can also drive layout edits without flooding the API.
  void updateContainerLayout(int containerId, entity.LayoutConfig layout) {
    final tree = state.tree;
    if (tree == null) {
      return;
    }
    emit(state.copyWith(tree: _withContainerLayout(tree, containerId, layout)));
    _styleDebounceTimer?.cancel();
    _pendingStyleWrite = () async {
      await _updateContainer.execute(
        UpdateContainerInput(id: containerId, layout: layout),
      );
    };
    _styleDebounceTimer = Timer(_kStyleDebounceDelay, _flushStyleWrite);
  }

  // ----------------------------------------------------------- Column CRUD

  Future<void> addColumn(int containerId) => _runAndReload(() async {
    final columns = state.tree?.columns[containerId] ?? const [];
    return _createColumn.execute(
      CreateColumnInput(
        containerId: containerId,
        index: columns.length,
        flex: 1,
      ),
    );
  });

  Future<void> deleteColumn(int columnId) =>
      _runAndReload(() => _deleteColumn.execute(columnId));

  Future<void> updateColumnDroppable(int columnId, bool isDroppable) async {
    final tree = state.tree;
    if (tree != null) {
      emit(
        state.copyWith(tree: _withColumnDroppable(tree, columnId, isDroppable)),
      );
    }
    final result = await _updateColumn.execute(
      UpdateColumnInput(id: columnId, isDroppable: isDroppable),
    );
    if (isDisposed) {
      return;
    }
    if (result.isFailure) {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
  }

  // ----------------------------------------------------------- Widget CRUD

  Future<Result<WidgetInstance, DomainError>> createWidget({
    required String type,
    required String version,
    required Map<String, dynamic> defaultProps,
    required int columnId,
    required int index,
  }) async {
    final result = await _createWidget.execute(
      CreateWidgetInput(
        columnId: columnId,
        type: type,
        version: version,
        index: index,
        props: defaultProps,
        isTemplate: true,
      ),
    );
    if (isDisposed) {
      return result;
    }
    if (result.isSuccess) {
      await _load(showSpinner: false);
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  Future<Result<WidgetInstance, DomainError>> updateWidgetProps(
    int widgetId,
    Map<String, dynamic> props,
  ) async {
    final result = await _updateWidget.execute(
      UpdateWidgetInput(id: widgetId, props: props),
    );
    if (isDisposed) {
      return result;
    }
    if (result.isSuccess) {
      await _load(showSpinner: false);
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  Future<Result<WidgetInstance, DomainError>> updateWidgetLockForEdition(
    int widgetId,
    bool locked,
  ) async {
    final result = await _updateWidget.execute(
      UpdateWidgetInput(id: widgetId, lockedForEdition: locked),
    );
    if (isDisposed) {
      return result;
    }
    if (result.isSuccess) {
      final tree = state.tree;
      if (tree != null) {
        emit(state.copyWith(tree: _withWidgetLock(tree, widgetId, locked)));
      }
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  Future<Result<void, DomainError>> deleteWidget(int widgetId) async {
    final tree = state.tree;
    if (tree != null) {
      emit(state.copyWith(tree: _withoutWidget(tree, widgetId)));
    }
    final result = await _deleteWidget.execute(widgetId);
    if (isDisposed) {
      return result;
    }
    await _load(showSpinner: false);
    if (result.isFailure) {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  Future<Result<void, DomainError>> moveWidget({
    required WidgetInstance widget,
    required int sourceColumnId,
    required int targetColumnId,
    required int targetIndex,
  }) async {
    final result = await _moveWidget.execute(
      MoveWidgetInput(
        widget: widget,
        sourceColumnId: sourceColumnId,
        targetColumnId: targetColumnId,
        targetIndex: targetIndex,
      ),
    );
    if (isDisposed) {
      return result;
    }
    if (result.isSuccess) {
      await _load(showSpinner: false);
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
    return result;
  }

  // ----------------------------------------------------------- Menu-level

  Future<void> updateAllowedWidgets(List<WidgetTypeConfig> configs) async {
    final tree = state.tree;
    if (tree == null) {
      return;
    }
    final previous = tree.menu.allowedWidgets;
    emit(
      state.copyWith(
        tree: _withMenu(tree, tree.menu.copyWith(allowedWidgets: configs)),
      ),
    );
    final result = await _updateMenu.execute(
      UpdateMenuInput(id: _menuId, allowedWidgets: configs),
    );
    if (isDisposed) {
      return;
    }
    if (result.isFailure) {
      final latest = state.tree;
      if (latest != null) {
        emit(
          state.copyWith(
            tree: _withMenu(
              latest,
              latest.menu.copyWith(allowedWidgets: previous),
            ),
            errorMessage: result.errorOrNull!.message,
          ),
        );
      } else {
        emit(state.copyWith(errorMessage: result.errorOrNull!.message));
      }
    }
  }

  Future<void> updateDisplayOptions(MenuDisplayOptions options) async {
    final result = await _updateMenu.execute(
      UpdateMenuInput(id: _menuId, displayOptions: options),
    );
    if (isDisposed) {
      return;
    }
    if (result.isSuccess) {
      final tree = state.tree;
      if (tree != null) {
        emit(
          state.copyWith(
            tree: _withMenu(tree, tree.menu.copyWith(displayOptions: options)),
          ),
        );
      }
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
  }

  Future<void> updatePageSize(int sizeId, PageSize pageSize) async {
    final result = await _updateMenu.execute(
      UpdateMenuInput(id: _menuId, sizeId: sizeId),
    );
    if (isDisposed) {
      return;
    }
    if (result.isSuccess) {
      final tree = state.tree;
      if (tree != null) {
        emit(
          state.copyWith(
            tree: _withMenu(tree, tree.menu.copyWith(pageSize: pageSize)),
          ),
        );
      }
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
  }

  Future<void> updateArea(Area? area) async {
    final result = await _updateMenu.execute(
      UpdateMenuInput(id: _menuId, areaId: area?.id),
    );
    if (isDisposed) {
      return;
    }
    if (result.isSuccess) {
      final tree = state.tree;
      if (tree != null) {
        emit(
          state.copyWith(tree: _withMenu(tree, tree.menu.copyWith(area: area))),
        );
      }
    } else {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
    }
  }

  Future<void> saveTemplate() async {
    flushStyleDebounce();
    emit(state.copyWith(savingState: TemplateSavingState.saving));
    final tree = state.tree;
    final styleConfig = tree?.menu.styleConfig;
    final result = await _updateMenu.execute(
      UpdateMenuInput(id: _menuId, styleConfig: styleConfig),
    );
    if (isDisposed) {
      return;
    }
    if (result.isFailure) {
      emit(
        state.copyWith(
          savingState: TemplateSavingState.idle,
          errorMessage: result.errorOrNull!.message,
        ),
      );
      return;
    }
    emit(state.copyWith(savingState: TemplateSavingState.idle));
  }

  Future<void> publishTemplate() async {
    emit(state.copyWith(savingState: TemplateSavingState.publishing));
    final result = await _updateMenu.execute(
      UpdateMenuInput(id: _menuId, status: Status.published),
    );
    if (isDisposed) {
      return;
    }
    if (result.isFailure) {
      emit(
        state.copyWith(
          savingState: TemplateSavingState.idle,
          errorMessage: result.errorOrNull!.message,
        ),
      );
      return;
    }
    emit(state.copyWith(savingState: TemplateSavingState.idle));
    await _load(showSpinner: false);
  }

  Future<Result<List<Area>, DomainError>> loadAreas() =>
      _listAreas.execute(NoInput.instance);

  Future<Result<List<domain.Size>, DomainError>> loadSizes() =>
      _listSizes.execute(NoInput.instance);

  // ----------------------------------------------------------- Navigation

  void goBack() => _router.goBack();
  void goToAdminSizes() => _router.goToAdminSizes();
  void goToPdfPreview() => _router.goToPdfPreview(_menuId);

  @override
  void onDispose() {
    _styleDebounceTimer?.cancel();
    _styleDebounceTimer = null;
    _pendingStyleWrite = null;
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }

  // ----------------------------------------------------------- Internals

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    final result = await _loadTemplate.execute(_menuId);
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (tree) {
        emit(state.copyWith(isLoading: false, tree: tree, errorMessage: null));
      },
      onFailure: (error) {
        emit(state.copyWith(isLoading: false, errorMessage: error.message));
      },
    );
  }

  Future<void> _runAndReload(
    Future<Result<dynamic, DomainError>> Function() action,
  ) async {
    final result = await action();
    if (isDisposed) {
      return;
    }
    if (result.isFailure) {
      emit(state.copyWith(errorMessage: result.errorOrNull!.message));
      return;
    }
    await _load(showSpinner: false);
  }

  void _onConnectivityChanged(ConnectivityStatus next) {
    if (isDisposed) {
      return;
    }
    final wasOffline = _lastConnectivity == ConnectivityStatus.offline;
    _lastConnectivity = next;
    if (wasOffline &&
        next == ConnectivityStatus.online &&
        state.errorMessage != null) {
      unawaited(_load(showSpinner: false));
    }
  }

  void _scheduleStyleWrite(EditorSelection selection, StyleConfig style) {
    _styleDebounceTimer?.cancel();
    if (selection.type == EditorElementType.menu) {
      // Menu-level styles are committed by the explicit Save button, never by
      // the debounce. Mirrors the legacy behaviour so an admin can iterate on
      // the menu style without auto-publishing it.
      _pendingStyleWrite = null;
      return;
    }
    _pendingStyleWrite = () async {
      switch (selection.type) {
        case EditorElementType.container:
          await _updateContainer.execute(
            UpdateContainerInput(id: selection.id, styleConfig: style),
          );
        case EditorElementType.column:
          await _updateColumn.execute(
            UpdateColumnInput(id: selection.id, styleConfig: style),
          );
        case EditorElementType.menu:
          // unreachable — handled above
          break;
      }
    };
    _styleDebounceTimer = Timer(_kStyleDebounceDelay, _flushStyleWrite);
  }

  void _flushStyleWrite() {
    final pending = _pendingStyleWrite;
    _pendingStyleWrite = null;
    _styleDebounceTimer = null;
    if (pending == null) {
      return;
    }
    unawaited(pending());
  }

  // -------------------------- tree helpers (immutable updates) ----------

  EditorTreeData _withMenu(EditorTreeData tree, Menu menu) => EditorTreeData(
    menu: menu,
    pages: tree.pages,
    headerPage: tree.headerPage,
    footerPage: tree.footerPage,
    containers: tree.containers,
    childContainers: tree.childContainers,
    columns: tree.columns,
    widgets: tree.widgets,
  );

  EditorTreeData _withContainerStyle(
    EditorTreeData tree,
    int id,
    StyleConfig style,
  ) => EditorTreeData(
    menu: tree.menu,
    pages: tree.pages,
    headerPage: tree.headerPage,
    footerPage: tree.footerPage,
    containers: _mapContainers(
      tree.containers,
      id,
      (c) => c.copyWith(styleConfig: style),
    ),
    childContainers: _mapContainers(
      tree.childContainers,
      id,
      (c) => c.copyWith(styleConfig: style),
    ),
    columns: tree.columns,
    widgets: tree.widgets,
  );

  EditorTreeData _withContainerLayout(
    EditorTreeData tree,
    int id,
    entity.LayoutConfig layout,
  ) => EditorTreeData(
    menu: tree.menu,
    pages: tree.pages,
    headerPage: tree.headerPage,
    footerPage: tree.footerPage,
    containers: _mapContainers(
      tree.containers,
      id,
      (c) => c.copyWith(layout: layout),
    ),
    childContainers: _mapContainers(
      tree.childContainers,
      id,
      (c) => c.copyWith(layout: layout),
    ),
    columns: tree.columns,
    widgets: tree.widgets,
  );

  EditorTreeData _withColumnStyle(
    EditorTreeData tree,
    int id,
    StyleConfig style,
  ) => EditorTreeData(
    menu: tree.menu,
    pages: tree.pages,
    headerPage: tree.headerPage,
    footerPage: tree.footerPage,
    containers: tree.containers,
    childContainers: tree.childContainers,
    columns: _mapColumns(
      tree.columns,
      id,
      (c) => c.copyWith(styleConfig: style),
    ),
    widgets: tree.widgets,
  );

  EditorTreeData _withColumnDroppable(
    EditorTreeData tree,
    int id,
    bool droppable,
  ) => EditorTreeData(
    menu: tree.menu,
    pages: tree.pages,
    headerPage: tree.headerPage,
    footerPage: tree.footerPage,
    containers: tree.containers,
    childContainers: tree.childContainers,
    columns: _mapColumns(
      tree.columns,
      id,
      (c) => c.copyWith(isDroppable: droppable),
    ),
    widgets: tree.widgets,
  );

  EditorTreeData _withWidgetLock(EditorTreeData tree, int id, bool locked) =>
      EditorTreeData(
        menu: tree.menu,
        pages: tree.pages,
        headerPage: tree.headerPage,
        footerPage: tree.footerPage,
        containers: tree.containers,
        childContainers: tree.childContainers,
        columns: tree.columns,
        widgets: _mapWidgets(
          tree.widgets,
          id,
          (w) => w.copyWith(lockedForEdition: locked),
        ),
      );

  EditorTreeData _withoutWidget(EditorTreeData tree, int id) {
    final updated = <int, List<WidgetInstance>>{};
    for (final entry in tree.widgets.entries) {
      updated[entry.key] = entry.value.where((w) => w.id != id).toList();
    }
    return EditorTreeData(
      menu: tree.menu,
      pages: tree.pages,
      headerPage: tree.headerPage,
      footerPage: tree.footerPage,
      containers: tree.containers,
      childContainers: tree.childContainers,
      columns: tree.columns,
      widgets: updated,
    );
  }

  Map<int, List<entity.Container>> _mapContainers(
    Map<int, List<entity.Container>> source,
    int id,
    entity.Container Function(entity.Container) transform,
  ) {
    final out = <int, List<entity.Container>>{};
    for (final entry in source.entries) {
      out[entry.key] = entry.value
          .map((c) => c.id == id ? transform(c) : c)
          .toList();
    }
    return out;
  }

  Map<int, List<entity.Column>> _mapColumns(
    Map<int, List<entity.Column>> source,
    int id,
    entity.Column Function(entity.Column) transform,
  ) {
    final out = <int, List<entity.Column>>{};
    for (final entry in source.entries) {
      out[entry.key] = entry.value
          .map((c) => c.id == id ? transform(c) : c)
          .toList();
    }
    return out;
  }

  Map<int, List<WidgetInstance>> _mapWidgets(
    Map<int, List<WidgetInstance>> source,
    int id,
    WidgetInstance Function(WidgetInstance) transform,
  ) {
    final out = <int, List<WidgetInstance>>{};
    for (final entry in source.entries) {
      out[entry.key] = entry.value
          .map((w) => w.id == id ? transform(w) : w)
          .toList();
    }
    return out;
  }

  StyleConfig? _findContainerStyle(int id) {
    final tree = state.tree;
    if (tree == null) {
      return null;
    }
    for (final list in tree.containers.values) {
      for (final c in list) {
        if (c.id == id) return c.styleConfig;
      }
    }
    for (final list in tree.childContainers.values) {
      for (final c in list) {
        if (c.id == id) return c.styleConfig;
      }
    }
    return null;
  }

  StyleConfig? _findColumnStyle(int id) {
    final tree = state.tree;
    if (tree == null) {
      return null;
    }
    for (final list in tree.columns.values) {
      for (final c in list) {
        if (c.id == id) return c.styleConfig;
      }
    }
    return null;
  }

  entity.Container? _findContainer(EditorTreeData tree, int id) {
    for (final list in tree.containers.values) {
      for (final c in list) {
        if (c.id == id) return c;
      }
    }
    for (final list in tree.childContainers.values) {
      for (final c in list) {
        if (c.id == id) return c;
      }
    }
    return null;
  }
}
