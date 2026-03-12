# Presentation Layer Reference

## Routing (`lib/core/routing/app_router.dart`)

`GoRouter` with auth guards via `refreshListenable` (watches `authProvider`).

### Routes
| Path | Page | Access |
|------|------|--------|
| `/splash` | SplashScreen | Loading |
| `/login` | LoginPage | Public (redirects to /home if authed) |
| `/home` | HomePage | Authenticated |
| `/menus` | MenuListPage | Authenticated |
| `/menus/:id` | MenuEditorPage | Authenticated |
| `/menus/pdf/:id` | PdfPreviewPage | Authenticated |
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

**Derived:** `currentUserProvider` (User?), `isAdminProvider` (bool — respects `adminViewAsUserProvider` toggle), `adminViewAsUserProvider` (session toggle), `authListenableProvider` (for GoRouter)

### RepositoriesProvider (`repositories_provider.dart`)
All watch `directusDataSourceProvider`:
- `menuRepositoryProvider`, `pageRepositoryProvider`, `containerRepositoryProvider`, `columnRepositoryProvider`, `widgetRepositoryProvider`
- `authRepositoryProvider`, `sizeRepositoryProvider`, `areaRepositoryProvider`
- `fileRepositoryProvider`, `menuSubscriptionRepositoryProvider`, `presenceRepositoryProvider`
- `directusBaseUrlProvider` — resolves URL (env var or web hostname)
- `directusAccessTokenProvider` — current auth token for asset requests
- `directusDataSourceProvider` — singleton data source
- `imageDataProvider` — FutureProvider.family for downloading image bytes with auth

### UseCasesProvider (`usecases_provider.dart`)
`fetchMenuTreeUseCaseProvider`, `generatePdfUseCaseProvider`, `duplicateMenuUseCaseProvider`

### WidgetRegistryProvider (`widget_registry_provider.dart`)
Registers all 5 widget types: dish, image, section, text, wine.

### MenuListProvider (`menu_list_provider.dart`)
**MenuListState (freezed):** `menus`, `isLoading`, `errorMessage?`
**MenuListNotifier:** `loadMenus(onlyPublished)`, `deleteMenu(id)`, `refresh()`, `createMenu(input)`, `duplicateMenu(id)`, `clearError()`

### MenuDisplayOptionsProvider (`menu_display_options_provider.dart`)
Session state for menu-level display settings (read by WidgetRenderer).

### AppVersionProvider (`app_version_provider.dart`)
FutureProvider fetching app version from `package_info_plus`.

## Pages (`lib/presentation/pages/`)

### LoginPage
Platform-adaptive (Cupertino on Apple, Material elsewhere). Email/password form, validation, autofill hints.

### HomePage
Time-based greeting (`home_helpers.dart`), user avatar, role badge. Responsive grid of quick action cards (1-3 columns). Admin-only actions: Manage Templates, Create Template.
Subwidgets: `WelcomeCard`, `QuickActionCard`, `RoleBadge`

### MenuListPage
**Admin:** Status filter chips (All/Draft/Published/Archived), create button (opens `TemplateCreateDialog`), per-menu actions (edit, duplicate, delete). **User:** Published menus only, open editor. Responsive grid layout. Menus grouped by area.
Subwidgets: `MenuListItem`, `TemplateCreateDialog`

### MenuEditorPage
Left sidebar: Widget palette (drag-drop). Main canvas: nested page/container/column layout with drop zones. Top actions: Display Options, PDF preview. Narrow layout (<600px): horizontal palette above canvas. Disables drops in non-droppable columns (lock icon). Real-time: WebSocket subscriptions for collaborative editing, presence tracking with `PresenceBar`, auto-reconnect with polling fallback.

### PdfPreviewPage
Generates and previews PDF menus client-side. Uses FutureBuilder for async generation. Share functionality.

### AdminTemplateEditorPage
Like MenuEditorPage but for templates. Edits header/footer pages. Manages allowed widget types. Side panel with style editor. Tracks selection state for property editing.
Subwidgets: `SidePanelStyleEditor`, `PageSizePickerDialog`, `EditorSelectionNotifier`

