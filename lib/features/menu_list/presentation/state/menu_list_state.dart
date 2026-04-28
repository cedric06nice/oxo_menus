import 'package:oxo_menus/features/menu/domain/entities/menu.dart';

/// Immutable state of the menu-list screen.
///
/// Defaults to "loading, no menus, all-statuses filter, not admin" — the
/// initial value owned by [MenuListViewModel] before the first load resolves.
final class MenuListState {
  const MenuListState({
    this.isLoading = true,
    this.errorMessage,
    this.menus = const <Menu>[],
    this.statusFilter = 'all',
    this.isAdmin = false,
  });

  /// True while a load (initial or refresh) is in flight.
  final bool isLoading;

  /// Last error message surfaced by a load/mutate operation; `null` when
  /// there is no current error.
  final String? errorMessage;

  /// Menus visible to the current viewer, ordered as returned by the
  /// repository (most-recent-first after a create or duplicate).
  final List<Menu> menus;

  /// One of `'all' | 'draft' | 'published' | 'archived'`. Drives the
  /// admin-only status filter bar; ignored for regular users.
  final String statusFilter;

  /// `true` when the viewer is an admin. Mirrors [AuthGateway]'s snapshot at
  /// VM construction.
  final bool isAdmin;

  MenuListState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    List<Menu>? menus,
    String? statusFilter,
    bool? isAdmin,
  }) {
    return MenuListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      menus: menus ?? this.menus,
      statusFilter: statusFilter ?? this.statusFilter,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is MenuListState &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage &&
      _listEquals(other.menus, menus) &&
      other.statusFilter == statusFilter &&
      other.isAdmin == isAdmin;

  @override
  int get hashCode => Object.hash(
    isLoading,
    errorMessage,
    Object.hashAll(menus),
    statusFilter,
    isAdmin,
  );

  static bool _listEquals(List<Menu> a, List<Menu> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
