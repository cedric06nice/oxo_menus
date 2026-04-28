/// Marker interface for per-feature router contracts.
///
/// Each feature defines its own router interface (e.g. `MenuListRouter`,
/// `AuthRouter`) extending [FeatureRouter] and exposes only the navigation
/// methods that feature's ViewModels need. The production implementation is
/// the feature's `Legacy*Router` adapter, which forwards to `go_router` via
/// [LegacyNavigator]; tests inject hand-rolled fakes.
///
/// Feature routers must NEVER expose `BuildContext`, `Navigator`, or any
/// Flutter primitives — only domain-shaped methods like
/// `goToMenuEditor(int menuId)`. This keeps ViewModels free of UI concerns
/// and trivial to test with hand-rolled fakes.
abstract class FeatureRouter {
  const FeatureRouter();
}
