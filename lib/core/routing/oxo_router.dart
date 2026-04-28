import 'package:flutter/material.dart';

/// Lightweight in-house router that replaces `go_router`.
///
/// `OxoRouter` is a [RouterConfig] holding an [OxoRouterDelegate] and an
/// [OxoRouteInformationParser]. Each route is described by an [OxoRoute] with a
/// path template (`'/menus/:id'`), a builder, and a flag that opts the route
/// into the application shell. The delegate keeps a navigation stack of
/// [OxoRouteEntry] values; `go(...)` resets the stack to a single entry and
/// `push(...)` appends one. A redirect closure runs on every navigation and
/// whenever the supplied [Listenable] fires, mirroring the
/// `refreshListenable`/`redirect` contract that the previous `GoRouter` build
/// relied on.
///
/// Use [OxoRouterScope] in the widget tree (above `MaterialApp.router`) to
/// expose the router to descendants; `OxoRouterRouteNavigator` resolves it via
/// the inherited widget so feature route adapters never depend on a specific
/// router implementation.
class OxoRouter implements RouterConfig<OxoRouteState> {
  OxoRouter({
    required String initialLocation,
    required List<OxoRoute> routes,
    OxoShellBuilder? shellBuilder,
    Listenable? refreshListenable,
    OxoRedirect? redirect,
  }) : _delegate = OxoRouterDelegate(
         initialLocation: initialLocation,
         routes: routes,
         shellBuilder: shellBuilder,
         refreshListenable: refreshListenable,
         redirect: redirect,
       ),
       _parser = const OxoRouteInformationParser(),
       _provider = PlatformRouteInformationProvider(
         initialRouteInformation: RouteInformation(
           uri: Uri.parse(_resolveInitialPlatformLocation(initialLocation)),
         ),
       ),
       _backButtonDispatcher = RootBackButtonDispatcher();

  /// Picks the location the platform [RouteInformationProvider] should report
  /// on first attach. On web, `defaultRouteName` carries the URL the user
  /// opened the app with — when it's anything other than `'/'` we honour it so
  /// deep-links land on the right screen. On native (and in tests) it's the
  /// engine's `'/'` placeholder; we fall back to [initialLocation] so the app
  /// boots at its declared start route instead of an unmatched `'/'`.
  static String _resolveInitialPlatformLocation(String initialLocation) {
    final platformDefault =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    return platformDefault == '/' ? initialLocation : platformDefault;
  }

  final OxoRouterDelegate _delegate;
  final OxoRouteInformationParser _parser;
  final PlatformRouteInformationProvider _provider;
  final RootBackButtonDispatcher _backButtonDispatcher;

  @override
  RouterDelegate<OxoRouteState> get routerDelegate => _delegate;

  @override
  RouteInformationParser<OxoRouteState> get routeInformationParser => _parser;

  @override
  RouteInformationProvider? get routeInformationProvider => _provider;

  @override
  BackButtonDispatcher? get backButtonDispatcher => _backButtonDispatcher;

  /// Replace the entire navigation stack with a single entry pointing at
  /// [location]. Equivalent to `go_router`'s `context.go(location)`.
  void go(String location, {Object? extra}) =>
      _delegate.go(location, extra: extra);

  /// Push [location] on top of the current stack so the previous entry is
  /// preserved beneath it. Equivalent to `go_router`'s `context.push(...)`.
  void push(String location, {Object? extra}) =>
      _delegate.push(location, extra: extra);

  /// Pop the top of the navigation stack. No-op if the stack only holds one
  /// entry.
  void pop() => _delegate.pop();

  /// The location currently rendered at the top of the stack.
  String get currentLocation => _delegate.currentLocation;

  /// Dispose the underlying delegate. Call from the widget that owns the
  /// router.
  void dispose() => _delegate.dispose();
}

/// Function that returns a redirect target for the given navigation state.
/// Return `null` to let the navigation proceed unchanged.
typedef OxoRedirect = String? Function(OxoRouteState state);

/// Builder used to wrap shell-bound routes (`/home`, `/menus`, `/settings`,
/// `/admin/*`) in a common chrome — typically the `AppShell`.
typedef OxoShellBuilder =
    Widget Function(BuildContext context, String currentLocation, Widget child);

/// Builder used to construct the widget for a matched [OxoRoute].
typedef OxoRouteBuilder =
    Widget Function(BuildContext context, OxoRouteMatch match);

