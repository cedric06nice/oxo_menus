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

### Auth (`auth_provider.dart`)

- **AuthState (freezed):** `initial()`, `loading()`, `authenticated(User)`, `unauthenticated()`, `error(String)`
- **AuthNotifier:** `_tryRestoreSession()` (on init), `login()`, `logout()`, `refresh()`
- **Derived:** `currentUserProvider` (User?), `isAdminProvider` (bool — respects `adminViewAsUserProvider` toggle), `adminViewAsUserProvider` (session toggle), `authListenableProvider` (for GoRouter)

### Repositories (`repositories_provider.dart`)

All watch `directusDataSourceProvider`:
- `menuRepositoryProvider`, `pageRepositoryProvider`, `containerRepositoryProvider`, `columnRepositoryProvider`, `widgetRepositoryProvider`
- `authRepositoryProvider`, `sizeRepositoryProvider`, `areaRepositoryProvider`
- `fileRepositoryProvider`, `menuSubscriptionRepositoryProvider`, `presenceRepositoryProvider`
- `connectivityRepositoryProvider`, `assetLoaderRepositoryProvider`
- `directusBaseUrlProvider` — resolves URL (env var or web hostname)
- `directusAccessTokenProvider` — current auth token for asset requests
- `directusDataSourceProvider` — singleton data source
- `imageDataProvider` — FutureProvider.family for downloading image bytes with auth

### Use Cases (`usecases_provider.dart`)

`fetchMenuTreeUseCaseProvider`, `generatePdfUseCaseProvider`, `duplicateMenuUseCaseProvider`

### Widget Registry (`widget_registry_provider.dart`)

Registers all 5 widget types: dish, image, section, text, wine.

### Page-Level State Providers

| Provider | State Fields | Key Methods |
|----------|-------------|-------------|
| `menuListProvider` | menus, isLoading, errorMessage | loadMenus, deleteMenu, refresh, createMenu, duplicateMenu |
| `editorTreeProvider(menuId)` | menu, pages, containers, columns, widgets, loading/error | loadTree, updateWidget, deleteWidget, addWidget, moveWidget |
| `menuCollaborationProvider(menuId)` | presences, isReconnecting, isPaused, currentUserId | startTracking, stopTracking, onConnectivityChanged, onLifecycleChanged |
| `adminTemplatesProvider` | templates, isLoading, errorMessage, statusFilter | loadTemplates |
| `adminSizesProvider` | sizes, isLoading, errorMessage, statusFilter | loadSizes |
| `menuSettingsProvider` | sizes, areas, isLoading, errorMessage | loadSizes, loadAreas, updateDisplayOptions, saveMenu |
| `imageFilesProvider` | files, isLoading, errorMessage | loadImageFiles |
| `templateEditorProvider` | isSaving | - |
| `editorSelectionProvider` | selection, clipboardStyle, currentStyle | selectElement, updateStyle, copyStyle, pasteStyle |

### Other Providers

- **connectivityProvider** (`StreamProvider<ConnectivityStatus>`) — real-time connectivity stream
- **appLifecycleProvider** — tracks app lifecycle state (for reconnection logic)
- **isAppInForegroundProvider** — derived from appLifecycleProvider
- **menuDisplayOptionsProvider** — session state for menu-level display settings
- **appVersionProvider** — from `package_info_plus`

## Pages (`lib/presentation/pages/`)

### LoginPage
Platform-adaptive (Cupertino on Apple, Material elsewhere). Email/password form, validation, autofill hints. Shows OfflineBanner when disconnected.

### HomePage
Time-based greeting, user avatar, role badge. Responsive grid of quick action cards (1-3 columns). Admin-only actions: Manage Templates, Create Template.

### MenuListPage
**Admin:** Status filter chips, create button (opens `TemplateCreateDialog`), per-menu actions (edit, duplicate, delete). **User:** Published menus only. Responsive grid. Connectivity-aware auto-reload.

### MenuEditorPage
Left sidebar: Widget palette (drag-drop). Main canvas: nested page/container/column layout with drop zones. Top actions: Display Options, PDF preview. Narrow layout (<600px): horizontal palette above canvas. Real-time: WebSocket subscriptions for collaborative editing, presence tracking with `PresenceBar`.

### PdfPreviewPage
Generates and previews PDF menus client-side. Uses FutureBuilder for async generation. Share functionality.

### AdminTemplateEditorPage
Like MenuEditorPage but for templates. Edits header/footer pages. Side panel with style editor. Tracks selection state for property editing.

### AdminTemplateCreatorPage
Form: template name (required), version (default "1.0.0"), page size dropdown, area dropdown. Creates as draft.

### AdminTemplatesPage
Template management with status filters, responsive grid of cards with edit/delete actions.

### AdminSizesPage
Page size CRUD. Cards show name, dimensions (mm), direction, status.

### SettingsPage
User profile (avatar, name, role badge). Logout. Admin debug: "Show as non-admin user" toggle. App version.

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

- **WidgetPalette** — draggable list of widget types, filters by `allowedWidgetTypes`
- **DraggableWidgetItem** — wraps instance for drag/drop with edit/delete actions, shows editing user
- **EditorDropZone** — visual drop target with hover state
- **EditorWidgetCrudHelper** — CRUD operations (create, update, move, delete via repos)
- **WidgetDragData** — payload distinguishing new vs. existing widget drops
- **AutoScrollListener** — auto-scrolls canvas when dragging near edges
- **EditingUserBadge** — shows which user is currently editing a widget

### Canvas Widgets (`canvas/`)

- **TemplateCanvas** — main rendering canvas for menu templates
- **WidgetRenderer** — dynamic dispatch: registry lookup → parseProps → render

### Common Widgets (`common/`)

- **AppShell** — adaptive nav: Mobile (<600px) = NavigationBar, Tablet (600-1200px) = Rail, Desktop (>1200px) = Drawer
- **AuthenticatedScaffold** — consistent AppBar + user avatar button → settings
- **UserAvatarWidget** — network image, initials fallback, email-letter fallback
- **StatusBadge** — colored badge (Draft/Published/Archived)
- **EmptyState** — generic empty state with icon, title, subtitle, optional action
- **HoverCard** — card with hover effects for desktop
- **SkeletonLoader** — shimmer placeholder for loading states
- **PresenceBar** — shows active users editing menu with avatars
- **OfflineBanner** / **OfflineErrorPage** — connectivity warnings
- **EdgeInsetsEditor** — padding/margin editing
- **AdaptiveLoadingIndicator** — platform-specific spinner

### Helpers & Mixins

- `status_helpers.dart` — status → color mapping
- `grid_helpers.dart` — `computeGridColumns()` for responsive layouts
- `edit_dialog_helper.dart` — platform-adaptive dialog opening
- `snackbar_helper.dart` — `showThemedSnackBar(context, message, isError)`
- **ConnectivityRetryMixin** — connectivity-aware auto-retry for pages

## Theme (`lib/presentation/theme/`)

Material 3 with warm burgundy palette. Font: Futura (Book for body, Bold for headings).

- **app_colors.dart** — Light: burgundy (#8B2252), espresso (#5C4033), gold (#C7953C). Dark: warm dark variants
- **app_spacing.dart** — Spacing: xs(4) sm(8) md(12) lg(16) xl(24) xxl(32) xxxl(48). Radii: sm(8) md(12) lg(16) xl(24) full(999)
- **app_text_theme.dart** — Futura-based TextTheme
- **app_theme.dart** — Light/dark builder with Material 3 component theming
- **app_transitions.dart** — Web: fade (200ms), iOS/macOS: Cupertino slide, Android: fade
