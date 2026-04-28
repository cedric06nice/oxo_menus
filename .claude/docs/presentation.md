# Presentation Layer Reference

The presentation layer is split between `lib/shared/presentation/` (cross-feature shell, controllers, theme, helpers, common widgets) and `lib/features/<feature>/presentation/` (feature-owned routing, view models, screens, widgets).

## Routing (`lib/core/routing/`)

In-house `OxoRouter` (`oxo_router.dart`) with auth guards. The `redirect` closure consults `AppScope.of(context).auth.status` (and the `adminViewAsUser` controller for admin gating); both feed `refreshListenable` so the redirect re-runs on auth state changes. `go_router` and `flutter_riverpod` were both retired in Phases 28–29. Route constants live in `app_routes.dart` (`AppRoutes` class).

### Routes (declared in `AppRouter._buildRoutes()`)

| Path / Builder | Screen | Shell | Access |
|---|---|---|---|
| `/splash` | (inline splash) | no | Loading |
| `/login` | `LoginScreen` | no | Public (redirects to `/home` if authed) |
| `/forgot-password` | `ForgotPasswordScreen` | no | Public |
| `/reset-password` | `ResetPasswordScreen` (token in query) | no | Public |
| `/home` | `HomeScreen` | yes | Authenticated |
| `/menus` | `MenuListScreen` | yes | Authenticated |
| `AppRoutes.menuEditor(id)` → `/menus/:id` | `MenuEditorScreen` | yes | Authenticated |
| `AppRoutes.menuPdf(id)` → `/menus/pdf/:id` | `PdfPreviewScreen` | yes | Authenticated |
| `/settings` | `SettingsScreen` | yes | Authenticated |
| `/admin/sizes` | `AdminSizesScreen` | yes | Admin only |
| `/admin/templates` | `AdminTemplatesScreen` | yes | Admin only |
| `/admin/templates/create` | `AdminTemplateCreatorScreen` | yes | Admin only |
| `AppRoutes.adminTemplateEditor(id)` → `/admin/templates/:id` | `AdminTemplateEditorScreen` | yes | Admin only |
| `/admin/exportable_menus` | `AdminExportableMenusScreen` | yes | Admin only |

Shell-bound routes (`inShell: true`) are wrapped by `AppRouter._buildShell` → `_AppShellHost` → `AppShell`. Per-feature route adapters call `OxoRouter.go(...)` (replace stack) or `OxoRouter.push(...)` (append).

## State Management

`AppScope` (`lib/core/di/app_scope.dart`) is the root `InheritedWidget`. It exposes the singleton `AppContainer` plus four shared `ChangeNotifier` controllers (`AuthController`, `ConnectivityController`, `AdminViewAsUserController`, `AppLifecycleController`) — those replace the retired Riverpod providers.

Per-screen state is owned by a feature `ViewModel<S>` (a `ChangeNotifier`) at `lib/features/<feature>/presentation/view_models/`. Each route in `app_router.dart` is hosted by a small `_*RouteHost` `StatefulWidget` that builds the ViewModel from `AppScope.read(context).container` in `initState` and disposes it in `dispose`. Screens receive the ViewModel via constructor and rebuild via `ListenableBuilder(listenable: viewModel, …)`.

### Shared controllers (`lib/shared/presentation/controllers/`)

| Controller | Source of truth | Exposed |
|---|---|---|
| `AuthController` | `AuthGateway.statusStream` | `status` (`AuthStatus`), helper `isAuthenticated`/`isAdmin` |
| `ConnectivityController` | `ConnectivityGateway` stream | `isOffline`, `status` |
| `AdminViewAsUserController` | `AdminViewAsUserGateway` | `value` (bool toggle) |
| `AppLifecycleController` | `WidgetsBindingObserver` | `state` (`AppLifecycleState`) |

Construct any of them with the matching gateway from `AppContainer`. `AuthController` defaults `autoRestore: true` (kicks `tryRestoreSession` via `Future.microtask`); tests pass `autoRestore: false` for deterministic state.

### Feature ViewModels

Each feature ViewModel takes its use cases + a feature `Router` interface via constructor. The route adapter forwards the router calls to a `RouteNavigator` (`OxoRouterRouteNavigator(context)` in production), so the ViewModel is `BuildContext`-free.

| ViewModel | Path |
|---|---|
| `LoginViewModel` / `ForgotPasswordViewModel` / `ResetPasswordViewModel` | `features/auth/presentation/view_models/` |
| `HomeViewModel` | `features/home/presentation/view_models/` |
| `MenuListViewModel` | `features/menu_list/presentation/view_models/` |
| `MenuEditorViewModel` / `PdfPreviewViewModel` | `features/menu_editor/presentation/view_models/` |
| `SettingsViewModel` | `features/settings/presentation/view_models/` |
| `AdminSizesViewModel` / `AdminTemplatesViewModel` / `AdminTemplateCreatorViewModel` / `AdminTemplateEditorViewModel` / `AdminExportableMenusViewModel` | `features/admin_*/presentation/view_models/` |