/// Defines a single route in the application.
@immutable
class OxoRoute {
  const OxoRoute({
    required this.pattern,
    required this.builder,
    this.inShell = false,
  });

  /// The path template for the route. Supports static segments and named
  /// placeholders (`':id'`). Trailing slashes are ignored.
  final String pattern;

  /// Builder invoked to produce the route's widget.
  final OxoRouteBuilder builder;

  /// Whether the matched widget should be wrapped in the app shell supplied to
  /// [OxoRouter].
  final bool inShell;

  /// Returns a parameter map if [path] matches this route's [pattern], or
  /// `null` otherwise.
  Map<String, String>? matchPath(String path) {
    final patternSegments = _segments(pattern);
    final pathSegments = _segments(path);
    if (patternSegments.length != pathSegments.length) return null;
    final params = <String, String>{};
    for (var i = 0; i < patternSegments.length; i++) {
      final p = patternSegments[i];
      final s = pathSegments[i];
      if (p.startsWith(':')) {
        params[p.substring(1)] = s;
      } else if (p != s) {
        return null;
      }
    }
    return params;
  }

  static List<String> _segments(String path) =>
      path.split('/').where((s) => s.isNotEmpty).toList();
}

/// One entry on the navigation stack: a fully-resolved location plus optional
/// `extra` payload propagated from `push`/`go` calls.
@immutable
class OxoRouteEntry {
  const OxoRouteEntry({required this.location, this.extra});

  /// Path + query (`'/menus/2?focus=top'`).
  final String location;

  /// Free-form payload forwarded to the route builder via [OxoRouteMatch].
  final Object? extra;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OxoRouteEntry &&
          other.location == location &&
          other.extra == extra);

  @override
  int get hashCode => Object.hash(location, extra);
}

/// Snapshot of the navigation stack handed to redirects.
@immutable
class OxoRouteState {
  const OxoRouteState({required this.stack});

  final List<OxoRouteEntry> stack;

  /// Topmost entry — the route the user is currently looking at.
  OxoRouteEntry get top => stack.last;

  /// Convenience accessor for [top]'s location.
  String get location => top.location;

  /// Path portion of [location] (no query string).
  String get matchedLocation => Uri.parse(location).path;
}

/// Concrete match handed to a route's builder. Carries the original location,
/// parsed path/query parameters, and `extra` payload.
@immutable
class OxoRouteMatch {
  const OxoRouteMatch({
    required this.location,
    required this.pathParameters,
    required this.queryParameters,
    this.extra,
  });

  final String location;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Object? extra;
}

/// Parses platform [RouteInformation] into [OxoRouteState] and back.
class OxoRouteInformationParser extends RouteInformationParser<OxoRouteState> {
  const OxoRouteInformationParser();

  @override
  Future<OxoRouteState> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    final query = uri.hasQuery ? '?${uri.query}' : '';
    final path = uri.path.isEmpty ? '/' : uri.path;
    return OxoRouteState(
      stack: <OxoRouteEntry>[OxoRouteEntry(location: '$path$query')],
    );
  }

  @override
  RouteInformation restoreRouteInformation(OxoRouteState configuration) {
    return RouteInformation(uri: Uri.parse(configuration.location));
  }
}

