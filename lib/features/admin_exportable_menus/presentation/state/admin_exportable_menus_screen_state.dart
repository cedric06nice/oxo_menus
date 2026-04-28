import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';

/// Immutable state of the migrated admin-exportable-menus screen.
///
/// Captures the bundle list and the available-menu lookup used by the
/// create/edit dialog, the loading and error flags, and the set of bundle ids
/// currently being (re)published. The publish set drives per-row spinner
/// affordances; each entry is removed when the publish call completes.
final class AdminExportableMenusScreenState {
  const AdminExportableMenusScreenState({
    this.isAdmin = false,
    this.isLoading = true,
    this.errorMessage,
    this.bundles = const <MenuBundle>[],
    this.availableMenus = const <Menu>[],
    this.publishingBundleIds = const <int>{},
  });

  /// `true` when the viewer is an admin. Mirrors [AuthGateway]'s snapshot at
  /// VM construction time.
  final bool isAdmin;

  /// True while the initial load (or a connectivity-driven reload) is in
  /// flight.
  final bool isLoading;

  /// Last error message surfaced by a load, CRUD, or publish failure;
  /// `null` when there is no current error.
  final String? errorMessage;

  /// Bundles known to the screen, in the order returned by the repository.
  final List<MenuBundle> bundles;

  /// Menus the create/edit dialog can pick from. Includes drafts because
  /// bundles compose menus regardless of status.
  final List<Menu> availableMenus;

  /// Bundle ids currently being (re)published. Each entry is removed when the
  /// publish call completes.
  final Set<int> publishingBundleIds;

  AdminExportableMenusScreenState copyWith({
    bool? isAdmin,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    List<MenuBundle>? bundles,
    List<Menu>? availableMenus,
    Set<int>? publishingBundleIds,
  }) {
    return AdminExportableMenusScreenState(
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      bundles: bundles ?? this.bundles,
      availableMenus: availableMenus ?? this.availableMenus,
      publishingBundleIds: publishingBundleIds ?? this.publishingBundleIds,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is AdminExportableMenusScreenState &&
      other.isAdmin == isAdmin &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage &&
      _listEquals(other.bundles, bundles) &&
      _listEquals(other.availableMenus, availableMenus) &&
      _setEquals(other.publishingBundleIds, publishingBundleIds);

  @override
  int get hashCode => Object.hash(
    isAdmin,
    isLoading,
    errorMessage,
    Object.hashAll(bundles),
    Object.hashAll(availableMenus),
    Object.hashAllUnordered(publishingBundleIds),
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
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

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (final element in a) {
      if (!b.contains(element)) {
        return false;
      }
    }
    return true;
  }
}
