# Testing Reference

## Structure

```
test/
├── helpers/                    # Shared utilities (test_image_data.dart)
├── integration/                # Directus integration tests
├── unit/                       # ~87 test files, mirrors lib/
│   ├── core/                   # Result, DomainError, router, URL resolver
│   ├── data/
│   │   ├── datasources/        # DirectusDataSource, SecureTokenStorage
│   │   ├── models/             # DTO serialization (9 files)
│   │   ├── mappers/            # Entity mapping (8 files)
│   │   └── repositories/       # Repo impl tests (8 files)
│   ├── domain/
│   │   ├── allergens/          # UkAllergen, AllergenInfo, formatter
│   │   ├── entities/           # All entity tests
│   │   ├── repositories/       # Domain repo input validation
│   │   ├── usecases/           # FetchMenuTree, DuplicateMenu
│   │   ├── widget_system/      # Definition, registry, migrator
│   │   └── widgets/            # Props tests (dish, image, section, text, wine)
│   ├── presentation/
│   │   ├── helpers/            # Status helpers
│   │   ├── pages/              # Notifier + state tests (admin_sizes, admin_templates, editor)
│   │   ├── providers/          # Auth, menu_list, repositories, usecases
│   │   ├── theme/              # AppTheme
│   │   └── widgets/            # Widget definition + editor tests
│   └── usecases/               # GeneratePdf, PdfStyleResolver
└── widget/                     # ~35 UI test files
    ├── pages/                  # Page widget tests (all 9 pages)
    ├── presentation/widgets/   # AllergenSelector, editor components, dialogs
    └── widgets/                # Common + type-specific widget render tests
```

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
5. Coverage ≥ 75% (LH/LF from lcov.info)

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
