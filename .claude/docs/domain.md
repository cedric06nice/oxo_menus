# Domain Layer Reference

Domain code is split between `lib/shared/domain/` (cross-feature entities, repos, use cases) and `lib/features/<feature>/domain/` (feature-owned domain code). All repositories return `Result<T, DomainError>` and never throw.

## Shared Domain (`lib/shared/domain/`)

### Entities (`shared/domain/entities/`)

- **User** — `id`, `email`, `firstName?`, `lastName?`, `role` (`UserRole`: admin|user), `avatar?`, `areas` (`List<Area>`)
- **Area** — `id` (int), `name` (String)
- **ImageFileInfo** — `id`, `title?`, `type?`
- **Status** — `draft`, `published`, `archived`
- **BorderType** — `none`, `plainThin`, `plainThick`, `doubleOffset`, `dropShadow` (with labels)
- **VerticalAlignment** — vertical alignment enum used by widget styles

### Repositories (`shared/domain/repositories/`)

- **AuthRepository** — `login`, `logout`, `getCurrentUser`, `refreshSession`, `tryRestoreSession`, `requestPasswordReset(email, {resetUrl})`, `confirmPasswordReset({token, password})`
- **AreaRepository** — `getAll()` → `List<Area>`
- **FileRepository** — `upload(bytes, filename)` → file ID, `listImageFiles()`, `downloadFile(fileId)` → bytes
- **AssetLoaderRepository** — `loadAsset(assetPath)` → `ByteData` (pure, framework-agnostic font/asset loading)

### Use Cases (`shared/domain/usecases/`)

- **ListImageFilesUseCase** — thin wrapper around `FileRepository.listImageFiles()`

## Menu Feature (`lib/features/menu/domain/`)

### Hierarchy entities (`features/menu/domain/entities/`)

```
Menu → Page → Container → Column → WidgetInstance
```

- **Menu** — `id`, `name`, `status`, `version`, `dateCreated`, `dateUpdated`, `userCreated`, `userUpdated`, `styleConfig?` (`StyleConfig`), `pageSize?` (`PageSize`), `area?`, `displayOptions?` (`MenuDisplayOptions`), `allowedWidgetTypes` (`List<String>`)
- **Page** — `id`, `menuId`, `name`, `index`, `type` (`PageType`: content|header|footer), `dateCreated`, `dateUpdated`
- **Container** — `id`, `pageId`, `index`, `name?`, `layout?` (`LayoutConfig`), `styleConfig?`, `dateCreated`, `dateUpdated`
- **Column** — `id`, `containerId`, `index`, `flex?`, `width?`, `styleConfig?`, `isDroppable` (default: true), `dateCreated`, `dateUpdated`
- **WidgetInstance** — `id`, `columnId`, `type` (String), `version`, `index`, `props` (`Map<String, dynamic>`), `style?` (`WidgetStyle`), `isTemplate` (default: false), `dateCreated`, `dateUpdated`, `editingBy?`, `editingSince?`
- **Size** — `id`, `name`, `width`, `height`, `status`, `direction`
- **MenuBundle** — `id`, `menuId`, `name`, `status`, `version`, …  (publishable export bundle for a menu)

### Configuration types (also under `features/menu/domain/entities/`)

- **StyleConfig** — fontFamily, fontSize, primaryColor, secondaryColor, backgroundColor, per-side margin/padding, borderType
- **LayoutConfig** — direction, alignment, spacing
- **PageSize** — name, width, height
- **MenuDisplayOptions** — `showPrices` (true), `showAllergens` (true)
- **WidgetStyle** — fontFamily, fontSize, color, backgroundColor, border, padding

### Repositories (`features/menu/domain/repositories/`)