/// Owns the navigation stack, runs redirects, and builds the [Navigator]
/// rendered by `MaterialApp.router`.
class OxoRouterDelegate extends RouterDelegate<OxoRouteState>
    with ChangeNotifier {
  OxoRouterDelegate({
    required this.initialLocation,
    required this.routes,
    this.shellBuilder,
    this.refreshListenable,
    this.redirect,
  }) : _stack = <OxoRouteEntry>[OxoRouteEntry(location: initialLocation)] {
    refreshListenable?.addListener(_handleRefresh);
    _applyRedirect();
  }

  final String initialLocation;
  final List<OxoRoute> routes;
  final OxoShellBuilder? shellBuilder;
  final Listenable? refreshListenable;
  final OxoRedirect? redirect;

  List<OxoRouteEntry> _stack;

  String get currentLocation => _stack.last.location;

  /// Reset the stack to a single entry pointing at [location].
  void go(String location, {Object? extra}) {
    _stack = <OxoRouteEntry>[OxoRouteEntry(location: location, extra: extra)];
    _applyRedirect();
    notifyListeners();
  }

  /// Append a new entry on top of the existing stack.
  void push(String location, {Object? extra}) {
    _stack = <OxoRouteEntry>[
      ..._stack,
      OxoRouteEntry(location: location, extra: extra),
    ];
    _applyRedirect();
    notifyListeners();
  }

  /// Pop the top entry. No-op if the stack only has one entry.
  void pop() {
    if (_stack.length <= 1) return;
    _stack = _stack.sublist(0, _stack.length - 1);
    notifyListeners();
  }

  void _handleRefresh() {
    if (_applyRedirect()) {
      notifyListeners();
    }
  }

  /// Run the supplied [redirect] in a fixed-point loop (max 5 hops) and
  /// rewrite the top of the stack if it changes the destination. Returns
  /// `true` if the stack was rewritten.
  bool _applyRedirect() {
    if (redirect == null) return false;
    var changed = false;
    for (var i = 0; i < 5; i++) {
      final next = redirect!(OxoRouteState(stack: _stack));
      if (next == null || next == _stack.last.location) break;
      _stack = <OxoRouteEntry>[OxoRouteEntry(location: next)];
      changed = true;
    }
    return changed;
  }

  @override
  Future<void> setNewRoutePath(OxoRouteState configuration) async {
    _stack = configuration.stack.toList();
    _applyRedirect();
    notifyListeners();
  }

  @override
  OxoRouteState? get currentConfiguration =>
      OxoRouteState(stack: List<OxoRouteEntry>.unmodifiable(_stack));

  @override
  Future<bool> popRoute() async {
    if (_stack.length <= 1) return false;
    _stack = _stack.sublist(0, _stack.length - 1);
    notifyListeners();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _stack.map(_buildPage).toList(growable: false);
    return Navigator(pages: pages, onDidRemovePage: _onDidRemovePage);
  }

  void _onDidRemovePage(Page<dynamic> page) {
    final index = _stack.indexWhere(
      (entry) => ValueKey<String>(entry.location) == page.key,
    );
    if (index < 0) return;
    final next = <OxoRouteEntry>[..._stack]..removeAt(index);
    if (next.isEmpty) return;
    _stack = next;
    notifyListeners();
  }

  Page<dynamic> _buildPage(OxoRouteEntry entry) {
    final uri = Uri.parse(entry.location);
    final path = uri.path;
    OxoRoute? matched;
    Map<String, String>? params;
    for (final route in routes) {
      final result = route.matchPath(path);
      if (result != null) {
        matched = route;
        params = result;
        break;
      }
    }
    if (matched == null) {
      return MaterialPage<void>(
        key: ValueKey<String>(entry.location),
        child: _RouteNotFound(location: entry.location),
      );
    }
    final match = OxoRouteMatch(
      location: entry.location,
      pathParameters: params!,
      queryParameters: uri.queryParameters,
      extra: entry.extra,
    );
    final route = matched;
    return MaterialPage<void>(
      key: ValueKey<String>(entry.location),
      child: Builder(
        builder: (context) {
          final body = route.builder(context, match);
          if (route.inShell && shellBuilder != null) {
            return shellBuilder!(context, entry.location, body);
          }
          return body;
        },
      ),
    );
  }

  @override
  void dispose() {
    refreshListenable?.removeListener(_handleRefresh);
    super.dispose();
  }
}

/// `InheritedWidget` that exposes an [OxoRouter] to descendants so feature
/// route adapters and nav bars can call `go`/`push` without holding a
/// reference to the router themselves.
class OxoRouterScope extends InheritedWidget {
  const OxoRouterScope({super.key, required this.router, required super.child});

  final OxoRouter router;

  static OxoRouter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OxoRouterScope>();
    assert(scope != null, 'No OxoRouterScope found in widget tree');
    return scope!.router;
  }

  /// Same as [of] but does not register a dependency, so the calling widget
  /// will not rebuild if the surrounding [OxoRouterScope] changes. Use from
  /// one-shot lookups (e.g. constructing a router-bound navigator in
  /// `initState`) where rebuild-on-change tracking is not needed.
  static OxoRouter read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<OxoRouterScope>();
    assert(element != null, 'No OxoRouterScope found in widget tree');
    return (element!.widget as OxoRouterScope).router;
  }

  @override
  bool updateShouldNotify(OxoRouterScope oldWidget) =>
      router != oldWidget.router;
}

class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No route matches $location',
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