### AdminTemplateCreatorPage
Form: template name (required), version (default "1.0.0"), page size dropdown, area dropdown. Creates as draft. Navigates to editor on success.

### AdminTemplatesPage
Template management with status filters, responsive grid of cards. Each card: status header, name, version, edit/delete actions.
Subwidgets: `TemplateCard`

### AdminSizesPage
Page size CRUD. Cards show name, dimensions (mm), direction, status. Create/edit/delete dialogs.
Subwidgets: `SizeCreateEditDialog`

### SettingsPage
User profile (avatar, name, role badge). Logout with confirmation. Admin debug: "Show as non-admin user" toggle. App version display.

## Widgets (`lib/presentation/widgets/`)

### Widget Type Definitions (5 types)
Each has: `*_widget_definition.dart`, `*_widget.dart` (render), `*_edit_dialog.dart` (form)

| Type | Key Render Elements |
|------|-------------------|
| Dish | Name (uppercase + dietary abbr), price (£), description, calories, allergens (text) |
| Wine | Name (uppercase + dietary abbr), price (£), description, vintage, sulphites flag |
| Section | Title (optional uppercase), optional divider line |
| Text | Content with alignment, font size, bold/italic |
| Image | Image from Directus via Image.memory with auth headers, alignment, fit |

### Editor Widgets (`editor/`)
- **WidgetPalette** — draggable list of widget types, filters by `allowedWidgetTypes`. Horizontal/vertical layout
- **DraggableWidgetItem** — wraps instance for drag/drop with edit/delete actions, shows editing user presence
- **EditorDropZone** — visual drop target with hover state
- **EditorWidgetCrudHelper** — CRUD operations (create, update, move, delete via repos)
- **WidgetDragData** — payload distinguishing new vs. existing widget drops
- **AutoScrollListener** — auto-scrolls canvas when dragging near edges
- **EditingUserBadge** — shows which user is currently editing a widget

### Canvas Widgets (`canvas/`)
- **TemplateCanvas** — main rendering canvas for menu templates
- **WidgetRenderer** — dynamic dispatch: registry lookup → parseProps → render

### Common Widgets (`common/`)
- **AppShell** — adaptive navigation shell: Mobile (<600px) = NavigationBar, Tablet (600-1200px) = NavigationRail, Desktop (>1200px) = NavigationDrawer; role-aware destinations
- **AuthenticatedScaffold** — consistent AppBar + user avatar button → settings
- **UserAvatarWidget** — network image, initials fallback, email-letter fallback
- **StatusBadge** — colored badge (Draft/Published/Archived)
- **EmptyState** — generic empty state with icon, title, subtitle, optional action button
- **HoverCard** — card with hover effects for desktop interaction
- **SkeletonLoader** — shimmer placeholder for loading states
- **PresenceBar** — shows active users editing menu with avatars and names
- **EdgeInsetsEditor** / **CompactEdgeInsetsEditor** — padding/margin editing

### Dialog Widgets (`dialogs/`)
- **DeleteConfirmationDialog** — reusable platform-adaptive confirm
- **MenuDisplayOptionsDialog** — edit showPrices/showAllergens

### Other Widgets
- **AllergenSelector** — multi-select for UK FSA allergens
- **MenuListItem** — rich card: status header, name, version, date (admin only), actions
- **TemplateCard** — template list card with click/edit/delete actions

### Helpers (`helpers/`)
- **status_helpers.dart** — status → color mapping
- **grid_helpers.dart** — `computeGridColumns()` for responsive layouts
- **edit_dialog_helper.dart** — platform-adaptive dialog opening

## Theme (`lib/presentation/theme/`)

Material 3 with rich burgundy palette. Font: Futura (Book weight for body, Bold for headings).

- **app_colors.dart** — Light: burgundy primary (#8B2252), espresso secondary, antique gold tertiary. Dark: matching dark variants. Status colors: statusGreen, statusGreenDark
- **app_spacing.dart** — Spacing tokens (xs=4 to xxxl=48), radii (sm=8 to full=999), elevation levels
- **app_text_theme.dart** — Futura-based TextTheme with intentional weights
- **app_theme.dart** — Unified builder: light/dark schemes, custom component theming (AppBar, Card, Dialog, Button, Navigation, Input, FAB, etc.)
