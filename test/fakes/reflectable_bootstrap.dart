import 'package:oxo_menus/main.reflectable.dart';

/// Initializes reflectable metadata for tests that exercise widget pages or
/// other code paths that depend on the reflectable package
/// (e.g. [MenuEditorPage], [AdminTemplateEditorPage], repository impls that
/// use [DirectusWebSocketSubscription]).
///
/// Call this once in [setUpAll] for any test file that renders such pages:
///
/// ```dart
/// setUpAll(initializeReflectableForTests);
/// ```
///
/// Calling it multiple times is safe — the generated [initializeReflectable]
/// function is idempotent.
void initializeReflectableForTests() {
  initializeReflectable();
}
