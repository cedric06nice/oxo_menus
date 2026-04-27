import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';

/// One entry in the [MainRouter] stack.
///
/// Each subclass represents a destination (login, settings, menu editor, …)
/// and is responsible for building its screen and disposing of any owned
/// view models.
///
/// Equality (via [identity]) is what the router uses to detect "same page" so
/// state survives stack rebuilds.
abstract class RoutePage {
  const RoutePage();

  /// Stable identity used for stack diffing and VM caching.
  Object get identity;

  /// Construct the screen for this route. Implementations resolve dependencies
  /// from [container], create use cases → view models → screen, and return
  /// the screen widget. Must be cheap and idempotent — the router may call it
  /// multiple times across rebuilds.
  Widget buildScreen(AppContainer container);

  /// Called by the router when this page leaves the stack for good. Default
  /// is a no-op; subclasses that own a ViewModel must dispose it here.
  void disposeResources() {}
}
