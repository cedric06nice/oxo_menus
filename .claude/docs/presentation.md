# Presentation Layer Reference

The presentation layer is split between `lib/shared/presentation/` (cross-feature shell, providers, theme, helpers, common widgets) and `lib/features/<feature>/presentation/` (feature-specific pages, widgets, and state).

## Routing (`lib/core/routing/`)

`GoRouter` with auth guards via `refreshListenable` (watches `authProvider`). Route constants live in `app_routes.dart` (`AppRoutes` class).

### Routes (defined in `app_routes.dart`)

| Path / Builder | Page | Access |
|---|---|---|
| `/splash` | SplashScreen | Loading |
| `/login` | LoginPage | Public (redirects to `/home` if authed) |
| `/forgot-password` | ForgotPasswordPage | Public |
| `/reset-password` | ResetPasswordPage | Public (token in query) |
| `/home` | HomePage | Authenticated |
| `/menus` | MenuListPage | Authenticated |
| `AppRoutes.menuEditor(id)` → `/menus/:id` | MenuEditorPage | Authenticated |
| `AppRoutes.menuPdf(id)` → `/menus/pdf/:id` | PdfPreviewPage | Authenticated |
| `/settings` | SettingsPage | Authenticated |
| `/admin/sizes` | AdminSizesPage | Admin only |
| `/admin/templates` | AdminTemplatesPage | Admin only |
| `/admin/templates/create` | AdminTemplateCreatorPage | Admin only |
| `AppRoutes.adminTemplateEditor(id)` → `/admin/templates/:id` | AdminTemplateEditorPage | Admin only |
| `/admin/exportable_menus` | AdminExportableMenusPage | Admin only |

Web uses `context.go()` (deep-linking), native uses `context.push()`.

## Providers

### Shared providers (`lib/shared/presentation/providers/`)

- **`auth_provider.dart`**
  - **AuthState** (freezed) — `initial()`, `loading()`, `authenticated(User)`, `unauthenticated()`, `error(String)`.
  - **AuthNotifier** — `_tryRestoreSession()` on init, `login()`, `logout()`, `refresh()`.
  - Derived: `currentUserProvider` (User?), `isAdminProvider` (bool — single source of truth, respects `adminViewAsUserProvider` toggle), `adminViewAsUserProvider` (session toggle), `authListenableProvider` (for GoRouter).
- **`repositories_provider.dart`** — all repo providers watch `directusDataSourceProvider`.
  Includes: `menuRepositoryProvider`, `pageRepositoryProvider`, `containerRepositoryProvider`, `columnRepositoryProvider`, `widgetRepositoryProvider`, `authRepositoryProvider`, `sizeRepositoryProvider`, `areaRepositoryProvider`, `fileRepositoryProvider`, `menuSubscriptionRepositoryProvider`, `presenceRepositoryProvider`, `connectivityRepositoryProvider`, `assetLoaderRepositoryProvider`, `menuBundleRepositoryProvider`. Also: `directusBaseUrlProvider`, `directusAccessTokenProvider`, `directusDataSourceProvider`, `imageDataProvider` (FutureProvider.family for downloading image bytes with auth).
- **`usecases_provider.dart`** — `fetchMenuTreeUseCaseProvider`, `generatePdfUseCaseProvider`, `duplicateMenuUseCaseProvider`, `duplicateContainerUseCaseProvider`, `reorderContainerUseCaseProvider`, `listImageFilesUseCaseProvider`, `listSizesUseCaseProvider`, `listTemplatesUseCaseProvider`, plus the `MenuBundle` use case providers (`createMenuBundleUseCaseProvider`, `getMenuBundleUseCaseProvider`, `updateMenuBundleUseCaseProvider`, `deleteMenuBundleUseCaseProvider`, `listMenuBundlesUseCaseProvider`, `publishMenuBundleUseCaseProvider`, `publishBundlesForMenuUseCaseProvider`).
- **`app_lifecycle_provider.dart`** — tracks app lifecycle state; exposes `isAppInForegroundProvider` (used by reconnection logic).
- **`app_version_provider.dart`** — version string from `package_info_plus`.

### Widget registry (`lib/features/widget_system/presentation/providers/`)