- **MenuRepository** — `create(CreateMenuInput)`, `listAll({onlyPublished, areaIds})`, `getById(id)`, `update(UpdateMenuInput)`, `delete(id)`
- **PageRepository** — `create(CreatePageInput)`, `getAllForMenu(menuId)`, `getById(id)`, `update(UpdatePageInput)`, `delete(id)`, `reorder(pageId, newIndex)`
- **ContainerRepository** — `create(CreateContainerInput)`, `getAllForPage(pageId)`, `getById(id)`, `update(UpdateContainerInput)`, `delete(id)`, `reorder(containerId, newIndex)`, `moveTo(containerId, newPageId, index)`
- **ColumnRepository** — `create(CreateColumnInput)`, `getAllForContainer(containerId)`, `getById(id)`, `update(UpdateColumnInput)`, `delete(id)`, `reorder(columnId, newIndex)`
- **WidgetRepository** — `create(CreateWidgetInput)`, `getAllForColumn(columnId)`, `getById(id)`, `update(UpdateWidgetInput)`, `delete(id)`, `reorder(widgetId, newIndex)`, `moveTo(widgetId, newColumnId, index)`, `lockForEditing(widgetId, userId)`, `unlockEditing(widgetId)`
- **SizeRepository** — `getAll()`, `getById(id)`, `create(CreateSizeInput)`, `update(UpdateSizeInput)`, `delete(id)`
- **MenuBundleRepository** — CRUD + publish for `MenuBundle`

### Use Cases (`features/menu/domain/usecases/`)

- **FetchMenuTreeUseCase** — fetches complete `MenuTree` (menu + all pages/containers/columns/widgets sorted by index). Separates content, header, footer pages. Parallel fetches at each hierarchy level. Output graph: `MenuTree` → `PageWithContainers` → `ContainerWithColumns` → `ColumnWithWidgets`.
- **GeneratePdfUseCase** — renders `MenuTree` to PDF bytes in a background isolate. Pre-fetches images from `FileRepository`. Supports all 8 widget types. Respects `MenuDisplayOptions`.
- **DuplicateMenuUseCase** — deep-copies a menu with all children. Appends " (copy)", creates as draft. Resolves pageSize → sizeId. Tracks created IDs and rolls back on failure.
- **DuplicateContainerUseCase** — deep-copies a single container (with columns + widgets) within a page.
- **ReorderContainerUseCase** — moves a container to a new index, shifting siblings.
- **ListTemplatesUseCase** — `menuRepository.listAll(onlyPublished: false)` filtered by status.
- **ListSizesUseCase** — `sizeRepository.getAll()` filtered by status.
- **PdfDocumentBuilder** — isolate-safe `buildDocument(menuTree, baseFontData, boldFontData, imageCache)`. Renders containers as columns or multi-column grids, with header/footer page support.
- **PdfStyleResolver** — resolves `StyleConfig` + `PageSize` → PDF values. Page formats (A4, Letter, Legal, A3, custom). Per-side margin/padding. 5 border render styles. Default base font size 11.0.
- **MenuBundle use cases** — `Create…`, `Get…`, `Update…`, `Delete…`, `List…`, `PublishMenuBundleUseCase`, `PublishBundlesForMenuUseCase` (publish flow for exportable menus).

## Collaboration Feature (`lib/features/collaboration/domain/`)

### Entities (`collaboration/domain/entities/`)

- **MenuPresence** — `id`, `userId`, `menuId`, `lastSeen`, `userName?`, `userAvatar?`
- **MenuChangeEvent** (sealed) → **WidgetChangedEvent** with `eventType`, `data?`, `ids?`

### Repositories (`collaboration/domain/repositories/`)

- **MenuSubscriptionRepository** — `subscribeToMenuChanges(menuId)` → `Stream<MenuChangeEvent>`, `unsubscribe(menuId)`
- **PresenceRepository** — `joinMenu(menuId, userId, {userName?, userAvatar?})`, `leaveMenu(menuId, userId)`, `heartbeat(menuId, userId)`, `getActiveUsers(menuId)`, `watchActiveUsers(menuId)` → `Stream`, `unsubscribePresence(menuId)`

`WidgetInstance.editingBy` / `WidgetInstance.editingSince` (defined on the menu entity) are the per-widget editing locks driven by this feature.

