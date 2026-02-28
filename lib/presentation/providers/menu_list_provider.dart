import 'package:flutter_riverpod/legacy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

part 'menu_list_provider.freezed.dart';

/// Menu list state
///
/// Represents the state of the menu list screen
@freezed
abstract class MenuListState with _$MenuListState {
  const factory MenuListState({
    @Default([]) List<Menu> menus,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _MenuListState;
}

/// Menu list state notifier
///
/// Manages the menu list state and provides methods for loading and deleting menus
class MenuListNotifier extends StateNotifier<MenuListState> {
  final MenuRepository _menuRepository;
  final DuplicateMenuUseCase? _duplicateMenuUseCase;

  MenuListNotifier(
    this._menuRepository, {
    DuplicateMenuUseCase? duplicateMenuUseCase,
  }) : _duplicateMenuUseCase = duplicateMenuUseCase,
       super(const MenuListState());

  /// Load all menus
  ///
  /// If [onlyPublished] is true, only published menus will be loaded.
  /// This should be true for regular users and false for admins.
  /// If [areaIds] is provided, only menus in those areas will be returned
  /// (filtered server-side by Directus).
  Future<void> loadMenus({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _menuRepository.listAll(
      onlyPublished: onlyPublished,
      areaIds: areaIds,
    );

    result.fold(
      onSuccess: (menus) {
        state = state.copyWith(menus: menus, isLoading: false);
      },
      onFailure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  /// Delete a menu by ID
  ///
  /// Removes the menu from both the backend and the local state
  Future<void> deleteMenu(int menuId) async {
    final result = await _menuRepository.delete(menuId);

    result.fold(
      onSuccess: (_) {
        // Remove from local state
        state = state.copyWith(
          menus: state.menus.where((m) => m.id != menuId).toList(),
        );
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }

  /// Refresh the menu list
  ///
  /// Reloads the menus with the same filter as before
  Future<void> refresh({bool onlyPublished = true, List<int>? areaIds}) async {
    await loadMenus(onlyPublished: onlyPublished, areaIds: areaIds);
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Create a new menu/template
  ///
  /// Creates a new menu with the given input and adds it to the local state.
  /// Returns the created menu on success, or null on failure.
  Future<Menu?> createMenu(CreateMenuInput input) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _menuRepository.create(input);

    return result.fold(
      onSuccess: (menu) {
        state = state.copyWith(menus: [menu, ...state.menus], isLoading: false);
        return menu;
      },
      onFailure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        return null;
      },
    );
  }

  /// Duplicate a menu
  ///
  /// Duplicates a menu with all its pages, containers, columns, and widgets.
  /// Returns the duplicated menu on success, or null on failure.
  Future<Menu?> duplicateMenu(int menuId) async {
    if (_duplicateMenuUseCase == null) {
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _duplicateMenuUseCase.execute(menuId);

    return result.fold(
      onSuccess: (menu) {
        state = state.copyWith(menus: [menu, ...state.menus], isLoading: false);
        return menu;
      },
      onFailure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        return null;
      },
    );
  }
}

/// Menu list state provider
///
/// Provides the menu list state and methods for managing menus
///
/// Example usage:
/// ```dart
/// final menuListState = ref.watch(menuListProvider);
///
/// if (menuListState.isLoading) {
///   return CircularProgressIndicator();
/// }
///
/// if (menuListState.errorMessage != null) {
///   return Text('Error: ${menuListState.errorMessage}');
/// }
///
/// return ListView.builder(
///   itemCount: menuListState.menus.length,
///   itemBuilder: (context, index) {
///     final menu = menuListState.menus[index];
///     return MenuListTile(menu: menu);
///   },
/// );
/// ```
final menuListProvider = StateNotifierProvider<MenuListNotifier, MenuListState>(
  (ref) {
    final menuRepository = ref.watch(menuRepositoryProvider);
    final duplicateMenuUseCase = ref.watch(duplicateMenuUseCaseProvider);
    return MenuListNotifier(
      menuRepository,
      duplicateMenuUseCase: duplicateMenuUseCase,
    );
  },
);