- **`widget_registry_provider.dart`** — registers all 8 widget types: `dish`, `dishToShare`, `image`, `section`, `setMenuDish`, `setMenuTitle`, `text`, `wine`.
- **`allowed_widgets_provider.dart`** — derives the per-menu allowed widget palette from `Menu.allowedWidgetTypes`.

### Connectivity (`lib/features/connectivity/presentation/providers/`)

- **`connectivity_provider.dart`** — `StreamProvider<ConnectivityStatus>` watching the `ConnectivityRepository`.

### Page-level state providers (per-feature)

| Provider | Location | State Fields | Key Methods |
|---|---|---|---|
| `menuListProvider` | `features/menu_list/presentation/providers/menu_list_provider.dart` | menus, isLoading, errorMessage | loadMenus, deleteMenu, refresh, createMenu, duplicateMenu |
| `editorTreeProvider(menuId)` | `features/editor_tree/presentation/state/` | menu, pages, containers, columns, widgets, loading/error | loadTree, updateWidget, deleteWidget, addWidget, moveWidget |
| `menuCollaborationProvider(menuId)` | `features/menu_editor/presentation/state/` | presences, isReconnecting, isPaused, currentUserId | startTracking, stopTracking, onConnectivityChanged, onLifecycleChanged |
| `adminTemplatesProvider` | `features/admin_templates/presentation/` | templates, isLoading, errorMessage, statusFilter | loadTemplates |
| `adminSizesProvider` | `features/admin_sizes/presentation/` | sizes, isLoading, errorMessage, statusFilter | loadSizes |
| `adminExportableMenusProvider` | `features/admin_exportable_menus/presentation/` | menus, bundles, isLoading, errorMessage | loadMenus, createBundle, publishBundle, deleteBundle |
| `templateEditorProvider` | `features/admin_template_editor/presentation/state/` | isSaving | save, applyStyle |
| `editorSelectionProvider` | `features/admin_template_editor/presentation/state/` | selection, clipboardStyle, currentStyle | selectElement, updateStyle, copyStyle, pasteStyle |
| `menuSettingsProvider` | `features/menu/presentation/providers/menu_settings/` | sizes, areas, isLoading, errorMessage | loadSizes, loadAreas, updateDisplayOptions, saveMenu |
| `imageFilesProvider` | `features/menu/presentation/providers/image_files/` | files, isLoading, errorMessage | loadImageFiles |
| `menuDisplayOptionsProvider` | `features/menu/presentation/providers/menu_display_options_provider.dart` | session display-option state | toggleShowPrices, toggleShowAllergens |
| `passwordResetProvider` | `features/auth/presentation/providers/password_reset_provider.dart` | request/confirm flow state | requestReset, confirmReset |

## Pages

Most pages live at `lib/features/<feature>/presentation/pages/<feature>_page.dart`. Three admin pages sit one level higher (directly under `presentation/`).

| Page | Path |
|---|---|
| `LoginPage` | `features/auth/presentation/pages/login_page.dart` |
| `ForgotPasswordPage` | `features/auth/presentation/pages/forgot_password_page.dart` |
| `ResetPasswordPage` | `features/auth/presentation/pages/reset_password_page.dart` |
| `HomePage` | `features/home/presentation/pages/home_page.dart` |
| `MenuListPage` | `features/menu_list/presentation/pages/menu_list_page.dart` |
| `MenuEditorPage` | `features/menu_editor/presentation/pages/menu_editor_page.dart` |
| `PdfPreviewPage` | `features/menu_editor/presentation/pages/pdf_preview_page.dart` |
| `AdminTemplateCreatorPage` | `features/admin_template_creator/presentation/pages/admin_template_creator_page.dart` |
| `AdminTemplateEditorPage` | `features/admin_template_editor/presentation/pages/admin_template_editor_page.dart` |
| `AdminTemplatesPage` | `features/admin_templates/presentation/admin_templates_page.dart` (top-level) |
| `AdminSizesPage` | `features/admin_sizes/presentation/admin_sizes_page.dart` (top-level) |
| `AdminExportableMenusPage` | `features/admin_exportable_menus/presentation/admin_exportable_menus_page.dart` (top-level) |
| `SettingsPage` | `features/settings/presentation/pages/settings_page.dart` |

### Page behaviour highlights

