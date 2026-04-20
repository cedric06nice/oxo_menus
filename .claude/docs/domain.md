# Domain Layer Reference

## Entities (`lib/domain/entities/`)

### Core Hierarchy

**Menu** — `id`, `name`, `status` (Status enum), `version`, `dateCreated`, `dateUpdated`, `userCreated`, `userUpdated`, `styleConfig` (StyleConfig?), `pageSize` (PageSize?), `area` (Area?), `displayOptions` (MenuDisplayOptions?), `allowedWidgetTypes` (List\<String\>)

**Page** — `id`, `menuId`, `name`, `index`, `type` (PageType: content|header|footer), `dateCreated`, `dateUpdated`

**Container** — `id`, `pageId`, `index`, `name?`, `layout` (LayoutConfig?), `styleConfig?`, `dateCreated`, `dateUpdated`

**Column** — `id`, `containerId`, `index`, `flex?`, `width?`, `styleConfig?`, `isDroppable` (default: true), `dateCreated`, `dateUpdated`

**WidgetInstance** — `id`, `columnId`, `type` (String), `version`, `index`, `props` (Map\<String, dynamic\>), `style` (WidgetStyle?), `isTemplate` (default: false), `dateCreated`, `dateUpdated`, `editingBy` (String?), `editingSince` (DateTime?)

### Supporting Entities

- **User** — `id`, `email`, `firstName?`, `lastName?`, `role` (UserRole: admin|user), `avatar?`, `areas` (List\<Area\>)
- **Area** — `id` (int), `name` (String)
- **Size** — `id`, `name`, `width`, `height`, `status`, `direction`
- **ImageFileInfo** — `id`, `title?`, `type?`

### Configuration Types

- **Status**: `draft`, `published`, `archived`
- **BorderType**: `none`, `plainThin`, `plainThick`, `doubleOffset`, `dropShadow` (with labels)
- **PageType**: `content`, `header`, `footer`
- **ConnectivityStatus**: `online`, `offline`
- **StyleConfig**: fontFamily, fontSize, primaryColor, secondaryColor, backgroundColor, margin/padding (per-side), borderType
- **LayoutConfig**: direction, alignment, spacing
- **PageSize**: name, width, height
- **MenuDisplayOptions**: showPrices (default: true), showAllergens (default: true)
- **WidgetStyle**: fontFamily, fontSize, color, backgroundColor, border, padding

### Real-Time Entities

- **MenuPresence** — `id`, `userId`, `menuId`, `lastSeen`, `userName?`, `userAvatar?`
- **MenuChangeEvent** (sealed) → **WidgetChangedEvent**: `eventType`, `data?`, `ids?`

## Repositories (`lib/domain/repositories/`)

All return `Result<T, DomainError>`, never throw. Input DTOs are freezed classes.

### AuthRepository
`login(email, password)`, `logout()`, `getCurrentUser()`, `refreshSession()`, `tryRestoreSession()`

### MenuRepository
`create(CreateMenuInput)`, `listAll({onlyPublished, areaIds})`, `getById(id)`, `update(UpdateMenuInput)`, `delete(id)`

### PageRepository
`create(CreatePageInput)`, `getAllForMenu(menuId)`, `getById(id)`, `update(UpdatePageInput)`, `delete(id)`, `reorder(pageId, newIndex)`

### ContainerRepository
`create(CreateContainerInput)`, `getAllForPage(pageId)`, `getById(id)`, `update(UpdateContainerInput)`, `delete(id)`, `reorder(containerId, newIndex)`, `moveTo(containerId, newPageId, index)`

### ColumnRepository
`create(CreateColumnInput)`, `getAllForContainer(containerId)`, `getById(id)`, `update(UpdateColumnInput)`, `delete(id)`, `reorder(columnId, newIndex)`

### WidgetRepository
`create(CreateWidgetInput)`, `getAllForColumn(columnId)`, `getById(id)`, `update(UpdateWidgetInput)`, `delete(id)`, `reorder(widgetId, newIndex)`, `moveTo(widgetId, newColumnId, index)`, `lockForEditing(widgetId, userId)`, `unlockEditing(widgetId)`

### SizeRepository
`getAll()`, `getById(id)`, `create(CreateSizeInput)`, `update(UpdateSizeInput)`, `delete(id)`

### AreaRepository
`getAll()` → List\<Area\>

### FileRepository
`upload(bytes, filename)` → file ID, `listImageFiles()`, `downloadFile(fileId)` → bytes

### MenuSubscriptionRepository
`subscribeToMenuChanges(menuId)` → Stream\<MenuChangeEvent\>, `unsubscribe(menuId)`

### PresenceRepository
`joinMenu(menuId, userId, {userName?, userAvatar?})`, `leaveMenu(menuId, userId)`, `heartbeat(menuId, userId)`, `getActiveUsers(menuId)`, `watchActiveUsers(menuId)` → Stream, `unsubscribePresence(menuId)`

