# Testing Reference

## Structure

Tests mirror `lib/`. The codebase is mid-migration from layer-first to feature-first; both layouts coexist. New tests should use the feature-first paths.

```
test/
├── helpers/                       # Shared utilities (test_image_data.dart, etc.)
├── fakes/                         # Hand-rolled fakes + builders (no mocking lib)
│   └── builders/                  # Entity builders (menu, page, container, …)
├── integration/                   # End-to-end tests against a real Directus
├── unit/                          # Pure-Dart / Riverpod / mapper / repo tests
│   ├── core/                      # Result, DomainError, router, URL resolver
│   ├── shared/                    # Mirrors lib/shared
│   │   ├── domain/{entities,repositories,usecases}/
│   │   ├── data/{datasources,mappers,models,repositories}/
│   │   └── presentation/{helpers,mixins,providers,theme,utils}/
│   ├── features/<feature>/        # Mirrors lib/features/<feature>
│   │   ├── domain/...             # Entities, props, repo input, use cases
│   │   ├── data/...               # DTOs, mappers, repo impls
│   │   └── presentation/...       # State, providers, registry
│   ├── data/                      # Legacy (mid-migration)
│   ├── domain/                    # Legacy (mid-migration)
│   └── presentation/              # Legacy (mid-migration)
└── widget/                        # UI / widget-tree tests
    ├── shared/presentation/{helpers,widgets}/
    ├── features/<feature>/presentation/{pages,widgets,…}/
    ├── pages/                     # Legacy (mid-migration)
    ├── presentation/              # Legacy (mid-migration)
    └── widgets/                   # Legacy (mid-migration)
```

**Totals (per `CLAUDE.md`):** 261 test files (163 unit, 75 widget, 1 integration, 22 fake-tests under `test/fakes/`), ~4 445 test cases. CI enforces ≥75 % coverage.

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

`mocktail` was removed (see commit `eaa684a`). All collaboration with infrastructure is done via **hand-rolled fakes** in `test/fakes/` + Riverpod `ProviderScope` / `ProviderContainer` overrides.

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

Available fakes include: `FakeAuthRepository`, `FakeMenuRepository`, `FakePageRepository`, `FakeContainerRepository`, `FakeColumnRepository`, `FakeWidgetRepository`, `FakeSizeRepository`, `FakeAreaRepository`, `FakeFileRepository`, `FakeAssetLoaderRepository`, `FakeMenuSubscriptionRepository`, `FakePresenceRepository`, `FakeConnectivityRepository`, `FakeMenuBundleRepository`, `FakeDirectusDataSource`, `FakeDirectusWebSocketSubscription`, `FakeSecureTokenStorage`, plus use-case fakes (`FakeFetchMenuTreeUseCase`, `FakeGeneratePdfUseCase`, `FakeListTemplatesUseCase`, `FakeListSizesUseCase`, `FakeListMenuBundlesUseCase`, `FakeCreateMenuBundleUseCase`, `FakeUpdateMenuBundleUseCase`, `FakeDeleteMenuBundleUseCase`, `FakePublishMenuBundleUseCase`).

Builders under `test/fakes/builders/` produce sensible default entities for tests (`MenuBuilder`, `PageBuilder`, `ContainerBuilder`, `ColumnBuilder`, `WidgetInstanceBuilder`, `SizeBuilder`, `UserBuilder`, `MenuBundleBuilder`).

Helpers: `test/fakes/result_helpers.dart` exposes `success(value)` / `failure(err)` constructors, and `test/fakes/reflectable_bootstrap.dart` calls `initializeReflectable()` once per test isolate.

### Riverpod unit / provider tests

```dart
late ProviderContainer container;
late FakeDirectusDataSource fakeDataSource;

setUp(() {
  fakeDataSource = FakeDirectusDataSource();
  container = ProviderContainer(
    overrides: [
      directusDataSourceProvider.overrideWithValue(fakeDataSource),
    ],
  );
});
tearDown(() => container.dispose());
```

### Widget tests

```dart
Widget createWidgetUnderTest() {
  final fakeAuth = FakeAuthRepository()
    ..whenTryRestoreSessionResponse = const Failure(UnauthorizedError());
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
    child: const MaterialApp(home: PageUnderTest()),
  );
}

testWidgets('displays widget', (tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  expect(find.text('Expected'), findsOneWidget);
});
```

## Key Conventions

- Hand-rolled fakes — never `mocktail`/`mockito`. New repo or use-case → add a `test/fakes/fake_<name>.dart` and a sibling `*_test.dart` exercising the fake itself.
- `FakeSecureTokenStorage` is in-memory and avoids platform-channel calls in tests.
- `FakeDirectusDataSource` is the boundary fake for repo-impl tests.
- Test image fixture: `kTestPngBytes` in `test/helpers/test_image_data.dart`.
- Reflectable: tests that mount widget-rendering pages (`MenuEditorPage`, `AdminTemplateEditorPage`, etc.) must call `initializeReflectable()` (see `test/fakes/reflectable_bootstrap.dart`) and override `widgetRepositoryProvider` (otherwise widget-instance lookups fail).
- DTO serialization tests verify JSON round-tripping (`fromJson` ↔ `toJson`).
- State / Notifier tests verify the loading → success and loading → error transitions explicitly.
- The `AuthNotifier` constructor calls `tryRestoreSession()` on init — always pre-program that response when constructing one in tests.

## Architectural Boundaries (enforced)

| Test Layer | May Mock / Fake | Must Not Import |
|---|---|---|
| Domain | — | Infrastructure, DTOs, frameworks |
| Use cases | Repositories | Concrete entities (use real ones) |
| UI / Widget | Use cases, providers | Data sources |
| Data / Repo impls | `DirectusDataSource` (`FakeDirectusDataSource`) | — |