- **LoginPage** — Platform-adaptive (Cupertino on Apple, Material elsewhere). Email/password form, validation, autofill hints. Shows OfflineBanner when disconnected.
- **HomePage** — Time-based greeting, user avatar, role badge. Responsive grid of quick action cards. Admin-only actions: Manage Templates, Create Template.
- **MenuListPage** — Admin: status filter chips, create button (opens `TemplateCreateDialog`), per-menu actions (edit, duplicate, delete). User: published menus only. Connectivity-aware auto-reload.
- **MenuEditorPage** — Left sidebar widget palette (drag-drop). Main canvas: nested page/container/column layout with drop zones. Top actions: Display Options, PDF preview. Narrow layout (<600 px): horizontal palette above canvas. Real-time WebSocket subscriptions for collaborative editing; presence via `PresenceBar`.
- **PdfPreviewPage** — Generates and previews PDFs client-side via `FutureBuilder`. Share functionality.
- **AdminTemplateEditorPage** — Like `MenuEditorPage` but for templates. Edits header/footer pages. Side panel with style editor. Tracks selection state for property editing.
- **AdminTemplateCreatorPage** — Form: template name (required), version (default `1.0.0`), page size dropdown, area dropdown. Creates as draft.
- **AdminTemplatesPage** — Template management with status filters and a responsive grid of cards (edit/delete actions).
- **AdminSizesPage** — Page-size CRUD. Cards show name, dimensions (mm), direction, status.
- **AdminExportableMenusPage** — Manage published bundles per menu (create/edit/delete via `MenuBundleCreateEditDialog`).
- **SettingsPage** — User profile (avatar, name, role badge). Logout. Admin debug toggle "Show as non-admin user". App version.

## Widgets

### Shared widgets (`lib/shared/presentation/widgets/`)

- **AppShell** — adaptive nav: Mobile (<600 px) NavigationBar, Tablet (600–1200 px) Rail, Desktop (>1200 px) Drawer.
- **AuthenticatedScaffold** — consistent AppBar with user-avatar button → settings.
- **AdaptiveEditScaffold** — platform-adaptive shell for edit dialogs (used by per-widget edit dialogs).
- **AdaptiveLoadingIndicator**, **AdaptiveErrorState** — platform-aware spinner / error state.
- **UserAvatarWidget** — network image with initials and email-letter fallbacks.
- **StatusBadge** — coloured badge (Draft/Published/Archived).
- **StatusFilterBar** — chips filter for status enums.
- **EmptyState** — generic empty state with icon, title, subtitle, optional action.
- **HoverCard** — card with hover effects for desktop.
- **SkeletonLoader** — shimmer placeholder for loading states.
- **EdgeInsetsEditor** — padding/margin editing UI.
- **DeleteConfirmationDialog** — adaptive confirm dialog for destructive ops.
- **PriceCell** — styled GBP price label.
- **PdfViewerWidget** + `pdf_viewer_widget_native.dart` / `pdf_viewer_widget_web.dart` — conditional PDF viewer (native vs web).

### Shared helpers (`lib/shared/presentation/helpers/`)

- `status_helpers.dart` — status → colour mapping.
- `grid_helpers.dart` — `computeGridColumns()` for responsive layouts.
- `edit_dialog_helper.dart` — `showEditDialog()` platform-adaptive dialog opener.
- `cupertino_picker_helper.dart` — Cupertino picker convenience helpers.
- `snackbar_helper.dart` — `showThemedSnackBar(context, message, isError)`.

### Shared mixins (`lib/shared/presentation/mixins/`)

- `connectivity_retry_mixin.dart` — `ConnectivityRetryMixin` for connectivity-aware auto-retry on pages.

### Shared utils (`lib/shared/presentation/utils/`)

- `platform_detection.dart` — host OS detection helpers.
- `pdf_filename.dart` — naming helpers for exported PDFs.

### Per-widget renderers (`lib/features/widget_system/presentation/widgets/<type>_widget/`)

Each of the 8 widget types has three files: `*_widget.dart` (render), `*_edit_dialog.dart` (form), `*_widget_definition.dart` (`PresentableWidgetDefinition`).

