# CLAUDE.md

## Project

OXO Menus — Flutter menu template builder with Directus CMS backend.
SDK >=3.8.0 <4.0.0 | Flutter 3.41.7 | Dart 3.11.5

## Architecture

Feature-first Clean Architecture. Top of `lib/`:

- `lib/core/` — cross-cutting infra (types, errors, routing, utils). No feature code.
- `lib/shared/` — domain/data/presentation reused across features (auth, file/area/asset repos, theme, shared `ChangeNotifier` controllers, common widgets, helpers).
- `lib/features/<feature>/` — feature modules. Each has the layers it needs:
  - **Full** (`menu`, `collaboration`, `connectivity`): `domain/` + `data/` + `presentation/`
  - **Domain + presentation** (everything else: `allergens`, `widget_system`, `auth`, `home`, `menu_editor`, `menu_list`, `settings`, all `admin_*`): `domain/` + `presentation/`. Each MVVM screen has a ViewModel + use cases; data dependencies are reused from `lib/shared/data/` or `lib/features/menu/data/`.
- Dependency direction: features → shared → core. Features must not import from each other.

Key fixed locations:

- **lib/core/types/result.dart** — sealed `Result<T, E>` (Success | Failure), railway-oriented error handling
- **lib/core/errors/domain_errors.dart** — sealed `DomainError` hierarchy (InvalidCredentials, TokenExpired, Unauthorized, Network, NetworkUnavailable, NotFound, Validation, Server, Unknown, RateLimit)
- **lib/core/routing/oxo_router.dart** — in-house `OxoRouter` (`RouterDelegate` + `RouteInformationParser` + `OxoRouterScope` `InheritedWidget`); replaces `go_router` (Phase 29)
- **lib/core/routing/app_router.dart** — `AppRouter.build()` constructs the production `OxoRouter` with auth/admin guards and 14 routes
- **lib/core/routing/app_routes.dart** — centralized route path constants (`AppRoutes`)
- **lib/core/utils/directus_url_resolver.dart** — environment-aware URL resolution (dart-define → web hostname → localhost)
- Repositories return `Result<T, DomainError>`, never throw

Topic-deep references live under `.claude/docs/`: `domain.md`, `data.md`, `presentation.md`, `testing.md`, `new_widget_checklist.md`.

## Domain Model (hierarchy, each level sorted by `index`)

```
Menu → Page → Container → Column → WidgetInstance
```

- `FetchMenuTreeUseCase` builds `MenuTree` with nested freezed value objects: `PageWithContainers`, `ContainerWithColumns`, `ColumnWithWidgets`
- `GeneratePdfUseCase` renders `MenuTree` to PDF client-side (`pdf` package), runs in background isolate
- `DuplicateMenuUseCase` deep-copies menu with all children, rollback on failure
- `ListTemplatesUseCase` / `ListSizesUseCase` / `ListImageFilesUseCase` — domain use cases with status filtering

## Widget System

Plugin architecture in `lib/features/widget_system/`:

- `lib/features/widget_system/domain/widget_definition.dart` — generic `WidgetDefinition<P>` (`parseProps`, `render`, `defaultProps`, `migrate`); also defines `WidgetContext` (runtime editing state: isEditable, onUpdate, onDelete, displayOptions)
- `lib/features/widget_system/domain/widget_registry.dart` — `WidgetRegistry`, O(1) lookup by type string
- `lib/features/widget_system/domain/widget_migrator.dart` — `WidgetMigrator`, version-based prop migration
- `lib/features/widget_system/presentation/widget_system/presentable_widget_definition.dart` and `presentable_widget_registry.dart` — presentation-side renderer + dynamic dispatch

Widget types: `dish`, `dish_to_share`, `image`, `section`, `set_menu_dish`, `set_menu_title`, `text`, `wine`

- Props: `lib/features/widget_system/domain/widgets/{type}/{type}_props.dart`
- UI + edit dialog: `lib/features/widget_system/presentation/widgets/{type}_widget/{type}_widget.dart` and `{type}_edit_dialog.dart`

## Real-Time Collaboration

Lives under `lib/features/collaboration/` (full domain + data + presentation).

