# Testing Reference

## Structure

```
test/
├── helpers/                    # Shared utilities (test_image_data.dart)
├── integration/                # Directus integration tests
├── unit/                       # 130 test files, mirrors lib/
│   ├── core/                   # Result, DomainError, router, URL resolver
│   ├── data/
│   │   ├── datasources/        # DirectusDataSource, WebSocket, SecureTokenStorage
│   │   ├── models/             # DTO serialization (10 files)
│   │   ├── mappers/            # Entity mapping (13 files incl. lock fields)
│   │   └── repositories/       # Repo impl tests (12+ files incl. lock, subscription, presence, connectivity)
│   ├── domain/
│   │   ├── allergens/          # UkAllergen, AllergenInfo, formatter
│   │   ├── entities/           # All entity tests (incl. lock fields)
│   │   ├── repositories/       # Domain repo input validation
│   │   ├── usecases/           # FetchMenuTree, DuplicateMenu
│   │   ├── widget_system/      # Definition, registry, migrator, context
│   │   └── widgets/            # Props tests (dish, image, section, text, wine)
│   ├── presentation/
│   │   ├── helpers/            # Status, grid, edit dialog helpers
│   │   ├── pages/              # Notifier + state tests
│   │   ├── providers/          # Auth, menu_list, repos, usecases, widget_registry, connectivity
│   │   ├── theme/              # AppTheme
│   │   └── widgets/            # Widget definition + editor tests (all 5 types + CRUD helper)
│   └── usecases/               # GeneratePdf, PdfDocumentBuilder, PdfStyleResolver
└── widget/                     # 64 UI test files
    ├── pages/                  # Page widget tests (all 10 pages incl. live sync + presence)
    ├── presentation/widgets/   # AllergenSelector, editor components, dialogs, presence bar
    └── widgets/                # Common widgets + type-specific render tests
```

**Total:** 195 test files, 2023 test cases, 87.7% coverage

## Commands

```sh
flutter test                    # All tests
flutter test test/unit/         # Unit only
flutter test test/widget/       # Widget only
```

## CI (`deploy.yml`)

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter pub run build_runner build --delete-conflicting-outputs`
3. `flutter analyze --fatal-infos`
4. `flutter test --coverage --reporter expanded`
5. Coverage >= 75% (LH/LF from lcov.info)

## Mocking Patterns

### Library: `mocktail`

### Unit / Provider Tests

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

setUp(() {
  mockRepo = MockAuthRepository();
  when(() => mockRepo.tryRestoreSession())
      .thenAnswer((_) async => const Failure(UnauthorizedError()));
});
```

### Riverpod Provider Tests

```dart
late ProviderContainer container;
setUp(() {
  container = ProviderContainer(overrides: [
    directusDataSourceProvider.overrideWithValue(mockDataSource),
  ]);
});
tearDown(() => container.dispose());
```

### Widget Tests

```dart
Widget createWidgetUnderTest() => ProviderScope(
  overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
  child: MaterialApp(home: const PageUnderTest()),
);
testWidgets('displays widget', (tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  expect(find.text('Expected'), findsOneWidget);
});
```

## Key Conventions

- `registerFallbackValue()` in `setUpAll` for mocktail argument matchers
- Fake implementations for infrastructure: `FakeTokenStorage` (in-memory, avoids platform channels)
- Test image fixture: `kTestPngBytes` in `test/helpers/test_image_data.dart`
- Pages using widgets (MenuEditorPage, AdminTemplateEditorPage) must call `initializeReflectable()` and mock `widgetRepositoryProvider`
- DTO serialization tests verify JSON round-tripping
- State/Notifier tests verify loading, success, and error states

## Architectural Boundaries (enforced)

| Test Layer | May Mock | Must Not Import |
|------------|----------|-----------------|
| Domain | — | Infrastructure, DTOs, frameworks |
| Use cases | Repositories | Entities (use real ones) |
| UI / Widget | Use cases, providers | Data sources |
| Data / Repos | DirectusDataSource | — |
