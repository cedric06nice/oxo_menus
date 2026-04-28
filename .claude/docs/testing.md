# Testing Reference

## Structure

Tests mirror `lib/`. The codebase is mid-migration from layer-first to feature-first; both layouts coexist. New tests should use the feature-first paths.

```
test/
├── helpers/                       # Shared utilities
│   ├── build_app_scope_test_harness.dart    # wrapInTestAppScope(...)
│   ├── build_view_model_test_harness.dart   # pumpScreenWithViewModel(...)
│   └── test_image_data.dart
├── fakes/                         # Hand-rolled fakes + builders (no mocking lib)
│   └── builders/                  # Entity builders (menu, page, container, …)
├── integration/                   # End-to-end tests against a real Directus
├── unit/                          # Pure-Dart, controller, mapper, repo, use-case, view-model tests
│   ├── core/                      # Result, DomainError, router (OxoRouter), URL resolver
│   ├── shared/                    # Mirrors lib/shared
│   │   ├── domain/{entities,repositories,usecases}/
│   │   ├── data/{datasources,mappers,models,repositories}/
│   │   └── presentation/{controllers,helpers,theme,utils}/
│   ├── features/<feature>/        # Mirrors lib/features/<feature>
│   │   ├── domain/...             # Entities, props, repo input, use cases
│   │   ├── data/...               # DTOs, mappers, repo impls
│   │   └── presentation/...       # ViewModels, route adapters, registries
│   ├── data/                      # Legacy (mid-migration)
│   ├── domain/                    # Legacy (mid-migration)
│   └── presentation/              # Legacy (mid-migration)
└── widget/                        # UI / widget-tree tests
    ├── shared/presentation/{helpers,widgets}/
    ├── features/<feature>/presentation/{screens,widgets,…}/
    ├── pages/                     # Legacy (mid-migration)
    ├── presentation/              # Legacy (mid-migration)
    └── widgets/                   # Legacy (mid-migration)
```

**Totals:** 317 test files (225 unit, 69 widget, 1 integration, 22 fake-tests under `test/fakes/`), ~4506 test cases. CI enforces ≥75 % coverage.

## Commands

```sh
flutter test                    # All tests
flutter test test/unit/         # Unit only
flutter test test/widget/       # Widget only
```

## CI (`.github/workflows/deploy.yml`)

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter pub run build_runner build --delete-conflicting-outputs`
3. `flutter analyze --fatal-infos`
4. `flutter test --coverage --reporter expanded`
5. Coverage gate: ≥ 75 % (LH/LF parsed from `lcov.info`)

## No Mocking Library

`mocktail` was removed (see commit `eaa684a`); `flutter_riverpod` was retired in Phase 28. All collaboration with infrastructure is done via **hand-rolled fakes** in `test/fakes/` and either:

- **Constructor injection** (preferred) — pass fakes directly into the ViewModel / use case / dialog under test, then mount the screen via `pumpScreenWithViewModel(...)`. No DI scope required.
- **`wrapInTestAppScope(child: ...)`** (`test/helpers/build_app_scope_test_harness.dart`) — for widgets that read `AppScope.of(context)` (e.g. `PresenceBar`, `EditingUserBadge`, `UserAvatarWidget`). The helper builds an `AppContainer` backed by stub gateways and disables `AuthController.autoRestore` so tests stay deterministic.

### Hand-rolled fakes (`test/fakes/`)

Each fake records a typed call list and lets the test pre-program responses.

```dart
// FakeAuthRepository sketch — see test/fakes/fake_auth_repository.dart
sealed class AuthCall { const AuthCall(); }
final class LoginCall extends AuthCall {
  final String email;
  final String password;
  const LoginCall({required this.email, required this.password});
}

class FakeAuthRepository implements AuthRepository {
  final List<AuthCall> calls = [];
  Result<User, DomainError>? whenLoginResponse;

