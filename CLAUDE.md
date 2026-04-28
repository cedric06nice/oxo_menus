# CLAUDE.md

## Project

OXO Menus — Flutter menu template builder with Directus CMS backend.
SDK >=3.8.0 <4.0.0 | Flutter 3.41.7 | Dart 3.11.5

## Architecture

Feature-first Clean Architecture. Top of `lib/`:

- `lib/core/` — cross-cutting infra (types, errors, routing, utils). No feature code.
- `lib/shared/` — domain/data/presentation reused across features (auth, file/area/asset repos, theme, common providers, common widgets, mixins).
- `lib/features/<feature>/` — feature modules. Each has the layers it needs:
  - **Full** (`menu`, `collaboration`, `connectivity`): `domain/` + `data/` + `presentation/`
  - **Domain + presentation** (`allergens`, `editor_tree`, `menu_editor`, `widget_system`): `domain/` + `presentation/`
  - **Presentation-only** (`auth`, `home`, `menu_list`, `settings`, all `admin_*`): `presentation/` only
- Dependency direction: features → shared → core. Features must not import from each other.

Key fixed locations:

- **lib/core/types/result.dart** — sealed `Result<T, E>` (Success | Failure), railway-oriented error handling
- **lib/core/errors/domain_errors.dart** — sealed `DomainError` hierarchy (InvalidCredentials, TokenExpired, Unauthorized, Network, NetworkUnavailable, NotFound, Validation, Server, Unknown, RateLimit)
- **lib/core/routing/app_router.dart** — GoRouter with auth guards, 11 routes
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
- `ConnectivityRetryMixin` for auto-retry lives at `lib/shared/presentation/mixins/connectivity_retry_mixin.dart`

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

`go_router` — routes in `lib/core/routing/app_router.dart`, constants in `lib/core/routing/app_routes.dart`

- Auth-guarded redirect (unauthenticated → `/login`, non-admin blocked from `/admin/*`)
- All route paths use `AppRoutes` constants (no hardcoded strings)
- Web uses `context.go()` for deep-linking, native uses `context.push()`

## Pages

Pages live at `lib/features/<feature>/presentation/pages/<feature>_page.dart` (a few admin pages sit directly under `presentation/`). Current set:

`login`, `home`, `menu_list`, `menu_editor`, `pdf_preview`, `admin_templates`, `admin_template_creator`, `admin_template_editor`, `admin_sizes`, `settings`

## Testing

```sh
flutter test                    # all tests
flutter test test/unit/         # unit only
flutter test test/widget/       # widget only
```

- Structure mirrors `lib/`: `test/unit/{core,shared,features}/`, `test/widget/{shared,features}/`, `test/integration/`, `test/fakes/`, `test/helpers/`
- Legacy paths (`test/unit/{data,domain,presentation}/`, `test/widget/{pages,presentation,widgets}/`) still exist — tests are mid-migration to the feature layout
- 261 test files (163 unit, 75 widget, 1 integration, 22 fake-tests under `test/fakes/`), ~4445 test cases
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
- Use cases: class with `execute()` method, injected repos via constructor
- Providers: manual `final xxxProvider = Provider<Xxx>((ref) { ... });`
- Currency: GBP (£)
- NEVER add the message "Co-Authored-By: Claude" or any other co-authing message on git
