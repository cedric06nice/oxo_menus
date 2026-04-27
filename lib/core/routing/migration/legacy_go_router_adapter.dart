import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/routing/feature_router.dart';

/// Bridges per-feature router contracts to the legacy `go_router` during the
/// migration.
///
/// Migrated ViewModels can be wired with this adapter when they live under a
/// `Screen` that is still mounted by `go_router` rather than `MainRouter`.
/// Each method translates a domain navigation call to the equivalent
/// `context.go(...)` / `context.push(...)`.
///
/// Subclasses should `implements` whichever per-feature router interface they
/// adapt and forward calls to the helpers here.
abstract class LegacyGoRouterAdapter implements FeatureRouter {
  const LegacyGoRouterAdapter(this._contextProvider);

  final BuildContext Function() _contextProvider;

  @protected
  void goTo(String location, {Object? extra}) {
    _contextProvider().go(location, extra: extra);
  }

  @protected
  void pushTo(String location, {Object? extra}) {
    _contextProvider().push(location, extra: extra);
  }

  @protected
  void popLegacy() {
    _contextProvider().pop();
  }
}
