# Data Layer Reference

## DTOs (`lib/data/models/`)

All DTOs extend `DirectusItem` from `directus_api_manager` (except `UserDto` which uses freezed).

### MenuDto (collection: `menu`)
`name`, `version`, `status`, `dateCreated`, `dateUpdated`, `userUpdated`, `styleJson` (Map), `allowedWidgetTypes` (List\<String\>), `displayOptionsJson` (Map), `area` (AreaDto?), `versions` (List\<VersionDto\>?), `pages` (List\<PageDto\>?), `size` (SizeDto?)

### PageDto (collection: `page`)
`index`, `status`, `type` (header|footer|content), `dateCreated`, `dateUpdated`, `userUpdated`, `menu` (MenuDto?), `containers` (List\<ContainerDto\>?)

### ContainerDto (collection: `container`)
`index`, `status`, `dateCreated`, `dateUpdated`, `userUpdated`, `direction?`, `styleJson` (Map), `page` (PageDto?), `columns` (List\<ColumnDto\>?)

### ColumnDto (collection: `column`)
`index`, `width` (num), `isDroppable` (default: true), `dateCreated`, `dateUpdated`, `userUpdated`, `styleJson` (Map), `container` (ContainerDto?), `widgets` (List\<WidgetDto\>?)

### WidgetDto (collection: `widget`)
`index`, `typeKey`, `version`, `status?`, `isTemplate` (default: false), `dateCreated`, `dateUpdated`, `userUpdated`, `styleJson` (Map), `propsJson` (Map), `editingBy` (String?), `editingSince` (DateTime?), `column` (ColumnDto?)

### UserDto (freezed)
`id`, `email`, `firstName?`, `lastName?`, `role?` (flexible: string, Map with `name`, or UUID), `avatar?`, `areas` (M2M junction data)

### SizeDto (collection: `size`)
`name`, `width`, `height`, `status`, `direction`

### AreaDto (collection: `area`)
`name`, `dateCreated`, `dateUpdated`, `userUpdated`, `menus` (List\<MenuDto\>?)

### VersionDto (collection: `version`)
`snapshotJson` (Map), `dateCreated`, `dateUpdated`, `userUpdated`, `menu` (MenuDto?)

### PresenceDto (collection: `menu_presence`)
`userId`, `menuId`, `lastSeen`, `userName?`, `userAvatar?`

## Mappers (`lib/data/mappers/`)

Pattern: `XxxMapper.toEntity(dto)` for DTO→Entity, `toDto(entity)` for reverse. Input mappers: `toCreateDto(input)` → Map, `toUpdateDto(input)` → Map (only non-null fields).

| Mapper | Key Logic |
|--------|-----------|
| MenuMapper | Parses status enum, style, display options, page size. Maps area relationship |
| PageMapper | Parses PageType enum (default: content) |
| ContainerMapper | Splits/merges layout+style into single `styleJson` |
| ColumnMapper | Converts width num→double, no `flex` in DTO |
| WidgetMapper | Parses props JSON, WidgetStyle, and editing lock fields |
| UserMapper | Flexible role mapping: 'admin'/'administrator'→admin, 'user'/'standard'/'regular'/UUID→user. Parses M2M junction area data |
| AreaMapper | Simple id+name mapping |
| SizeMapper | Parses status enum |
| StyleConfigMapper | Shared: fonts, colors, margin/padding (per-side), borderType |
| DisplayOptionsMapper | showPrices/showAllergens with defaults (true) |
| FileMapper | Extracts id, title, type from file metadata |
| PresenceMapper | Maps PresenceDto to MenuPresence entity |
| ErrorMapper | `mapDirectusError()` — maps Directus/network exceptions to DomainError |

### Error Code Mapping (`mapDirectusError`)
| Directus Code | DomainError |
|---------------|-------------|
| INVALID_CREDENTIALS | InvalidCredentialsError |
| TOKEN_EXPIRED | TokenExpiredError |
| FORBIDDEN, NOT_AUTHENTICATED | UnauthorizedError |
| NOT_FOUND | NotFoundError |
| INVALID_QUERY, RECORD_NOT_UNIQUE, INVALID_FOREIGN_KEY | ValidationError |
| REQUESTS_EXCEEDED | RateLimitError |
| CREATE/UPDATE/DELETE_FAILED, LOGIN_ERROR | ServerError |
| Default | UnknownError |

## Repository Implementations (`lib/data/repositories/`)

All follow the same pattern: inject `DirectusDataSource`, try-catch with `mapDirectusError()`, return `Result<T, DomainError>`.

### Notable Implementation Details
- **MenuRepositoryImpl**: `getById` fetches full tree (pages→containers→columns→widgets) with nested field specifications. `listAll` supports area ID filtering for non-admin users
- **WidgetRepositoryImpl**: `reorder()` shifts indices within column; `moveTo()` handles cross-column moves with index adjustments. `lockForEditing`/`unlockEditing` for editing locks
- **ContainerRepositoryImpl**: `moveTo()` moves container to different page
- **AuthRepositoryImpl**: `tryRestoreSession()` returns `TokenExpiredError` if no stored tokens
- **ColumnRepositoryImpl**: Width defaults to 100 if null on create
- **FileRepositoryImpl**: `listImageFiles()` filters by `type` starts with `image/`, limited to 100, sorted by `-uploaded_on`
- **MenuSubscriptionRepositoryImpl**: WebSocket subscription for widget changes via nested relation filter
- **PresenceRepositoryImpl**: WebSocket presence tracking with `joinMenu`/`leaveMenu`/`heartbeat` + `watchActiveUsers` stream
- **ConnectivityRepositoryImpl**: DNS probe (dns.google) with 3 attempts; periodic 30s online, 5s recovery offline; distinct stream
- **AssetLoaderRepositoryImpl**: Wrapper for Flutter's `rootBundle.load()` — keeps domain framework-agnostic

## Data Sources (`lib/data/datasources/`)

### DirectusDataSource
Wraps `directus_api_manager` for all Directus API calls.

**Auth flow:**
- `login()` → `_apiManager.loginDirectusUser()` → saves tokens → fetches user with expanded role
- `tryRestoreSession()` → checks stored tokens → `refreshSession()` if present
- `refreshSession()` → POST `/auth/refresh` → updates tokens
- `_fetchUserWithRole()` → GET `/users/me?fields=id,email,first_name,last_name,avatar,role.name`
- Clears tokens on 401

**CRUD:**
- `getItem<T>(id, {fields})`, `getItems<T>({filter, fields, sort, limit, offset})` — uses reflectable for collection resolution
- `createItem<T>(item)`, `updateItem<T>(item)`, `deleteItem<T>(id)`
- Filter conversion: supports 18 operators (`_eq`, `_neq`, `_lt`, `_contains`, `_in`, etc.)

**Files:**
- `uploadFile(bytes, filename)` → multipart POST to `/files` → returns file ID
- `listFiles({filter, fields, sort, limit})` → queries `DirectusFile` collection
- `downloadFileBytes(fileId)` → GET `/assets/{fileId}` → raw bytes

**WebSocket:**
- `startSubscription(collection, filter)` → `DirectusWebSocketSubscription`
- `stopSubscription(subscription)`

### SecureTokenStorage
Wraps `flutter_secure_storage`. Methods: `saveTokens()`, `getAccessToken()`, `getRefreshToken()`, `hasTokens()`, `saveRefreshToken()`, `clearTokens()`.

### DirectusException
Custom exception: `code` (String), `message` (String). Consumed by `mapDirectusError()`.
