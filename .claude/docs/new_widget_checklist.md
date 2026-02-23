# Creating a New Widget Type

Use `section_widget` as the template — it's the simplest widget.
Replace `{type}` with your widget name (e.g., `cocktail`) and `{Type}` with PascalCase (e.g., `Cocktail`).

## Step 1: Domain Props (TDD)

### RED
- [ ] Create `test/unit/domain/widgets/{type}/{type}_props_test.dart`
- [ ] Write tests: construction with required/optional fields, defaults, copyWith, JSON round-trip (fromJson/toJson)
- [ ] Run tests — confirm they FAIL (class doesn't exist yet)

### GREEN
- [ ] Create `lib/domain/widgets/{type}/{type}_props.dart`
- [ ] Define freezed class `{Type}Props` with fields
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Run tests — confirm they PASS

## Step 2: Widget Definition (TDD)

### RED
- [ ] Create `test/unit/presentation/widgets/{type}_widget/{type}_widget_definition_test.dart`
- [ ] Write tests: type string, version, defaultProps values, parseProps from JSON
- [ ] Run tests — confirm they FAIL

### GREEN
- [ ] Create `lib/presentation/widgets/{type}_widget/{type}_widget_definition.dart`
- [ ] Define `final {type}WidgetDefinition = WidgetDefinition<{Type}Props>(...)`
- [ ] Set: type, version ('1.0.0'), displayName, materialIcon, cupertinoIcon, parseProps, render (placeholder), defaultProps
- [ ] Run tests — confirm they PASS

## Step 3: Widget Rendering (TDD)

### RED
- [ ] Create `test/widget/widgets/{type}_widget_test.dart`
- [ ] Write tests: renders with default props, renders with custom props, respects displayOptions, editable vs non-editable behavior
- [ ] Run tests — confirm they FAIL

### GREEN
- [ ] Create `lib/presentation/widgets/{type}_widget/{type}_widget.dart`
- [ ] Implement `{Type}Widget extends StatelessWidget` with `props` and `context` fields
- [ ] Use `showEditDialog()` helper in `_handleEdit` (not manual platform check)
- [ ] Run tests — confirm they PASS

## Step 4: Edit Dialog (TDD)

### RED
- [ ] Add edit dialog tests to the widget test file or create `test/widget/widgets/{type}_edit_dialog_test.dart`
- [ ] Write tests: dialog opens, fields pre-populated, onSave returns updated props, Cancel pops
- [ ] Run tests — confirm they FAIL

### GREEN
- [ ] Create `lib/presentation/widgets/{type}_widget/{type}_edit_dialog.dart`
- [ ] Use `AdaptiveEditScaffold` for the shell (title, onSave, appleFormChildren, materialFormChildren)
- [ ] Define form fields in the children lists — only the form content, no shell boilerplate
- [ ] Run tests — confirm they PASS

## Step 5: Registration

- [ ] Add `import` and `{type}WidgetDefinition` entry to `allWidgetDefinitions` in `lib/presentation/providers/widget_registry_provider.dart`
- [ ] Run `flutter test test/unit/presentation/providers/widget_registry_provider_test.dart` — update count assertion if needed

## Step 6: PDF Rendering (TDD)

### RED
- [ ] Add test for new widget type in `test/unit/domain/usecases/generate_pdf_usecase_test.dart`
- [ ] Run test — confirm it FAILS

### GREEN
- [ ] Add `case '{type}':` to `_buildWidget()` in `lib/domain/usecases/generate_pdf_usecase.dart`
- [ ] Implement `_build{Type}Widget()` method
- [ ] Run test — confirm it PASSES

## Step 7: Final Verification

- [ ] `flutter analyze --fatal-infos` — no warnings
- [ ] `flutter test` — all tests pass
- [ ] `dart format .` — no formatting issues
- [ ] Coverage remains above 75%

## Template Reference Files

| What to copy | Source (simplest template) |
|---|---|
| Props class | `lib/domain/widgets/section/section_props.dart` |
| Definition | `lib/presentation/widgets/section_widget/section_widget_definition.dart` |
| Widget | `lib/presentation/widgets/section_widget/section_widget.dart` |
| Edit dialog | `lib/presentation/widgets/section_widget/section_edit_dialog.dart` |
| Props test | `test/unit/domain/widgets/section/section_props_test.dart` |
| Definition test | `test/unit/presentation/widgets/section_widget/section_widget_definition_test.dart` |
| Widget test | `test/widget/widgets/section_widget_test.dart` |

## Key Imports

```dart
// In your widget .dart file:
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';

// In your edit dialog .dart file:
import 'package:oxo_menus/presentation/widgets/common/adaptive_edit_scaffold.dart';

// In your definition .dart file (for icon metadata):
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
```
