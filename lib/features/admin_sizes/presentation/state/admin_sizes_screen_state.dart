import 'package:oxo_menus/features/menu/domain/entities/size.dart';

/// Immutable state of the migrated admin-sizes screen.
///
/// Defaults match the "loading, no sizes, all-statuses filter, not admin"
/// snapshot owned by [AdminSizesViewModel] before the first load resolves.
final class AdminSizesScreenState {
  const AdminSizesScreenState({
    this.isLoading = true,
    this.errorMessage,
    this.sizes = const <Size>[],
    this.statusFilter = 'all',
    this.isAdmin = false,
  });

  /// True while a load (initial, refresh, or status-filter-driven reload) is
  /// in flight.
  final bool isLoading;

  /// Last error message surfaced by a load/mutate operation; `null` when there
  /// is no current error.
  final String? errorMessage;

  /// Sizes visible to the admin viewer, ordered as returned by the
  /// repository.
  final List<Size> sizes;

  /// One of `'all' | 'draft' | 'published' | 'archived'`. Drives the status
  /// filter bar.
  final String statusFilter;

  /// `true` when the viewer is an admin. Mirrors [AuthGateway]'s snapshot at
  /// VM construction time.
  final bool isAdmin;

  AdminSizesScreenState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    List<Size>? sizes,
    String? statusFilter,
    bool? isAdmin,
  }) {
    return AdminSizesScreenState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      sizes: sizes ?? this.sizes,
      statusFilter: statusFilter ?? this.statusFilter,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is AdminSizesScreenState &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage &&
      _listEquals(other.sizes, sizes) &&
      other.statusFilter == statusFilter &&
      other.isAdmin == isAdmin;

  @override
  int get hashCode => Object.hash(
    isLoading,
    errorMessage,
    Object.hashAll(sizes),
    statusFilter,
    isAdmin,
  );

  static bool _listEquals(List<Size> a, List<Size> b) {
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
