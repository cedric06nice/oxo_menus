import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';

/// Immutable state of the migrated admin-template-creator screen.
///
/// Captures the form metadata that decides what the screen renders: viewer
/// admin status, the loaded sizes/areas, the current selection, the saving
/// flag, and the last surfaced error. The free-text fields (name, version)
/// stay in the screen as `TextEditingController` text and are passed to the
/// view model only at submit time — the VM doesn't track every keystroke.
final class AdminTemplateCreatorScreenState {
  const AdminTemplateCreatorScreenState({
    this.isAdmin = false,
    this.isLoadingSizes = true,
    this.isLoadingAreas = true,
    this.errorMessage,
    this.sizes = const <Size>[],
    this.areas = const <Area>[],
    this.selectedSize,
    this.selectedArea,
    this.isSaving = false,
  });

  /// `true` when the viewer is an admin. Mirrors [AuthGateway]'s snapshot at
  /// VM construction time.
  final bool isAdmin;

  /// True while the initial sizes load (or a connectivity-driven reload) is
  /// in flight.
  final bool isLoadingSizes;

  /// True while the initial areas load (or a connectivity-driven reload) is
  /// in flight.
  final bool isLoadingAreas;

  /// Last error message surfaced by a load or `createTemplate` failure;
  /// `null` when there is no current error.
  final String? errorMessage;

  /// Sizes available in the page-size dropdown.
  final List<Size> sizes;

  /// Areas available in the area dropdown. The picker also shows a synthetic
  /// "None" entry which maps to `selectedArea = null`.
  final List<Area> areas;

  /// Currently picked size, or `null` while the form is still empty.
  final Size? selectedSize;

  /// Currently picked area, or `null` when the user explicitly chose "None"
  /// or has not picked an area yet.
  final Area? selectedArea;

  /// True between the start of `createTemplate` and its resolution. Drives
  /// the spinner-on-button affordance and disables the submit button.
  final bool isSaving;

  AdminTemplateCreatorScreenState copyWith({
    bool? isAdmin,
    bool? isLoadingSizes,
    bool? isLoadingAreas,
    Object? errorMessage = _sentinel,
    List<Size>? sizes,
    List<Area>? areas,
    Object? selectedSize = _sentinel,
    Object? selectedArea = _sentinel,
    bool? isSaving,
  }) {
    return AdminTemplateCreatorScreenState(
      isAdmin: isAdmin ?? this.isAdmin,
      isLoadingSizes: isLoadingSizes ?? this.isLoadingSizes,
      isLoadingAreas: isLoadingAreas ?? this.isLoadingAreas,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      sizes: sizes ?? this.sizes,
      areas: areas ?? this.areas,
      selectedSize: identical(selectedSize, _sentinel)
          ? this.selectedSize
          : selectedSize as Size?,
      selectedArea: identical(selectedArea, _sentinel)
          ? this.selectedArea
          : selectedArea as Area?,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is AdminTemplateCreatorScreenState &&
      other.isAdmin == isAdmin &&
      other.isLoadingSizes == isLoadingSizes &&
      other.isLoadingAreas == isLoadingAreas &&
      other.errorMessage == errorMessage &&
      _listEquals(other.sizes, sizes) &&
      _listEquals(other.areas, areas) &&
      other.selectedSize == selectedSize &&
      other.selectedArea == selectedArea &&
      other.isSaving == isSaving;

  @override
  int get hashCode => Object.hash(
    isAdmin,
    isLoadingSizes,
    isLoadingAreas,
    errorMessage,
    Object.hashAll(sizes),
    Object.hashAll(areas),
    selectedSize,
    selectedArea,
    isSaving,
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
}