### ConnectivityRepository
`checkConnectivity()` → ConnectivityStatus, `watchConnectivity()` → Stream\<ConnectivityStatus\>

### AssetLoaderRepository
`loadAsset(assetPath)` → ByteData — pure, framework-agnostic font/asset loading

## Use Cases (`lib/domain/usecases/`)

### FetchMenuTreeUseCase
Fetches complete `MenuTree` (menu + all pages/containers/columns/widgets sorted by index). Separates content, header, and footer pages. Parallel fetches at each hierarchy level.

**Output:** `MenuTree` → `PageWithContainers` → `ContainerWithColumns` → `ColumnWithWidgets`

### GeneratePdfUseCase
Renders `MenuTree` to PDF bytes in background isolate. Pre-fetches images from `FileRepository`. Supports all 8 widget types. Respects `MenuDisplayOptions` for price/allergen visibility.

### DuplicateMenuUseCase
Deep-copies a menu with all children. Appends " (copy)" to name. Creates as draft. Resolves pageSize to sizeId. Implements rollback on failure (tracks all created IDs).

### ListTemplatesUseCase
Lists all templates (menus) with optional status filtering. Fetches via `menuRepository.listAll(onlyPublished: false)`, filters by `status.name` if filter is not `null` or `'all'`.

### ListSizesUseCase
Lists sizes with optional status filtering. Fetches via `sizeRepository.getAll()`, filters by `status.name`.

### ListImageFilesUseCase
Lists all image files. Thin wrapper around `fileRepository.listImageFiles()`.

### PdfDocumentBuilder
Isolate-safe builder: `buildDocument(menuTree, baseFontData, boldFontData, imageCache)`. Renders containers as columns or multi-column grids. Supports header/footer pages.

### PdfStyleResolver
Resolves `StyleConfig` + `PageSize` → PDF values. Page formats (A4, Letter, Legal, A3, custom). Per-side margin/padding. Border rendering (5 types). Base font size (default: 11.0).

## Widget System (`lib/domain/widget_system/`)

### WidgetDefinition\<P\>
Generic definition: `type`, `version`, `parseProps`, `render`, `defaultProps`, `migrate?`, `displayName?`, `materialIcon?`, `cupertinoIcon?`. Method `renderDynamic()` for type-erased dispatch.

### WidgetRegistry
`register<P>(definition)`, `getDefinition(type)`, `registeredTypes`, `isRegistered(type)`, `count`

### WidgetMigrator
Static: `migrate(instance, definition)`, `needsMigration(instance, definition)` — compares versions.

### WidgetContext
Runtime state: `isEditable`, `onUpdate`, `onDelete`, `onEditStarted?`, `onEditEnded?`, `displayOptions?`

## Widget Props (`lib/domain/widgets/`)

### DishProps
`name`, `price` (£), `description?`, `calories?`, `allergenInfo` (List\<AllergenInfo\>), `dietary` (DietaryType?). `displayName` → uppercase + dietary abbreviation.

### WineProps
`name`, `price` (£), `description?`, `vintage?`, `dietary?`, `containsSulphites` (default: false). `displayName` → uppercase + dietary abbreviation.

### SectionProps
`title`, `uppercase` (default: false), `showDivider` (default: true)

### TextProps
`text`, `fontSize` (default: 10.0), `align` (left|center|right), `bold` (false), `italic` (false)

### ImageProps
`fileId`, `align` (left|center|right), `fit` (contain|cover|fill|fitwidth|fitheight), `width?`, `height?`

### DishToShareProps
`name`, `price` (£), `description?`, `calories?`, `allergens`, `allergenInfo`, `dietary?`, `servings?`

### SetMenuDishProps
`name`, `description?`, `calories?`, `allergens`, `allergenInfo`, `dietary?`, `hasSupplement` (false), `supplementPrice?`

### SetMenuTitleProps
`title`, `subtitle?`, `uppercase` (false), `priceLabel1?`, `price1?`, `priceLabel2?`, `price2?`

### DietaryType
`vegetarian` → "(V)", `vegan` → "(Ve)"

## Allergen System (`lib/domain/allergens/`)

### UkAllergen
14 FSA allergens: celery, gluten, crustaceans, eggs, fish, lupin, milk, molluscs, mustard, nuts, peanuts, sesame, soya, sulphites. Properties: `displayName`, `shortName` (CAPITALS), `supportsDetails` (gluten, nuts).

### AllergenInfo (freezed)
`allergen`, `mayContain` (false), `details?`.

### AllergenFormatter
`formatForDisplay()` → UK format: definite first (alphabetical, CAPS, details in brackets), then "MAY CONTAIN" group.