  @override
  Future<Result<User, DomainError>> login(String email, String password) async {
    calls.add(LoginCall(email: email, password: password));
    return whenLoginResponse ?? (throw StateError('login response not set'));
  }
  // ...
}
```

Available fakes include: `FakeAuthRepository`, `FakeMenuRepository`, `FakePageRepository`, `FakeContainerRepository`, `FakeColumnRepository`, `FakeWidgetRepository`, `FakeSizeRepository`, `FakeAreaRepository`, `FakeFileRepository`, `FakeAssetLoaderRepository`, `FakeMenuSubscriptionRepository`, `FakePresenceRepository`, `FakeConnectivityRepository`, `FakeMenuBundleRepository`, `FakeDirectusDataSource`, `FakeDirectusWebSocketSubscription`, `FakeSecureTokenStorage`, plus per-feature use-case / route-adapter fakes used by ViewModel tests.

Builders under `test/fakes/builders/` produce sensible default entities for tests (`MenuBuilder`, `PageBuilder`, `ContainerBuilder`, `ColumnBuilder`, `WidgetInstanceBuilder`, `SizeBuilder`, `UserBuilder`, `MenuBundleBuilder`).

Helpers: `test/fakes/result_helpers.dart` exposes `success(value)` / `failure(err)` constructors, and `test/fakes/reflectable_bootstrap.dart` calls `initializeReflectable()` once per test isolate.

### ViewModel tests

```dart
test('emits error when login fails', () async {
  final auth = FakeAuthRepository()
    ..whenLoginResponse = const Failure(InvalidCredentialsError());
  final fakeRouter = FakeAuthRouter();
  final vm = LoginViewModel(
    login: LoginUseCase(gateway: AuthGateway(repository: auth)),
    router: fakeRouter,
    connectivityGateway: ConnectivityGateway(repository: FakeConnectivityRepository()),
  );
  addTearDown(vm.dispose);

  await vm.submit(email: 'x@y.z', password: 'bad');

  expect(vm.state.errorMessage, isNotNull);
  expect(fakeRouter.calls, isEmpty);
});
```

### Screen tests

```dart
testWidgets('shows error banner when ViewModel reports failure', (tester) async {
  final vm = StubLoginViewModel(state: const LoginState(errorMessage: 'Bad creds'));
  await pumpScreenWithViewModel(
    tester,
    viewModel: vm,
    builder: (vm) => LoginScreen(viewModel: vm),
  );
  expect(find.text('Bad creds'), findsOneWidget);
});
```

For widgets that read `AppScope.of(context)` directly, wrap them:

```dart
await tester.pumpWidget(wrapInTestAppScope(
  child: const PresenceBar(menuId: 1),
));
```

### Router tests

`AppRouter.build()` returns an `OxoRouter`; the unit tests build it inside an `AppScope` and capture the router via `_RouterTestHarness` to drive `router.go(...)` deep links. See `test/unit/core/routing/app_router_test.dart` for the canonical pattern.

## Key Conventions

- Hand-rolled fakes — never `mocktail` / `mockito`. New repo or use-case → add a `test/fakes/fake_<name>.dart` and a sibling `*_test.dart` exercising the fake itself.
- `FakeSecureTokenStorage` is in-memory and avoids platform-channel calls in tests.
- `FakeDirectusDataSource` is the boundary fake for repo-impl tests.
- Test image fixture: `kTestPngBytes` in `test/helpers/test_image_data.dart`.
- Reflectable: tests that mount widget-rendering screens (`MenuEditorScreen`, `AdminTemplateEditorScreen`, etc.) must call `initializeReflectable()` (see `test/fakes/reflectable_bootstrap.dart`).
- `AppContainer.directusAccessTokenOverride` — pass a known token to the test container (or `wrapInTestAppScope(directusAccessToken: ...)`) so tests do not need a real `DirectusDataSource`.
- `AuthController.autoRestore: false` — disable session restore in tests that construct a controller directly.
- DTO serialization tests verify JSON round-tripping (`fromJson` ↔ `toJson`).
- ViewModel tests verify the loading → success and loading → error transitions explicitly and assert the route-adapter call list.

## Architectural Boundaries (enforced)

| Test Layer | May Mock / Fake | Must Not Import |
|---|---|---|
| Domain | — | Infrastructure, DTOs, frameworks |
| Use cases | Repositories / gateways | Concrete entities (use real ones) |
| ViewModels | Use cases, gateways, route adapter | Repositories directly |
| UI / Widget | ViewModels, route adapter | Data sources |
| Data / Repo impls | `DirectusDataSource` (`FakeDirectusDataSource`) | — |
