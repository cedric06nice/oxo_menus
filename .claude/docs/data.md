# Data Layer Reference

Data code is split between `lib/shared/data/` (cross-feature DTOs/mappers/repos and the `DirectusDataSource`) and `lib/features/<feature>/data/` (feature-owned data code). All DTOs except `UserDto` extend `DirectusItem` from `directus_api_manager`.

Three features have a `data/` layer today: `menu`, `collaboration`, `connectivity`. Other features are presentation-only and consume shared/menu repos.

## Shared Data (`lib/shared/data/`)

### Models (`shared/data/models/`)

- **UserDto** (freezed) — `id`, `email`, `firstName?`, `lastName?`, `role?` (flexible: string, Map with `name`, or UUID), `avatar?`, `areas` (M2M junction data)
- **AreaDto** (collection: `area`) — `id`, `name`
- **VersionDto** — version history record reused by menus and other versioned items

### Mappers (`shared/data/mappers/`)

| Mapper | Key Logic |
|--------|-----------|
| `user_mapper.dart` | Flexible role mapping: `admin`/`administrator` → admin; `user`/`standard`/`regular`/UUID → user. Parses M2M junction area data. |
| `area_mapper.dart` | Simple field extraction. |
| `file_mapper.dart` | Maps `DirectusFile` → `ImageFileInfo`. |
| `error_mapper.dart` | `mapDirectusError()` — Directus/network exception → `DomainError`. |

### Repository implementations (`shared/data/repositories/`)

- **AuthRepositoryImpl** — `tryRestoreSession()` returns `TokenExpiredError` if no stored tokens. Adds `requestPasswordReset` / `confirmPasswordReset` flows (Directus password recovery endpoints).
- **AreaRepositoryImpl** — `getAll()` over the `area` collection.
- **FileRepositoryImpl** — `listImageFiles()` filters by `type` starting with `image/`, capped at 100. `upload()` returns the new file ID. `downloadFile()` returns raw bytes.
- **AssetLoaderRepositoryImpl** — wraps Flutter's `rootBundle.load()` so the domain stays framework-agnostic.

### Data Sources (`shared/data/datasources/`)

#### `directus_data_source.dart` — `DirectusDataSource`

Wraps `directus_api_manager` for all Directus API calls.

**Auth flow**

- `login()` → `_apiManager.loginDirectusUser()` → saves tokens → fetches user with expanded role.
- `tryRestoreSession()` → checks stored tokens → `refreshSession()` if present.
- `refreshSession()` → POST `/auth/refresh` → updates tokens.
- `_fetchUserWithRole()` → GET `/users/me?fields=id,email,first_name,last_name,avatar,role.name`.
- Clears tokens on 401.

**CRUD**

- `getItem<T>(id, {fields})`, `getItems<T>({filter, fields, sort, limit, offset})` — uses reflectable for collection resolution.
- `createItem<T>(item)`, `updateItem<T>(item)`, `deleteItem<T>(id)`.
- Filter conversion supports 18 operators (`_eq`, `_neq`, `_lt`, `_contains`, `_in`, …).

**Files**

- `uploadFile(bytes, filename)` → multipart POST to `/files` → returns file ID.
- `listFiles({filter, fields, sort, limit})` → queries `DirectusFile`.
- `downloadFileBytes(fileId)` → GET `/assets/{fileId}` → raw bytes.

**WebSocket**

- `startSubscription(collection, filter)` → `DirectusWebSocketSubscription`.
- `stopSubscription(subscription)`.

#### `secure_token_storage.dart` — `SecureTokenStorage`

Wraps `flutter_secure_storage`. Methods: `saveTokens()`, `getAccessToken()`, `getRefreshToken()`, `hasTokens()`, `saveRefreshToken()`, `clearTokens()`.

## Menu Feature (`lib/features/menu/data/`)

### Models (`features/menu/data/models/`)

- **MenuDto** (collection: `menu`) — `name`, `version`, `status`, `dateCreated`, `dateUpdated`, `userUpdated`, `styleJson` (Map), `allowedWidgetTypes` (`List<String>`), `displayOptionsJson` (Map), `area?`, `versions?`, `pages?`, `size?`
- **PageDto** (collection: `page`) — `index`, `status`, `type` (header|footer|content), timestamps, `userUpdated`, `menu?`, `containers?`
- **ContainerDto** (collection: `container`) — `index`, `status`, timestamps, `userUpdated`, `direction?`, `styleJson` (Map), `page?`, `columns?`
- **ColumnDto** (collection: `column`) — `index`, `width` (num), `isDroppable` (default true), timestamps, `userUpdated`, `styleJson`, `container?`, `widgets?`
- **WidgetDto** (collection: `widget`) — `index`, `typeKey`, `version`, `status?`, `isTemplate` (false), timestamps, `userUpdated`, `styleJson`, `propsJson`, `editingBy?`, `editingSince?`, `column?`
- **SizeDto** (collection: `size`) — page size record
- **MenuBundleDto** — exportable bundle for a menu

