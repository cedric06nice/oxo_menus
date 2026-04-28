# Creating a New Widget Type

Use `section_widget` as the template — it's the simplest of the 8 widget types.
Replace `{type}` with the snake_case name (e.g. `cocktail`) and `{Type}` with PascalCase (e.g. `Cocktail`).

All paths below are relative to the repo root and assume the feature-first layout (`lib/features/widget_system/...`).

## Step 1 — Domain Props (TDD)

### RED
- [ ] Create `test/unit/features/widget_system/domain/widgets/{type}/{type}_props_test.dart`
- [ ] Write tests: construction with required/optional fields, defaults, `copyWith`, JSON round-trip (`fromJson` / `toJson`)
- [ ] Run tests — confirm they FAIL (class doesn't exist yet)

### GREEN
- [ ] Create `lib/features/widget_system/domain/widgets/{type}/{type}_props.dart`
- [ ] Define a freezed class `{Type}Props`
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Run tests — confirm they PASS

## Step 2 — Widget Definition (TDD)

### RED
- [ ] Create `test/unit/features/widget_system/presentation/widgets/{type}_widget/{type}_widget_definition_test.dart`
- [ ] Test: type string, version, `defaultProps` values, `parseProps` from JSON, icon metadata
- [ ] Run tests — confirm they FAIL

### GREEN
- [ ] Create `lib/features/widget_system/presentation/widgets/{type}_widget/{type}_widget_definition.dart`
- [ ] Define `final {type}WidgetDefinition = PresentableWidgetDefinition<{Type}Props>(...)`
- [ ] Set: `type`, `version` (`'1.0.0'`), `displayName`, `materialIcon`, `cupertinoIcon`, `parseProps`, `render` (placeholder), `defaultProps`
- [ ] Run tests — confirm they PASS

## Step 3 — Widget Rendering (TDD)

### RED
- [ ] Create `test/widget/features/widget_system/presentation/widgets/{type}_widget/{type}_widget_test.dart`
- [ ] Test: renders with default props, with custom props, respects `displayOptions`, editable vs non-editable behaviour
- [ ] Run tests — confirm they FAIL

### GREEN
- [ ] Create `lib/features/widget_system/presentation/widgets/{type}_widget/{type}_widget.dart`
- [ ] Implement `{Type}Widget extends StatelessWidget` with `props` and `context` (`WidgetContext`) fields
- [ ] In `_handleEdit`, call the shared `showEditDialog()` helper (do **not** branch on platform manually)
- [ ] Run tests — confirm they PASS

## Step 4 — Edit Dialog (TDD)

### RED
- [ ] Add tests in `test/widget/features/widget_system/presentation/widgets/{type}_widget/{type}_edit_dialog_test.dart` (or extend the widget test file)
- [ ] Test: dialog opens, fields pre-populated, `onSave` returns updated props, Cancel pops
- [ ] Run tests — confirm they FAIL

### GREEN
- [ ] Create `lib/features/widget_system/presentation/widgets/{type}_widget/{type}_edit_dialog.dart`
- [ ] Use `AdaptiveEditScaffold` for the shell (`title`, `onSave`, `appleFormChildren`, `materialFormChildren`)
- [ ] Define form fields in the children lists — only the form content, no shell boilerplate
- [ ] Run tests — confirm they PASS

## Step 5 — Registration

- [ ] Add the import + `{type}WidgetDefinition` entry to `allWidgetDefinitions` in `lib/features/widget_system/presentation/widget_system/built_in_widget_definitions.dart` (consumed by `AppContainer.widgetRegistry`).
- [ ] Run `flutter test test/unit/features/widget_system/presentation/widget_system/presentable_widget_registry_test.dart` — update count assertions if needed.

## Step 6 — PDF Rendering (TDD)

### RED
- [ ] Add a test for the new widget type to `test/unit/features/menu/domain/usecases/generate_pdf_usecase_test.dart`
- [ ] Run test — confirm it FAILS

### GREEN
- [ ] Add a `case '{type}':` branch to `_buildWidget()` in `lib/features/menu/domain/usecases/generate_pdf_usecase.dart`
- [ ] Implement `_build{Type}Widget()`
- [ ] Run test — confirm it PASSES

## Step 7 — Final Verification

- [ ] `flutter analyze --fatal-infos` — no warnings
- [ ] `flutter test` — all tests pass
- [ ] `dart format .` — no formatting issues
- [ ] Coverage remains ≥ 75 %

## Template Reference Files

| What to copy | Source (simplest template — `section_widget`) |
|---|---|
| Props class | `lib/features/widget_system/domain/widgets/section/section_props.dart` |
| Definition | `lib/features/widget_system/presentation/widgets/section_widget/section_widget_definition.dart` |
| Widget | `lib/features/widget_system/presentation/widgets/section_widget/section_widget.dart` |
| Edit dialog | `lib/features/widget_system/presentation/widgets/section_widget/section_edit_dialog.dart` |
| Props test | `test/unit/features/widget_system/domain/widgets/section/section_props_test.dart` |
| Definition test | `test/unit/features/widget_system/presentation/widgets/section_widget/section_widget_definition_test.dart` |
| Widget test | `test/widget/features/widget_system/presentation/widgets/section_widget/section_widget_test.dart` |

## Key Imports

```dart
// In your widget .dart file:
import 'package:oxo_menus/shared/presentation/helpers/edit_dialog_helper.dart';

// In your edit dialog .dart file:
import 'package:oxo_menus/shared/presentation/widgets/adaptive_edit_scaffold.dart';

// In your definition .dart file (for icon metadata):
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_definition.dart';
```
