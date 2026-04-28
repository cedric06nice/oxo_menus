import 'package:oxo_menus/core/routing/feature_router.dart';

/// Navigation contract for the admin-sizes feature.
///
/// `AdminSizesRouteAdapter` implements this in production; the
/// [AdminSizesViewModel] depends on it so the view model never sees
/// `BuildContext` or any concrete router. The admin-sizes screen is a leaf —
/// its only navigation is "back" — so the contract intentionally exposes
/// nothing more.
abstract class AdminSizesRouter implements FeatureRouter {
  /// Pop the admin sizes page off the stack — typically returns to the
  /// settings screen or the template-create flow.
  void goBack();
}