- `MenuSubscriptionRepository` (`domain/repositories/`) — WebSocket stream of `MenuChangeEvent` (widget create/update/delete)
- `PresenceRepository` (`domain/repositories/`) — user presence tracking (join, leave, heartbeat, watchActiveUsers)
- `WidgetInstance` editing locks — `editingBy`, `editingSince` fields (entity defined in `lib/features/menu/domain/entities/`)
- `PresenceBar` and `EditingUserBadge` (`presentation/widgets/`) — active-users bar and per-widget editor badge

## Connectivity

Lives under `lib/features/connectivity/` (full domain + data + presentation).

- `ConnectivityRepository` (`domain/repositories/`) — DNS-probe-based connectivity monitoring (not just network interface)
- `ConnectivityStatus` enum: `online`, `offline`
- Periodic probes: 30s when online, 5s recovery when offline
- `OfflineBanner` / `OfflineErrorPage` (`presentation/widgets/`)
- Connectivity-aware retry: `MenuEditorViewModel.retryConnectivity()` calls `ConnectivityGateway.recheck()` and surfaces `isOffline` through state; the matching screen reacts via `ListenableBuilder` (the legacy `ConnectivityRetryMixin` was retired in Phase 28).

## Allergens

Lives under `lib/features/allergens/domain/`. UK FSA 14 allergens (`UkAllergen` enum). Dishes carry `List<AllergenInfo>` (structured). `AllergenFormatter` handles UK-compliant display (e.g., `GLUTEN [wheat], MILK, MAY CONTAIN EGGS`).

## State Management

`AppScope` `InheritedWidget` + per-feature `ChangeNotifier` controllers.
`flutter_riverpod` was retired in Phase 28.

- **`lib/core/di/app_container.dart`** — `AppContainer` holds singletons (gateways, `DirectusDataSource`, lazy `widgetRegistry` / `imageGateway`)
- **`lib/core/di/app_scope.dart`** — `AppScope` `InheritedWidget` exposes the container plus four `ChangeNotifier` controllers (`AuthController`, `ConnectivityController`, `AdminViewAsUserController`, `AppLifecycleController`). `AppScope.of(context)` returns the snapshot; widgets that need to rebuild on a controller change wrap themselves in `ListenableBuilder(listenable: controller, ...)`.
- **`lib/shared/presentation/controllers/`** — the four shared controllers; each subscribes to its gateway's stream and mirrors it into `notifyListeners()`.
- **Per-feature ViewModels** — extend `ViewModel<S>` (a `ChangeNotifier`) and live in `lib/features/<feature>/presentation/view_models/`. Each route in `app_router.dart` is hosted by a small `_*RouteHost` `StatefulWidget` that constructs the ViewModel in `initState` (reading the container via `AppScope.read(context)`) and disposes it on `dispose`.

## Data Layer

- `lib/shared/data/datasources/directus_data_source.dart` — `DirectusDataSource` wraps `directus_api_manager` package
- `lib/shared/data/datasources/secure_token_storage.dart` — `SecureTokenStorage` wraps `flutter_secure_storage`
- Shared DTOs/mappers in `lib/shared/data/{models,mappers}/` (`user_dto`, `area_dto`, `version_dto`, `error_mapper`, `user_mapper`, `area_mapper`, `file_mapper`)
- Feature-specific DTOs/mappers/repo impls under `lib/features/<feature>/data/{models,mappers,repositories}/` (currently `menu`, `collaboration`, `connectivity`)
- Mapper pattern: `XxxMapper.toEntity(dto)`, error mapping via `mapDirectusError()`

## Code Generation

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

- Freezed + json_serializable for entities, DTOs, props, states
- Reflectable for `main.reflectable.dart`
- Generated files: `*.freezed.dart`, `*.g.dart`, `*.reflectable.dart`

## Routing

In-house `OxoRouter` (`lib/core/routing/oxo_router.dart`) — `go_router` was retired in Phase 29. Routes are declared in `lib/core/routing/app_router.dart` (`AppRouter.build()`), constants live in `lib/core/routing/app_routes.dart`.

