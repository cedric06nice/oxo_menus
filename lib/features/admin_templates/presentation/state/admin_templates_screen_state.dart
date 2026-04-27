import 'package:oxo_menus/features/menu/domain/entities/menu.dart';

/// Immutable state of the migrated admin-templates screen.
///
/// Defaults match the "loading, no templates, all-statuses filter, not admin"
/// snapshot owned by [AdminTemplatesViewModel] before the first load resolves.
final class AdminTemplatesScreenState {
  const AdminTemplatesScreenState({
    this.isLoading = true,
    this.errorMessage,
    this.templates = const <Menu>[],
    this.statusFilter = 'all',
    this.isAdmin = false,
  });

  /// True while a load (initial, refresh, or status-filter-driven reload) is
  /// in flight.
  final bool isLoading;

  /// Last error message surfaced by a load/mutate operation; `null` when there
  /// is no current error.
  final String? errorMessage;

  /// Templates visible to the admin viewer, ordered as returned by the
  /// repository.
  final List<Menu> templates;

  /// One of `'all' | 'draft' | 'published' | 'archived'`. Drives the status
  /// filter bar.
  final String statusFilter;

  /// `true` when the viewer is an admin. Mirrors [AuthGateway]'s snapshot at
  /// VM construction time.
  final bool isAdmin;

  AdminTemplatesScreenState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    List<Menu>? templates,
    String? statusFilter,
    bool? isAdmin,
  }) {
    return AdminTemplatesScreenState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      templates: templates ?? this.templates,
      statusFilter: statusFilter ?? this.statusFilter,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is AdminTemplatesScreenState &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage &&
      _listEquals(other.templates, templates) &&
      other.statusFilter == statusFilter &&
      other.isAdmin == isAdmin;

  @override
  int get hashCode => Object.hash(
    isLoading,
    errorMessage,
    Object.hashAll(templates),
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
