# Plan: Add `isDroppable` Property to Column

## Context

The admin template editor allows admins to design menu templates with containers and columns. Currently, all columns unconditionally accept widget drops. The admin needs a way to lock specific columns so that non-admin users in the **menu editor** cannot drop widgets into them. The admin template editor itself remains unrestricted.

## Decisions

- **Field name**: `isDroppable` (entity) / `is_droppable` (Directus/DTO)
- **Default**: `true` — preserves current behavior, admin opts columns out
- **Scope**: Only the menu editor respects `isDroppable`; the admin template editor always allows drops
- **UI**: Toggle inside the existing "Column Style" `ExpansionTile` in the admin template editor

## Files to Modify

| Layer | File |
|-------|------|
| Entity | `lib/domain/entities/column.dart` |
| DTO | `lib/data/models/column_dto.dart` |
| Mapper | `lib/data/mappers/column_mapper.dart` |
| Repo interface | `lib/domain/repositories/column_repository.dart` |
| Repo impl | `lib/data/repositories/column_repository_impl.dart` |
| Admin editor | `lib/presentation/pages/admin_template_editor/admin_template_editor_page.dart` |
| Menu editor | `lib/presentation/pages/menu_editor/menu_editor_page.dart` |

## Implementation Steps (TDD: Red → Green → Refactor)

### Step 1 — Column Entity

**File**: `lib/domain/entities/column.dart`
**Test**: `test/unit/domain/entities/column_test.dart`

