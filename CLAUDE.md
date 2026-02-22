# CLAUDE.md

## Project

OXO Menus — Flutter menu template builder with Directus CMS backend.
SDK >=3.8.0 <4.0.0 | Flutter 3.24.0

## Architecture

Clean Architecture: `core/` → `domain/` → `data/` → `presentation/`

- **core/types/result.dart** — sealed `Result<T, E>` (Success | Failure), railway-oriented error handling
- **core/errors/domain_errors.dart** — sealed `DomainError` hierarchy (InvalidCredentials, TokenExpired, Unauthorized, Network, NetworkUnavailable, NotFound, Validation, Server, Unknown, RateLimit)
- Repositories return `Result<T, DomainError>`, never throw

Detailed references: [domain](.claude/docs/domain.md) | [data](.claude/docs/data.md) | [presentation](.claude/docs/presentation.md) | [testing](.claude/docs/testing.md)

## Domain Model (hierarchy, each level sorted by `index`)

```
Menu → Page → Container → Column → WidgetInstance
```

- `FetchMenuTreeUseCase` builds `MenuTree` with nested freezed value objects: `PageWithContainers`, `ContainerWithColumns`, `ColumnWithWidgets`
- `GeneratePdfUseCase` renders `MenuTree` to PDF client-side (`pdf` package)
- `DuplicateMenuUseCase` deep-copies menu with all children, rollback on failure

## Widget System

Plugin architecture in `domain/widget_system/`:

- `WidgetDefinition<P>` — generic: `parseProps`, `render`, `defaultProps`, `migrate`
- `WidgetRegistry` — O(1) lookup by type string
- `WidgetMigrator` — version-based prop migration
- `WidgetRenderer` — dynamic dispatch via `renderDynamic()`
- `WidgetContext` — runtime editing state (isEditable, onUpdate, onDelete, displayOptions)

Widget types: `dish`, `section`, `text`, `wine`, `image`

- Props in `domain/widgets/{type}/{type}_props.dart`
- Definitions in `presentation/widgets/{type}_widget/{type}_widget_definition.dart`
- Each has `*_edit_dialog.dart` for editing

## Allergens

UK FSA 14 allergens (`UkAllergen` enum). Legacy `List<String>` → `List<AllergenInfo>` migration via `DishProps.effectiveAllergenInfo`. `AllergenFormatter` handles UK-compliant display (e.g., `GLUTEN [wheat], MILK, MAY CONTAIN EGGS`).

## State Management

Riverpod with manual `Provider` declarations (not riverpod_generator):

- `repositories_provider.dart` — all repo providers watch `directusDataSourceProvider`
- `usecases_provider.dart` — use case providers
- `widget_registry_provider.dart` — registers all 5 widget types
- `auth_provider.dart` — `AuthNotifier` + `isAdminProvider` (single source of truth for admin check)
- Page-level state: freezed state classes + `Notifier` (e.g., `admin_templates_*`, `admin_sizes_*`, `menu_list_*`)

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

`go_router` — routes in `core/routing/app_router.dart`

- Auth-guarded redirect (unauthenticated → `/login`, non-admin blocked from `/admin/*`)
- Web uses `context.go()` for deep-linking, native uses `context.push()`

## Pages

`login`, `home`, `menu_list`, `menu_editor` (with `pdf_preview_dialog`), `admin_templates`, `admin_template_creator`, `admin_template_editor`, `admin_sizes`, `settings`

## Testing

```sh
flutter test                    # all tests
flutter test test/unit/         # unit only
flutter test test/widget/       # widget only
```

- Structure mirrors `lib/`: `test/unit/`, `test/widget/`, `test/integration/`
- Mocking: `mocktail`
- CI enforces 75% coverage, `dart format`, `flutter analyze --fatal-infos`

## Environment

```sh
# Local Directus (docker-compose.yml provided)
flutter run --dart-define=DIRECTUS_URL=http://localhost:8055

# Default fallback: http://localhost:8055
```

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