- `OxoRouter` is a `RouterConfig<OxoRouteState>` with an `OxoRouterDelegate` (stack of `OxoRouteEntry`), `OxoRouteInformationParser`, and a `redirect`/`refreshListenable` pair that mirror the previous GoRouter contract.
- Auth-guarded redirect (unauthenticated → `/login`, non-admin blocked from `/admin/*`); fires on every navigation and on `AuthController` / `AdminViewAsUserController` change.
- Shell-bound routes (`inShell: true`) are wrapped by the `shellBuilder` (the `AppShell` in production); auth screens (`/login`, `/forgot-password`, `/reset-password`) and `/splash` sit outside the shell.
- All route paths use `AppRoutes` constants (no hardcoded strings).
- Feature ViewModels never touch the router directly: each adapter uses `RouteNavigator` (`OxoRouterRouteNavigator(context)` in production), which resolves the surrounding `OxoRouter` via `OxoRouterScope.of(context)`. `RouteNavigator.go(...)` resets the stack; `push(...)` appends.

## Screens

MVVM screens live at `lib/features/<feature>/presentation/screens/<feature>_screen.dart` (a screen is a passive view bound to a `ViewModel<S>`; the `*_page.dart` widgets were retired in Phases 15–25). Current set:

`login`, `forgot_password`, `reset_password`, `home`, `menu_list`, `menu_editor`, `pdf_preview`, `admin_templates`, `admin_template_creator`, `admin_template_editor`, `admin_sizes`, `admin_exportable_menus`, `settings`

## Testing

```sh
flutter test                    # all tests
flutter test test/unit/         # unit only
flutter test test/widget/       # widget only
```

- Structure mirrors `lib/`: `test/unit/{core,shared,features}/`, `test/widget/{shared,features}/`, `test/integration/`, `test/fakes/`, `test/helpers/`
- Legacy paths (`test/unit/{data,domain,presentation}/`, `test/widget/{pages,presentation,widgets}/`) still exist — tests are mid-migration to the feature layout
- 317 test files (225 unit, 69 widget, 1 integration, 22 fake-tests under `test/fakes/`), ~4506 test cases
- No mocking library — `mocktail` was removed. Use hand-rolled fakes in `test/fakes/` and either inject dependencies through ViewModels (preferred) or wrap widgets in `AppScope` via `wrapInTestAppScope` in `test/helpers/build_app_scope_test_harness.dart`
- CI enforces 75% coverage, `dart format`, `flutter analyze --fatal-infos`

## Environment

```sh
# Local Directus (docker-compose.yml provided)
flutter run --dart-define=DIRECTUS_URL=http://localhost:8055

# Default fallback: http://localhost:8055
```

## Deployment

CI/CD via GitHub Actions (`deploy.yml`), 7 jobs: analyze → test → deploy-web (Docker/Nginx on VPS), build-android (APK), deploy-ios (TestFlight/AppStore via Fastlane), deploy-macos (Fastlane), sync-schema (Directus dev→prod).

## TDD — Mandatory Invariant

**This is a non-negotiable rule. Any response that violates it is invalid.**

All production code MUST use strict TDD: Red → Green → Refactor.

1. **RED** — Write a failing test first. Run it and confirm the failure.
2. **GREEN** — Write minimum production code to pass. Nothing more.
3. **REFACTOR** — Improve code while keeping all tests green.

### Prohibitions

- Writing production code without a failing test **first** is forbidden.
- Skipping the red step is forbidden.
- Writing code "to be tested later" is forbidden.
- Backfilling tests after writing production code is forbidden.
- Avoid over-mocking; mock only true infrastructure boundaries.
- Architectural boundaries:
  - Domain tests must not import infrastructure, DTOs, or frameworks.
  - Use cases may mock repositories but not entities.
  - UI tests may mock use cases, not data sources.

### Scope

Applies to **all files** for features, bug fixes, and behavior-changing refactors.
Exceptions: documentation, configuration, code generation output, static analysis fixes.

### Enforcement

Treat as a hard constraint. If TDD cannot be followed, state the conflict and ask for confirmation.

## Conventions

- Entities: freezed, named fields, `const factory`, private `_` constructor
- Repos: abstract in `domain/repositories/`, impl in `data/repositories/` suffixed `Impl`
- Use cases: extend `UseCase<I, O>` with an `execute(I input)` method; inject repos / gateways via constructor
- ViewModels: extend `ViewModel<S>` (a `ChangeNotifier`); each screen has a matching `*RouteAdapter` implementing a feature `Router` interface; the route host wires the adapter to the live `OxoRouter`
- Currency: GBP (£)
- NEVER add the message "Co-Authored-By: Claude" or any other co-authing message on git