- [x] **RED**: Write test `isDroppable defaults to true` — fails (field doesn't exist)
- [x] **RED**: Write test `can be created with isDroppable: false` — fails
- [x] **RED**: Write test `copyWith(isDroppable: false) works` — fails
- [x] **GREEN**: Add `@Default(true) bool isDroppable` to the freezed `Column` class
- [x] **GREEN**: Run `build_runner` to regenerate `column.freezed.dart` / `column.g.dart`
- [x] Confirm all 3 tests pass

### Step 2 — Column DTO

**File**: `lib/data/models/column_dto.dart`
**Test**: `test/unit/data/models/column_dto_test.dart`

- [x] **RED**: Write test `isDroppable defaults to true when field absent` — fails (getter doesn't exist)
- [x] **GREEN**: Add getter `bool get isDroppable => getValue(forKey: "is_droppable") ?? true;`
- [x] Confirm test passes
- [x] **RED**: Write test `reads false when is_droppable: false in JSON` — should pass (verify)
- [x] **RED**: Write test `newItem(isDroppable: false) round-trips correctly` — fails (param doesn't exist)
- [x] **GREEN**: Add `bool? isDroppable` param to `ColumnDto.newItem`, call `setValue` when non-null
- [x] Confirm all DTO tests pass

### Step 3 — Column Mapper

**File**: `lib/data/mappers/column_mapper.dart`
**Test**: `test/unit/data/mappers/column_mapper_test.dart`

- [x] **RED**: Write test `toEntity maps is_droppable: false → isDroppable: false` — fails (mapper doesn't set field)
- [x] **GREEN**: Add `isDroppable: dto.isDroppable` to `toEntity`
- [x] Confirm test passes
- [x] **RED**: Write test `toEntity defaults to true when field absent` — should pass (verify)
- [x] **RED**: Write test `toDto maps isDroppable: false → is_droppable: false` — fails (not in map)
- [x] **GREEN**: Add `'is_droppable': entity.isDroppable` to `toDto` map
- [x] Confirm test passes
- [x] **RED**: Write test `toDto maps default true correctly` — should pass (verify)
- [x] Confirm all mapper tests pass

### Step 4 — Repository Input DTOs + Code Generation

**File**: `lib/domain/repositories/column_repository.dart`

- [x] Add `bool? isDroppable` to `CreateColumnInput`
- [x] Add `bool? isDroppable` to `UpdateColumnInput`
- [x] Run `build_runner` to regenerate `column_repository.freezed.dart`

### Step 5 — Repository Implementation

**File**: `lib/data/repositories/column_repository_impl.dart`
**Test**: `test/unit/data/repositories/column_repository_impl_test.dart`

- [x] **RED**: Write test `create with isDroppable: false returns entity with isDroppable: false` — fails
- [x] **GREEN**: Add `if (input.isDroppable != null) item.setValue(input.isDroppable, forKey: 'is_droppable');` to `create()`
- [x] Confirm test passes
- [x] **RED**: Write test `update with isDroppable: false calls setValue and returns correct entity` — fails
- [x] **GREEN**: Add same `setValue` pattern to `update()` after the `styleConfig` block
- [x] Confirm test passes
- [x] **RED**: Write test `getAllForContainer fields list includes is_droppable` — fails
- [x] **GREEN**: Add `'is_droppable'` to `fields` list in `getAllForContainer()`
- [x] Confirm test passes
- [x] **RED**: Write test `getById fields list includes is_droppable` — fails
- [x] **GREEN**: Add `'is_droppable'` to `fields` list in `getById()`
- [x] Confirm test passes
- [x] Confirm all repository tests pass

### Step 6 — Admin Template Editor UI

**File**: `lib/presentation/pages/admin_template_editor/admin_template_editor_page.dart`
**Test**: `test/widget/pages/admin_template_editor/admin_template_editor_page_test.dart`

- [x] **RED**: Write test `shows isDroppable toggle in expanded Column Style section` — fails (widget doesn't exist)
- [x] **GREEN**: Add `SwitchListTile` inside `ExpansionTile` children, before `PageStyleSection`:
  ```dart
  SwitchListTile(
    key: Key('is_droppable_toggle_${column.id}'),
    title: const Text('Allow Widget Drops'),
    subtitle: const Text('When off, this column is locked in the menu editor'),
    value: column.isDroppable,
    onChanged: (value) => _onColumnDroppableChanged(column.id, value),
    dense: true,
  ),
  ```
- [x] Confirm test passes
- [x] **RED**: Write test `toggling calls columnRepository.update with correct isDroppable value` — fails (handler doesn't exist)
- [x] **GREEN**: Add `_onColumnDroppableChanged(int columnId, bool isDroppable)` method (mirrors `_onColumnStyleChanged`)
- [x] Confirm test passes
- [x] **RED**: Write test `drop zones still present when isDroppable: false (admin unrestricted)` — should pass (verify)
- [x] Confirm all admin template editor tests pass

### Step 7 — Menu Editor Behavior

**File**: `lib/presentation/pages/menu_editor/menu_editor_page.dart`
**Test**: `test/widget/pages/menu_editor/menu_editor_page_test.dart`

- [x] **RED**: Write test `non-droppable column has no drop_zone_* keys in widget tree` — fails (drops always shown)
- [x] **RED**: Write test `non-droppable column with widgets still renders widgets` — fails
- [x] **RED**: Write test `non-droppable empty column shows lock icon` — fails
- [x] **GREEN**: Wrap drop zone loop in `if (column.isDroppable)` guard in `_buildColumnCard`:
  ```dart
  if (column.isDroppable) ...[
    // existing interleaved drop zones + widgets loop
    // existing empty state "Drop widgets here"
  ] else ...[
    // widgets only, no drop zones
    for (final widget in widgets)
      _buildWidgetItem(widget, column.id, registry),
    if (widgets.isEmpty)
      Center(child: Icon(Icons.lock, color: Colors.grey[400], size: 16)),
  ],
  ```
- [x] Confirm all 3 tests pass
- [x] **RED**: Write test `droppable column (default) still has drop zones` — should pass (regression guard)
- [x] Confirm all menu editor tests pass

## Verification

1. [x] Run all unit tests: `flutter test test/unit/` — **681 tests pass**
2. [x] Run all widget tests: `flutter test test/widget/` — **185 tests pass**
3. [x] Run full suite: `flutter test` — **866 tests pass**
4. [x] Run analyzer: `flutter analyze --fatal-infos` — **No issues found**
5. [x] Run formatter: `dart format .` — **61 files formatted**
6. [ ] Manual: launch app, open admin template editor, toggle "Allow Widget Drops" on a column, then open menu editor and verify the locked column rejects drops

## Note

A `is_droppable` boolean field (default `true`) needs to be created in the Directus `column` collection. This is infrastructure config outside TDD scope.