| Type | Key Render Elements |
|---|---|
| Dish | Name (uppercase + dietary abbr), price (£), description, calories, allergens (text), price variants |
| Dish To Share | Like Dish + servings count |
| Wine | Name (uppercase + dietary abbr), price (£), description, vintage, sulphites flag |
| Section | Title (optional uppercase), optional divider line |
| Set Menu Dish | Dish without price; optional supplement (£) |
| Set Menu Title | Title/subtitle with 1–2 price columns |
| Text | Content with alignment, font size, bold/italic |
| Image | Image from Directus via `Image.memory` with auth headers, alignment, fit |

Plus `lib/features/widget_system/presentation/widget_system/`:
- `presentable_widget_definition.dart` — render-side definition wrapper.
- `presentable_widget_registry.dart` — render-side registry with dynamic dispatch.

### Editor widgets (`lib/features/editor_tree/presentation/widgets/`)

- `widget_palette.dart` — draggable list of widget types, filtered by `allowedWidgetTypes`.
- `draggable_widget_item.dart` — wraps an instance for drag/drop with edit/delete actions, shows editing user.
- `editor_drop_zone.dart` — visual drop target with hover state.
- `editor_column_card.dart` — column rendering inside the editor canvas.
- `editor_tree_loader.dart` + `editor_tree_loader_provider.dart` — async tree loader.
- `widget_drag_data.dart` — payload distinguishing new vs existing widget drops.
- `auto_scroll_listener.dart` — auto-scrolls canvas when dragging near edges.
- `area_dialog_helper.dart`, `display_options_dialog_helper.dart`, `page_size_dialog_helper.dart` — small adaptive helpers used by editor toolbars.

### Canvas widgets (`lib/features/menu/presentation/widgets/canvas/`)

- `template_canvas.dart` — main rendering canvas for menu templates.
- `widget_renderer.dart` — dynamic dispatch: registry lookup → `parseProps` → `render`.

### Collaboration widgets (`lib/features/collaboration/presentation/widgets/`)

- `presence_bar.dart` — active-users bar with avatars.
- `editing_user_badge.dart` — per-widget editor badge.

### Connectivity widgets (`lib/features/connectivity/presentation/widgets/`)

- `offline_banner.dart` — top-of-screen offline indicator.
- `offline_error_page.dart` — full-screen offline fallback.

### Allergen widgets (`lib/features/allergens/presentation/widgets/`)

- `allergen_selector.dart` — selector with may-contain toggle and detail editing.
- `allergen_detail_chips.dart` — chip-style allergen detail picker.

### Menu-editor widgets (`lib/features/menu_editor/presentation/widgets/`)

- `menu_display_options_dialog.dart`, `pdf_display_options_dialog.dart` — adaptive dialogs to toggle prices/allergens.

### Menu-list widgets (`lib/features/menu_list/presentation/widgets/`)

- `menu_list_item.dart` — list/grid item; subtitle (status/version/date) only shown for `isAdmin: true`.
- `template_create_dialog.dart` — create-template form dialog (used by the MenuListPage admin add button).

### Home widgets (`lib/features/home/presentation/widgets/`)

- `quick_action_card.dart`, `welcome_card.dart`, `role_badge.dart` — building blocks of the home dashboard.

### Admin-template-editor widgets (`lib/features/admin_template_editor/presentation/widgets/`)

- `page_size_picker_dialog.dart` — pick a page size when creating/editing.
- `side_panel_style_editor.dart` — side panel style editor used by the template editor.

### Admin-* per-feature widgets

- `features/admin_templates/presentation/widgets/template_card.dart`
- `features/admin_sizes/presentation/widgets/size_create_edit_dialog.dart`
- `features/admin_exportable_menus/presentation/widgets/menu_bundle_create_edit_dialog.dart`

## Theme (`lib/shared/presentation/theme/`)

Material 3 with a warm burgundy palette. Font: Futura (Book for body, Bold for headings).

- `app_colors.dart` — Light: burgundy (#8B2252), espresso (#5C4033), gold (#C7953C). Dark: warm dark variants.
- `app_spacing.dart` — Spacing: xs(4) sm(8) md(12) lg(16) xl(24) xxl(32) xxxl(48). Radii: sm(8) md(12) lg(16) xl(24) full(999).
- `app_text_theme.dart` — Futura-based `TextTheme`.
- `app_theme.dart` — Light/dark builders with Material 3 component theming.
- `app_transitions.dart` — Web: fade (200 ms); iOS/macOS: Cupertino slide; Android: fade.
