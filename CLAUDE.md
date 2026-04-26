# CLAUDE.md

## Project

OXO Menus — Flutter menu template builder with Directus CMS backend.
SDK >=3.8.0 <4.0.0 | Flutter 3.41.7 | Dart 3.11.5

## Architecture

Clean Architecture: `core/` → `domain/` → `data/` → `presentation/`

- **core/types/result.dart** — sealed `Result<T, E>` (Success | Failure), railway-oriented error handling
- **core/errors/domain_errors.dart** — sealed `DomainError` hierarchy (InvalidCredentials, TokenExpired, Unauthorized, Network, NetworkUnavailable, NotFound, Validation, Server, Unknown, RateLimit)
- **core/routing/app_router.dart** — GoRouter with auth guards, 11 routes
- **core/routing/app_routes.dart** — centralized route path constants (`AppRoutes`)
- **core/utils/directus_url_resolver.dart** — environment-aware URL resolution (dart-define → web hostname → localhost)
- Repositories return `Result<T, DomainError>`, never throw

Detailed references: [domain](.claude/docs/domain.md) | [data](.claude/docs/data.md) | [presentation](.claude/docs/presentation.md) | [testing](.claude/docs/testing.md) | [new widget](.claude/docs/new_widget_checklist.md)

## Domain Model (hierarchy, each level sorted by `index`)

```
Menu → Page → Container → Column → WidgetInstance
```

- `FetchMenuTreeUseCase` builds `MenuTree` with nested freezed value objects: `PageWithContainers`, `ContainerWithColumns`, `ColumnWithWidgets`
- `GeneratePdfUseCase` renders `MenuTree` to PDF client-side (`pdf` package), runs in background isolate
- `DuplicateMenuUseCase` deep-copies menu with all children, rollback on failure
- `ListTemplatesUseCase` / `ListSizesUseCase` / `ListImageFilesUseCase` — domain use cases with status filtering

## Widget System

Plugin architecture in `domain/widget_system/`:

- `WidgetDefinition<P>` — generic: `parseProps`, `render`, `defaultProps`, `migrate`
- `WidgetRegistry` — O(1) lookup by type string
- `WidgetMigrator` — version-based prop migration
- `WidgetRenderer` — dynamic dispatch via `renderDynamic()`
- `WidgetContext` — runtime editing state (isEditable, onUpdate, onDelete, displayOptions)

Widget types: `dish`, `dish_to_share`, `image`, `section`, `set_menu_dish`, `set_menu_title`, `text`, `wine`

- Props in `domain/widgets/{type}/{type}_props.dart`
- Definitions in `presentation/widgets/{type}_widget/{type}_widget_definition.dart`
- Each has `*_edit_dialog.dart` for editing

## Real-Time Collaboration

- `MenuSubscriptionRepository` — WebSocket stream of `MenuChangeEvent` (widget create/update/delete)
- `PresenceRepository` — user presence tracking (join, leave, heartbeat, watchActiveUsers)
- `WidgetInstance` editing locks — `editingBy`, `editingSince` fields
- `PresenceBar` widget shows active users; `EditingUserBadge` shows who's editing a widget

## Connectivity

- `ConnectivityRepository` — DNS-probe-based connectivity monitoring (not just network interface)
- `ConnectivityStatus` enum: `online`, `offline`
- Periodic probes: 30s when online, 5s recovery when offline
- `OfflineBanner` / `OfflineErrorPage` UI; `ConnectivityRetryMixin` for auto-retry

## Allergens

UK FSA 14 allergens (`UkAllergen` enum). Dishes carry `List<AllergenInfo>` (structured). `AllergenFormatter` handles UK-compliant display (e.g., `GLUTEN [wheat], MILK, MAY CONTAIN EGGS`).

## State Management

Riverpod with manual `Provider` declarations (not riverpod_generator):

- `repositories_provider.dart` — all repo providers watch `directusDataSourceProvider`
- `usecases_provider.dart` — use case providers
- `widget_registry_provider.dart` — registers all 8 widget types
- `auth_provider.dart` — `AuthNotifier` + `isAdminProvider` (single source of truth for admin check)
- Page-level state: freezed state classes + `Notifier` (e.g., `admin_templates_*`, `admin_sizes_*`, `menu_list_*`, `editor_tree_*`, `menu_collaboration_*`)

## Data Layer

- `DirectusDataSource` wraps `directus_api_manager` package
- `SecureTokenStorage` wraps `flutter_secure_storage`
- DTOs in `data/models/`, mappers in `data/mappers/`
- Mapper pattern: `XxxMapper.toEntity(dto)`, error mapping via `mapDirectusError()`

## Code Generation

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

- Freezed + json_serializable for entities, DTOs, props, states
- Reflectable for `main.reflectable.dart`
- Generated files: `*.freezed.dart`, `*.g.dart`, `*.reflectable.dart`

## Routing

`go_router` — routes in `core/routing/app_router.dart`, constants in `core/routing/app_routes.dart`

- Auth-guarded redirect (unauthenticated → `/login`, non-admin blocked from `/admin/*`)
- All route paths use `AppRoutes` constants (no hardcoded strings)
- Web uses `context.go()` for deep-linking, native uses `context.push()`

## Pages

`login`, `home`, `menu_list`, `menu_editor`, `pdf_preview`, `admin_templates`, `admin_template_creator`, `admin_template_editor`, `admin_sizes`, `settings`

## Testing

```sh
flutter test                    # all tests
flutter test test/unit/         # unit only
flutter test test/widget/       # widget only
```

- Structure mirrors `lib/`: `test/unit/`, `test/widget/`, `test/integration/`
- 218 test files (145 unit, 72 widget, 1 integration), 2319 test cases
- Mocking: `mocktail`
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
