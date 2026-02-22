# Presentation Layer Reference

## Routing (`lib/core/routing/app_router.dart`)

`GoRouter` with auth guards via `refreshListenable` (watches `authProvider`).

### Routes
| Path | Page | Access |
|------|------|--------|
| `/login` | LoginPage | Public (redirects to /home if authed) |
| `/home` | HomePage | Authenticated |
| `/menus` | MenuListPage | Authenticated |
| `/menus/:id` | MenuEditorPage | Authenticated |
| `/menus/pdf/:id` | PdfPreviewDialog | Authenticated |
| `/settings` | SettingsPage | Authenticated |
| `/admin/sizes` | AdminSizesPage | Admin only |
| `/admin/templates` | AdminTemplatesPage | Admin only |
| `/admin/templates/create` | AdminTemplateCreatorPage | Admin only |
| `/admin/templates/:id` | AdminTemplateEditorPage | Admin only |

Web uses `context.go()`, native uses `context.push()`.

## Providers (`lib/presentation/providers/`)

### AuthProvider (`auth_provider.dart`)
**AuthState (freezed):** `initial()`, `loading()`, `authenticated(User)`, `unauthenticated()`, `error(String)`

**AuthNotifier:** `_tryRestoreSession()` (on init), `login()`, `logout()`, `refresh()`

**Derived:** `currentUserProvider` (User?), `isAdminProvider` (bool — respects `adminViewAsUserProvider` toggle), `authListenableProvider` (for GoRouter)

### RepositoriesProvider (`repositories_provider.dart`)
All watch `directusDataSourceProvider`: `menuRepositoryProvider`, `pageRepositoryProvider`, `containerRepositoryProvider`, `columnRepositoryProvider`, `widgetRepositoryProvider`, `authRepositoryProvider`, `sizeRepositoryProvider`, `fileRepositoryProvider`

`directusBaseUrlProvider` resolves URL (env var or web hostname). `directusDataSourceProvider` creates the data source.

### UseCasesProvider (`usecases_provider.dart`)
`fetchMenuTreeUseCaseProvider`, `generatePdfUseCaseProvider`, `duplicateMenuUseCaseProvider`

### WidgetRegistryProvider (`widget_registry_provider.dart`)
Registers all 5 widget types: dish, image, section, text, wine.

### MenuListProvider (`menu_list_provider.dart`)
**MenuListState (freezed):** `menus`, `isLoading`, `errorMessage?`
**MenuListNotifier:** `loadMenus(onlyPublished)`, `deleteMenu(id)`, `refresh()`, `createMenu(input)`, `duplicateMenu(id)`, `clearError()`

### MenuDisplayOptionsProvider (`menu_display_options_provider.dart`)
Session state for menu-level display settings (read by WidgetRenderer).

## Pages (`lib/presentation/pages/`)

### LoginPage
Platform-adaptive (Cupertino on Apple, Material elsewhere). Email/password form, validation, autofill hints.

### HomePage
Time-based greeting, user avatar, role badge. Responsive grid of quick action cards (1-3 columns). Admin-only actions: Manage Templates, Create Template.

### MenuListPage
**Admin:** Status filter chips (All/Draft/Published/Archived), create button (opens TemplateCreateDialog), per-menu actions (edit, duplicate, delete). **User:** Published menus only, open editor. Responsive grid layout.

### MenuEditorPage
Left sidebar: Widget palette (drag-drop). Main canvas: nested page/container/column layout with drop zones. Top actions: Display Options, PDF preview, Save. Narrow layout (<600px): horizontal palette above canvas. Disables drops in non-droppable columns (lock icon).

### AdminTemplateEditorPage
Like MenuEditorPage but for templates. Edits header/footer pages. Manages allowed widget types. Side panel with style editor. Tracks selection state for property editing.

### AdminTemplateCreatorPage
Form: template name (required), version (default "1.0.0"), page size dropdown. Creates as draft. Navigates to editor on success.

### AdminTemplatesPage
Template management with status filters, responsive grid of cards. Each card: status header, name, version, edit/delete actions.

### AdminSizesPage
Page size CRUD. Cards show name, dimensions (mm), direction, status. Create/edit/delete dialogs.

### SettingsPage
User profile (avatar, name, role badge). Logout with confirmation. Admin debug: "Show as non-admin user" toggle.

## Widgets (`lib/presentation/widgets/`)

### Widget Type Definitions (5 types)
Each has: `*_widget_definition.dart`, `*_widget.dart` (render), `*_edit_dialog.dart` (form)

| Type | Key Render Elements |
|------|-------------------|
| Dish | Name (uppercase + dietary abbr), price (£), description, calories, allergens (text) |
| Wine | Name (uppercase + dietary abbr), price (£), description, vintage, sulphites flag |
| Section | Title (optional uppercase), optional divider line |
| Text | Content with alignment, font size, bold/italic |
| Image | Network image from Directus with alignment and fit options |

### Editor Widgets (`editor/`)
- **WidgetPalette** — draggable list of widget types, filters by `allowedWidgetTypes`
- **DraggableWidgetItem** — wraps instance for drag/drop with edit/delete actions
- **EditorDropZone** — visual drop target with hover state
- **EditorWidgetCrudHelper** — CRUD operations (create, update, move, delete via repos)
- **WidgetDragData** — payload distinguishing new vs. existing widget drops
- **AutoScrollListener** — auto-scrolls canvas when dragging near edges
- **DeleteConfirmationDialog** — platform-adaptive confirm

### Common Widgets (`common/`)
- **AuthenticatedScaffold** — consistent AppBar + user avatar button → settings
- **UserAvatarWidget** — network image, initials fallback, email-letter fallback
- **EdgeInsetsEditor** / **CompactEdgeInsetsEditor** — padding/margin editing

### Other Widgets
- **WidgetRenderer** (`widget_renderer.dart`) — dynamic dispatch: registry lookup → parseProps → render
- **MenuListItem** — rich card: status header, name, version, date (admin only), actions
- **TemplateCanvas** — canvas for template preview rendering
- **TemplateCard** / **TemplateStatusIndicator** — template list card and status badge
- **MenuStatusIndicator** — status badge (Draft/Published/Archived)
- **AllergenSelector** — multi-select for UK FSA allergens
- **MenuDisplayOptionsDialog** — edit showPrices/showAllergens
- **PageSizePickerDialog** / **SizeCreateEditDialog** / **TemplateCreateDialog**

### Helpers (`helpers/`)
- **status_helpers.dart** — status → color mapping

## Theme (`lib/presentation/theme/app_theme.dart`)

Material 3, seed color: Deep Purple, font: Futura. Light + Dark themes. Filled inputs (12px border radius), full-width buttons (48px height, rounded).