Local UI controllers (`TemplateCreateDialogController`) are also `ChangeNotifier`s and live next to the widget they drive.

## Screens

Screens live at `lib/features/<feature>/presentation/screens/<feature>_screen.dart`. They are passive views bound to a `ViewModel<S>`; the legacy `*_page.dart` widgets were retired in Phases 15–25.

### Screen behaviour highlights

- **LoginScreen** — Platform-adaptive (Cupertino on Apple, Material elsewhere). Email/password form, validation, autofill hints. Shows `OfflineBanner` when disconnected.
- **HomeScreen** — Time-based greeting, user avatar, role badge. Responsive grid of quick action cards. Admin-only actions: Manage Templates, Create Template.
- **MenuListScreen** — Admin: status filter chips, create button (opens `TemplateCreateDialog`), per-menu actions (edit, duplicate, delete). User: published menus only. Connectivity-aware auto-reload via the ViewModel.
- **MenuEditorScreen** — Left sidebar widget palette (drag-drop). Main canvas: nested page/container/column layout with drop zones. Top actions: Display Options, PDF preview. Narrow layout (<600 px): horizontal palette above canvas. Real-time WebSocket subscriptions for collaborative editing; presence via `PresenceBar`. Reads `viewModel.registry` / `viewModel.imageGateway` for dynamic widget dispatch + image loading.
- **PdfPreviewScreen** — Generates and previews PDFs client-side via the ViewModel; share functionality.
- **AdminTemplateEditorScreen** — Like `MenuEditorScreen` but for templates. Edits header/footer pages. Side panel with style editor.
- **AdminTemplateCreatorScreen** — Form: template name (required), version (default `1.0.0`), page size dropdown, area dropdown. Creates as draft.
- **AdminTemplatesScreen** — Template management with status filters and a responsive grid of cards (edit/delete actions).
- **AdminSizesScreen** — Page-size CRUD. Cards show name, dimensions (mm), direction, status.
- **AdminExportableMenusScreen** — Manage published bundles per menu (create/edit/delete via `MenuBundleCreateEditDialog`).
- **SettingsScreen** — User profile (avatar, name, role badge). Logout. Admin debug toggle "Show as non-admin user". App version.

## Widgets

### Shared widgets (`lib/shared/presentation/widgets/`)

- **AppShell** — adaptive nav: Mobile (<600 px) NavigationBar, Tablet (600–1200 px) Rail, Desktop (>1200 px) Drawer. Receives `RouteNavigator`, `currentLocation`, `isAdmin`, `isOffline` from the router shell builder.
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
| Image | Image from Directus via `Image.memory` with auth headers (resolved through `WidgetContext.imageGateway`), alignment, fit |

Plus `lib/features/widget_system/presentation/widget_system/`:
- `presentable_widget_definition.dart` — render-side definition wrapper.
- `presentable_widget_registry.dart` — render-side registry with dynamic dispatch.
- `built_in_widget_definitions.dart` — `allWidgetDefinitions` consumed lazily by `AppContainer.widgetRegistry` (replaces the retired `widget_registry_provider.dart`).

### Menu canvas + editor widgets (`lib/features/menu/presentation/widgets/`)

- `canvas/template_canvas.dart` — main rendering canvas for menu templates (plain `StatelessWidget`, takes `registry` / `displayOptions` / `allowedWidgets` / `imageGateway` via constructor).
- `canvas/widget_renderer.dart` — dynamic dispatch: registry lookup → `parseProps` → `render`.
- `editor/widget_palette.dart` — draggable list of widget types, filtered by `allowedWidgetTypes`.
- `editor/draggable_widget_item.dart` — wraps an instance for drag/drop with edit/delete actions, shows editing user.
- `editor/editor_drop_zone.dart` — visual drop target with hover state.
- `editor/editor_column_card.dart` — column rendering inside the editor canvas.
- `editor/widget_drag_data.dart` — payload distinguishing new vs existing widget drops.
- `editor/auto_scroll_listener.dart` — auto-scrolls canvas when dragging near edges.

### Collaboration widgets (`lib/features/collaboration/presentation/widgets/`)

- `presence_bar.dart` — active-users bar with avatars (reads scope via `AppScope.of(context)`).
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
- `template_create_dialog.dart` + `template_create_dialog_controller.dart` — create-template form dialog with its own local `ChangeNotifier`. The dialog accepts `sizeRepository` / `areaRepository` ctor args so tests inject fakes directly without an `AppScope`.

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
