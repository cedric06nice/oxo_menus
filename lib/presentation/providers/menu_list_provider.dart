import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

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
abstract class MenuListNotifier extends StateNotifier<MenuListState> {
  final MenuRepository _menuRepository;

  MenuListNotifier(this._menuRepository) : super(const MenuListState());

  /// Load all menus
  ///
  /// If [onlyPublished] is true, only published menus will be loaded.
  /// This should be true for regular users and false for admins.
  Future<void> loadMenus({bool onlyPublished = true}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _menuRepository.listAll(onlyPublished: onlyPublished);

    result.fold(
      onSuccess: (menus) {
        state = state.copyWith(
          menus: menus,
          isLoading: false,
        );
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }

  /// Delete a menu by ID
  ///
  /// Removes the menu from both the backend and the local state
  Future<void> deleteMenu(String menuId) async {
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
  Future<void> refresh({bool onlyPublished = true}) async {
    await loadMenus(onlyPublished: onlyPublished);
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
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
final menuListProvider =
    StateNotifierProvider<MenuListNotifier, MenuListState>((ref) {
  final menuRepository = ref.watch(menuRepositoryProvider);
  return MenuListNotifier(menuRepository);
});