## Connectivity Feature (`lib/features/connectivity/domain/`)

- **ConnectivityStatus** (`entities/connectivity_status.dart`) — `online`, `offline`
- **ConnectivityRepository** (`repositories/connectivity_repository.dart`) — `checkConnectivity()` → `ConnectivityStatus`, `watchConnectivity()` → `Stream<ConnectivityStatus>` (DNS-probe based; periodic 30 s online, 5 s recovery offline)

## Allergens Feature (`lib/features/allergens/domain/`)

- **UkAllergen** — UK FSA 14 allergens (`celery`, `gluten`, `crustaceans`, `eggs`, `fish`, `lupin`, `milk`, `molluscs`, `mustard`, `nuts`, `peanuts`, `sesame`, `soya`, `sulphites`). Properties: `displayName`, `shortName` (CAPS), `supportsDetails` (`gluten`, `nuts`).
- **AllergenInfo** (freezed) — `allergen`, `mayContain` (default false), `details?`
- **AllergenDetailOptions** — option lists for allergens that support details (e.g. wheat/oats for gluten)
- **AllergenFormatter.formatForDisplay()** — UK display: definite first (alphabetical, CAPS, details in brackets), then `MAY CONTAIN` group → e.g. `GLUTEN [wheat], MILK, MAY CONTAIN EGGS`

## Widget System (`lib/features/widget_system/domain/`)

### Plugin core (`widget_system/domain/`)

- **WidgetDefinition\<P\>** (`widget_definition.dart`) — `type`, `version`, `parseProps`, `render`, `defaultProps`, `migrate?`, `displayName?`, `materialIcon?`, `cupertinoIcon?`. `renderDynamic()` for type-erased dispatch. Also defines **WidgetContext** — runtime state (`isEditable`, `onUpdate`, `onDelete`, `onEditStarted?`, `onEditEnded?`, `displayOptions?`).
- **WidgetRegistry** (`widget_registry.dart`) — `register<P>(definition)`, `getDefinition(type)`, `registeredTypes`, `isRegistered(type)`, `count` (O(1) lookup).
- **WidgetMigrator** (`widget_migrator.dart`) — `migrate(instance, definition)`, `needsMigration(instance, definition)` (compares versions).
- **WidgetTypeConfig** (`entities/widget_type_config.dart`) — per-type configuration metadata.

### Widget props (`widget_system/domain/widgets/<type>/<type>_props.dart`)

8 widget types: `dish`, `dish_to_share`, `image`, `section`, `set_menu_dish`, `set_menu_title`, `text`, `wine`.

- **DishProps** — `name`, `price` (£), `description?`, `calories?`, `allergenInfo` (`List<AllergenInfo>`), `dietary?` (`DietaryType`), price variants. `displayName` → uppercase + dietary abbreviation.
- **WineProps** — `name`, `price` (£), `description?`, `vintage?`, `dietary?`, `containsSulphites` (default false).
- **SectionProps** — `title`, `uppercase` (false), `showDivider` (true).
- **TextProps** — `text`, `fontSize` (default 10.0), `align` (left|center|right), `bold` (false), `italic` (false).
- **ImageProps** — `fileId`, `align`, `fit` (contain|cover|fill|fitwidth|fitheight), `width?`, `height?`.
- **DishToShareProps** — Dish + `servings?`.
- **SetMenuDishProps** — dish without price; `hasSupplement` (false), `supplementPrice?`.
- **SetMenuTitleProps** — `title`, `subtitle?`, `uppercase` (false), 1–2 price labels with prices.

### Shared widget utilities (`widget_system/domain/widgets/shared/`)

- **DietaryType** — `vegetarian` → "(V)", `vegan` → "(Ve)"
- **PriceFormatter** — GBP formatting helpers
- **WidgetAlignment** — alignment enum used by props (`left`, `center`, `right`)

### Per-type sub-entities

- `widgets/dish/price_variant.dart` — multi-price variant model used by `DishProps`.
