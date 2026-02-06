# CLAUDE.md

## Project

OXO Menus — Flutter menu template builder with Directus CMS backend.
SDK >=3.8.0 <4.0.0 | Flutter 3.24.0

## Architecture

Clean Architecture: `core/` → `domain/` → `data/` → `presentation/`

- **core/types/result.dart** — sealed `Result<T, E>` (Success | Failure), railway-oriented error handling
- **core/errors/domain_errors.dart** — sealed `DomainError` hierarchy (InvalidCredentials, TokenExpired, Unauthorized, Network, NetworkUnavailable, NotFound, Validation, Server, Unknown)
- Repositories return `Result<T, DomainError>`, never throw

## Domain Model (hierarchy, each level sorted by `index`)

```
Menu → Page → Container → Column → WidgetInstance
```

- `FetchMenuTreeUseCase` builds `MenuTree` with nested freezed value objects: `PageWithContainers`, `ContainerWithColumns`, `ColumnWithWidgets`
- `GeneratePdfUseCase` renders `MenuTree` to PDF client-side (`pdf` package)

## Widget System

Plugin architecture in `domain/widget_system/`:
- `WidgetDefinition<P>` — generic: `parseProps`, `render`, `defaultProps`, `migrate`
- `WidgetRegistry` — O(1) lookup by type string
- `WidgetMigrator` — version-based prop migration
- `WidgetRenderer` — dynamic dispatch via `renderDynamic()`
- `WidgetContext` — runtime editing state (isEditable, onUpdate, onDelete)

Current widget types: `dish`, `section`, `text`
- Props in `domain/widgets/{type}/{type}_props.dart`
- Definitions in `presentation/widgets/{type}_widget/{type}_widget_definition.dart`
- Each has `*_edit_dialog.dart` for editing

## Allergens

UK FSA 14 allergens (`UkAllergen` enum). Legacy `List<String>` → `List<AllergenInfo>` migration via `DishProps.effectiveAllergenInfo`. `AllergenFormatter` handles display.

## State Management

Riverpod with manual `Provider` declarations (not riverpod_generator for providers):
- `repositories_provider.dart` — all repo providers watch `directusDataSourceProvider`
- `usecases_provider.dart` — use case providers
- `widget_registry_provider.dart`
- Page-level state: freezed state classes + `Notifier` (e.g., `admin_templates_*`)

## Data Layer

- `DirectusDataSource` wraps `directus_api_manager` package
- DTOs in `data/models/`, mappers in `data/mappers/`
- Mapper pattern: `XxxMapper.toEntity(dto)`, error mapping via `mapDirectusError()`
- Auth: `flutter_secure_storage` for tokens

## Code Generation

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

- Freezed + json_serializable for entities, DTOs, props, states
- Reflectable for `main.reflectable.dart`
- Generated files: `*.freezed.dart`, `*.g.dart`, `*.reflectable.dart`

## Routing

`go_router` — routes in `core/routing/app_router.dart`

## Pages

`login`, `home`, `menu_list`, `menu_editor` (with `pdf_preview_dialog`), `admin_templates`, `admin_template_creator`, `admin_template_editor`, `settings`

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

All production code in this repository (Dart, Flutter, or any other language) MUST be written using strict Test-Driven Development following the Red → Green → Refactor cycle:

1. **RED** — Write a failing test first. The test must target the intended behavior and must fail for the right reason. Run it and confirm the failure before proceeding.
2. **GREEN** — Write the minimum production code required to make the failing test pass. Nothing more.
3. **REFACTOR** — Improve the code (production and test) while keeping all tests green. No new behavior is added in this step.

### Prohibitions

- Writing or modifying production code without a corresponding failing test **first** is forbidden.
- Skipping the red step (e.g., writing a test that already passes) is forbidden.
- Writing production code "to be tested later" is forbidden.
- Generating a batch of production code and then backfilling tests afterward is forbidden.

### Scope

- Applies to **all languages and all files** in this repository.
- Applies to new features, bug fixes, and refactors that change behavior.
- The only exceptions are non-behavioral changes: documentation, configuration, code generation output, and static analysis fixes.

### Enforcement

Treat this rule as a hard constraint, not guidance. If a task cannot be completed under TDD (e.g., the user explicitly opts out), state the conflict and ask for confirmation before proceeding.

## Conventions

- Entities: freezed, named fields, `const factory`, private `_` constructor
- Repos: abstract in `domain/repositories/`, impl in `data/repositories/` suffixed `Impl`
- Use cases: class with `execute()` method, injected repos via constructor
- Providers: manual `final xxxProvider = Provider<Xxx>((ref) { ... });`
- Currency: GBP (£)
