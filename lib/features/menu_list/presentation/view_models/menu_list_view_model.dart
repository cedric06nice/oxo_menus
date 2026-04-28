import 'dart:async';

import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/create_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/delete_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/list_menus_for_viewer_use_case.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/state/menu_list_state.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// View model that owns the menu-list screen's state.
///
/// Listens to [ConnectivityGateway] to retry the load on offline → online
/// transitions. Knows nothing about widgets, `BuildContext`, or Riverpod —
/// the screen passes mutations through and the [MenuListRouter] owns
/// navigation.
class MenuListViewModel extends ViewModel<MenuListState> {
  MenuListViewModel({
    required ListMenusForViewerUseCase listMenusForViewer,
    required CreateMenuUseCase createMenu,
    required DeleteMenuUseCase deleteMenu,
    required DuplicateMenuUseCase duplicateMenu,
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    required MenuListRouter router,
  }) : _listMenusForViewer = listMenusForViewer,
       _createMenu = createMenu,
       _deleteMenu = deleteMenu,
       _duplicateMenu = duplicateMenu,
       _connectivityGateway = connectivityGateway,
       _router = router,
       _lastConnectivity = connectivityGateway.currentStatus,
       super(_initialStateFor(authGateway)) {
    _connectivitySubscription = _connectivityGateway.statusStream.listen(
      _onConnectivityChanged,
    );
    unawaited(_loadMenus());
  }

  final ListMenusForViewerUseCase _listMenusForViewer;
  final CreateMenuUseCase _createMenu;
  final DeleteMenuUseCase _deleteMenu;
  final DuplicateMenuUseCase _duplicateMenu;
  final ConnectivityGateway _connectivityGateway;
  final MenuListRouter _router;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _lastConnectivity;

  static MenuListState _initialStateFor(AuthGateway gateway) {
    final user = gateway.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    return MenuListState(isAdmin: isAdmin);
  }

  /// Re-runs the list use case (pull-to-refresh, retry after error).
  Future<void> refresh() => _loadMenus();

  /// Updates the admin-only status filter.
  void setStatusFilter(String filter) {
    if (state.statusFilter == filter) {
      return;
    }
    emit(state.copyWith(statusFilter: filter));
  }

  /// Creates a template; on success prepends it to the list and returns it.
  Future<Menu?> createTemplate(CreateMenuInput input) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _createMenu.execute(input);
    return result.fold(
      onSuccess: (menu) {
        emit(
          state.copyWith(
            isLoading: false,
            menus: [menu, ...state.menus],
            errorMessage: null,
          ),
        );
        return menu;
      },
      onFailure: (error) {
        emit(state.copyWith(isLoading: false, errorMessage: error.message));
        return null;
      },
    );
  }

  /// Deletes a menu; on success removes it from the list and returns `true`.
  Future<bool> deleteMenu(int menuId) async {
    final result = await _deleteMenu.execute(menuId);
    return result.fold(
      onSuccess: (_) {
        emit(
          state.copyWith(
            menus: state.menus.where((m) => m.id != menuId).toList(),
            errorMessage: null,
          ),
        );
        return true;
      },
      onFailure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return false;
      },
    );
  }

  /// Duplicates a menu; on success prepends the copy and returns it.
  Future<Menu?> duplicateMenu(int menuId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _duplicateMenu.execute(menuId);
    return result.fold(
      onSuccess: (menu) {
        emit(
          state.copyWith(
            isLoading: false,
            menus: [menu, ...state.menus],
            errorMessage: null,
          ),
        );
        return menu;
      },
      onFailure: (error) {
        emit(state.copyWith(isLoading: false, errorMessage: error.message));
        return null;
      },
    );
  }

  void openMenu(int menuId) => _router.goToMenuEditor(menuId);

  void openTemplateEditor(int menuId) =>
      _router.goToAdminTemplateEditor(menuId);

  /// Push the admin Sizes screen on top of the menu-list stack so the user
  /// can return with back navigation. Used by the template-create dialog
  /// when no sizes exist yet.
  void pushAdminSizes() => _router.pushAdminSizes();

  void goBack() => _router.goBack();

  Future<void> _loadMenus() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _listMenusForViewer.execute(NoInput.instance);
    if (isDisposed) {
      return;
    }
    result.fold(
      onSuccess: (menus) {
        emit(
          state.copyWith(isLoading: false, menus: menus, errorMessage: null),
        );
      },
      onFailure: (error) {
        emit(state.copyWith(isLoading: false, errorMessage: error.message));
      },
    );
  }

  void _onConnectivityChanged(ConnectivityStatus next) {
    if (isDisposed) {
      return;
    }
    final wasOffline = _lastConnectivity == ConnectivityStatus.offline;
    _lastConnectivity = next;
    if (wasOffline && next == ConnectivityStatus.online) {
      unawaited(_loadMenus());
    }
  }

  @override
  void onDispose() {
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }
}