### Mappers (`features/menu/data/mappers/`)

| Mapper | Key Logic |
|--------|-----------|
| `menu_mapper.dart` | Parses status enum, style, display options, page size; maps area relationship. |
| `page_mapper.dart` | Parses `PageType` (default: content). |
| `container_mapper.dart` | Splits/merges layout + style into a single `styleJson`. |
| `column_mapper.dart` | Converts `width` num → double; no `flex` field in DTO. |
| `widget_mapper.dart` | Parses props JSON, `WidgetStyle`, and editing-lock fields. |
| `size_mapper.dart` | Standard field extraction for `Size`. |
| `style_config_mapper.dart` | Shared between menu/page/container/column: fonts, colors, per-side margin/padding, borderType. |
| `display_options_mapper.dart` | `showPrices` / `showAllergens` defaults true. |
| `menu_bundle_mapper.dart` | Maps `MenuBundleDto` ↔ `MenuBundle`. |

### Repository implementations (`features/menu/data/repositories/`)

- **MenuRepositoryImpl** — `getById` fetches the full tree with nested field specs. `listAll` supports area-ID filtering and `onlyPublished`.
- **PageRepositoryImpl** — CRUD and `reorder()` with sibling shifting.
- **ContainerRepositoryImpl** — CRUD; `reorder()` shifts siblings within the page; `moveTo()` moves a container to a different page.
- **ColumnRepositoryImpl** — CRUD; `width` defaults to 100 if null on create.
- **WidgetRepositoryImpl** — CRUD; `reorder()` shifts indices within column; `moveTo()` handles cross-column moves; `lockForEditing` / `unlockEditing` write the editing-lock fields.
- **SizeRepositoryImpl** — CRUD over `size` collection.
- **MenuBundleRepositoryImpl** — CRUD + publish flow over the bundle collection.

## Collaboration Feature (`lib/features/collaboration/data/`)

- **`models/presence_dto.dart`** — `PresenceDto` (collection: `menu_presence`): `userId`, `menuId`, `lastSeen`, `userName?`, `userAvatar?`.
- **`mappers/presence_mapper.dart`** — `PresenceDto` ↔ `MenuPresence`.
- **`repositories/menu_subscription_repository_impl.dart`** — WebSocket subscription for widget changes via nested-relation filter.
- **`repositories/presence_repository_impl.dart`** — WebSocket presence tracking; `joinMenu` / `leaveMenu` / `heartbeat` + `watchActiveUsers` stream.

## Connectivity Feature (`lib/features/connectivity/data/`)

- **`repositories/connectivity_repository_impl.dart`** — DNS probe (dns.google, 3 attempts). Periodic checks: 30 s when online, 5 s recovery when offline. Emits a distinct status stream.

## Error Code Mapping (`mapDirectusError`)

| Directus Code | DomainError |
|---|---|
| `INVALID_CREDENTIALS` | `InvalidCredentialsError` |
| `TOKEN_EXPIRED` | `TokenExpiredError` |
| `FORBIDDEN`, `NOT_AUTHENTICATED` | `UnauthorizedError` |
| `NOT_FOUND` | `NotFoundError` |
| `INVALID_QUERY`, `RECORD_NOT_UNIQUE`, `INVALID_FOREIGN_KEY` | `ValidationError` |
| `REQUESTS_EXCEEDED` | `RateLimitError` |
| `CREATE_FAILED`, `UPDATE_FAILED`, `DELETE_FAILED`, `LOGIN_ERROR` | `ServerError` |
| Network exceptions (no DNS / socket) | `NetworkError` / `NetworkUnavailableError` |
| Default | `UnknownError` |

## Mapper Pattern

- DTO → entity: `XxxMapper.toEntity(dto)`
- Entity → DTO (when needed): `XxxMapper.toDto(entity)`
- Input DTOs (freezed) → Directus payload: `toCreateDto(input)` → Map, `toUpdateDto(input)` → Map containing only non-null fields
- Repository impls always wrap calls in try/catch, run exceptions through `mapDirectusError()`, and return `Result<T, DomainError>`.
