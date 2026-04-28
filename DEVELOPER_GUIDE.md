# OXO Menus - Developer Guide

This guide provides technical documentation for developers working on the OXO Menus Flutter application.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Getting Started](#getting-started)
4. [Development Workflow](#development-workflow)
5. [Code Guidelines](#code-guidelines)
6. [Testing](#testing)
7. [State Management](#state-management)
8. [Widget System](#widget-system)
9. [API Integration](#api-integration)
10. [PDF Generation](#pdf-generation)
11. [Contributing](#contributing)

---

## Architecture Overview

OXO Menus follows **Clean Architecture** principles with strict layer separation.

### Layer Diagram

```
┌─────────────────────────────────────────────────┐
│          Presentation Layer                     │
│  (UI, Pages, Widgets, Providers, ViewModels)    │
└──────────────┬──────────────────────────────────┘
               │ Depends on Domain only
               ▼
┌─────────────────────────────────────────────────┐
│          Domain Layer                           │
│  (Entities, Repositories, Use Cases, Errors)    │
└──────────────┬──────────────────────────────────┘
               ▲ Implemented by
               │
┌──────────────┴──────────────────────────────────┐
│          Data Layer                             │
│  (Repository Impls, DTOs, Mappers, DataSources) │
└─────────────────────────────────────────────────┘
```

### Key Principles

1. **Dependency Rule**: Dependencies point inward (Presentation → Domain ← Data)
2. **Domain Independence**: Domain layer has no external dependencies
3. **Repository Pattern**: Abstract data access through interfaces
4. **Use Cases**: Encapsulate complex business logic
5. **Result Type**: Railway-oriented programming for error handling

### Technology Stack

| Layer | Technologies |
|-------|-------------|
| **Presentation** | Flutter, AppScope (`InheritedWidget`) + per-feature `ChangeNotifier` ViewModels, in-house OxoRouter |
| **Domain** | Pure Dart (no dependencies) |
| **Data** | directus_api_manager, freezed, json_serializable |
| **Testing** | flutter_test, mocktail, integration_test |
| **Build** | build_runner, freezed, riverpod_generator |

---

## Project Structure

```
lib/
├── core/                       # Core utilities
│   ├── errors/                 # Domain error types
│   │   └── domain_errors.dart
│   └── types/                  # Shared types (Result)
│       └── result.dart
│
├── domain/                     # Business logic (pure Dart)
│   ├── entities/               # Core business entities
│   │   ├── menu.dart
│   │   ├── page.dart
│   │   ├── container.dart
│   │   ├── column.dart
│   │   ├── widget_instance.dart
│   │   └── user.dart
│   │
│   ├── repositories/           # Repository interfaces
│   │   ├── menu_repository.dart
│   │   ├── page_repository.dart
│   │   ├── container_repository.dart
│   │   ├── column_repository.dart
│   │   ├── widget_repository.dart
│   │   └── auth_repository.dart
│   │
│   ├── usecases/               # Business use cases
│   │   ├── fetch_menu_tree_usecase.dart
│   │   └── generate_pdf_usecase.dart
│   │
│   ├── widgets/                # Widget props definitions
│   │   ├── dish/
│   │   │   └── dish_props.dart
│   │   ├── section/
│   │   │   └── section_props.dart
│   │   └── text/
│   │       └── text_props.dart
│   │
│   └── widget_system/          # Widget registry
│       ├── widget_definition.dart
│       ├── widget_registry.dart
│       └── widget_migrator.dart
│
├── data/                       # Data layer
│   ├── datasources/            # Data sources
│   │   └── directus_data_source.dart
│   │
│   ├── models/                 # DTOs (Data Transfer Objects)
│   │   ├── menu_dto.dart
│   │   ├── page_dto.dart
│   │   ├── container_dto.dart
│   │   ├── column_dto.dart
│   │   ├── widget_dto.dart
│   │   └── user_dto.dart
│   │
│   ├── mappers/                # DTO ↔ Entity mappers
│   │   ├── menu_mapper.dart
│   │   ├── page_mapper.dart
│   │   ├── error_mapper.dart
│   │   └── ...
│   │
│   └── repositories/           # Repository implementations
│       ├── menu_repository_impl.dart
│       ├── page_repository_impl.dart
│       ├── auth_repository_impl.dart
│       └── ...
│
└── presentation/               # UI layer
    ├── pages/                  # Full screen pages
    │   ├── login/
    │   │   └── login_page.dart
    │   ├── menu_list/
    │   │   └── menu_list_page.dart
    │   └── menu_editor/
    │       └── menu_editor_page.dart
    │
    ├── widgets/                # Reusable UI widgets
    │   ├── dish_widget/
    │   │   ├── dish_widget.dart
    │   │   ├── dish_edit_dialog.dart
    │   │   └── dish_widget_definition.dart
    │   ├── template_canvas.dart
    │   └── widget_renderer.dart
    │
    └── providers/              # Riverpod providers
        ├── repositories_provider.dart
        ├── usecases_provider.dart
        ├── auth_provider.dart
        └── widget_registry_provider.dart

test/
├── unit/                       # Unit tests
│   ├── core/
│   ├── domain/
│   └── data/
│
├── widget/                     # Widget tests
│   ├── pages/
│   └── widgets/
│
└── integration_test/           # Integration tests
    └── login_flow_test.dart
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0+
- Dart SDK 3.0.0+
- VS Code or Android Studio with Flutter extensions
- Git
- Docker Desktop (for backend)

### Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd oxo_menus

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Start backend (Docker)
docker-compose up -d directus

# Run the app (web)
flutter run -d chrome --dart-define=DIRECTUS_URL=http://localhost:8055

# Or run on mobile
flutter run -d <device-id>
```

### Environment Setup

Create `.env` file:

```env
DIRECTUS_URL=http://localhost:8055
```

### IDE Setup

**VS Code**: Install extensions
- Flutter
- Dart
- Bloc (for Riverpod snippets)
- Error Lens

**Android Studio**: Install plugins
- Flutter
- Dart

### Recommended VS Code Settings

```json
{
  "dart.lineLength": 120,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true,
    "editor.rulers": [120]
  }
}
```

---

## Development Workflow

### Code Generation

The project uses code generation for:
- Freezed (immutable entities and DTOs)
- JSON Serialization
- Riverpod code generation

```bash
# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner build --delete-conflicting-outputs --delete-conflicting-outputs
```

### Running the App

```bash
# Web (recommended for development)
flutter run -d chrome --dart-define=DIRECTUS_URL=http://localhost:8055

# Android
flutter run -d <android-device-id>

# iOS (macOS only)
flutter run -d <ios-device-id>

# List devices
flutter devices
```

### Hot Reload

While app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `h` for help
- Press `q` to quit

### Building

```bash
# Web (production)
flutter build web --release --dart-define=DIRECTUS_URL=<production-url>

# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only, requires code signing)
flutter build ios --release
```

---

## Code Guidelines

### Naming Conventions

**Files**:
- Entities: `menu.dart`, `page.dart`
- DTOs: `menu_dto.dart`, `page_dto.dart`
- Mappers: `menu_mapper.dart`, `error_mapper.dart`
- Repositories: `menu_repository.dart` (interface), `menu_repository_impl.dart` (implementation)
- Use cases: `fetch_menu_tree_usecase.dart`
- Providers: `auth_provider.dart`, `repositories_provider.dart`
- Pages: `login_page.dart`, `menu_list_page.dart`

**Classes**:
- Entities: `Menu`, `Page`, `WidgetInstance`
- DTOs: `MenuDto`, `PageDto`
- Mappers: `MenuMapper`, `ErrorMapper`
- Repositories: `MenuRepository` (interface), `MenuRepositoryImpl` (implementation)
- Use cases: `FetchMenuTreeUseCase`
- Providers: `authProvider`, `menuRepositoryProvider`

**Variables**:
- camelCase: `menuId`, `userName`, `isLoading`
- Private: `_menuId`, `_controller`

### Code Style

**Follow flutter_lints**:
```bash
flutter analyze
```

**Key rules**:
- Always use `const` constructors where possible
- Prefer final over var
- Use trailing commas for multi-line lists
- Max line length: 120 characters
- Use named parameters for more than 2 arguments
- Prefer async/await over `.then()`

**Example**:
```dart
// Good
class MenuListPage extends ConsumerWidget {
  const MenuListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menuListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menus'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: state.menus.length,
              itemBuilder: (context, index) {
                return MenuListItem(menu: state.menus[index]);
              },
            ),
    );
  }
}

// Bad
class MenuListPage extends ConsumerWidget {
  @override
  Widget build(context, ref) {  // Missing const, super.key
    var state = ref.watch(menuListProvider);  // Use final, not var
    return Scaffold(
      appBar: AppBar(title: Text('Menus')),  // Missing const
      body: state.isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(itemCount: state.menus.length, itemBuilder: (context, index) => MenuListItem(menu: state.menus[index]))  // Poor formatting
    );
  }
}
```

### Documentation

**Public APIs**: Always document
```dart
/// Fetches the complete menu tree including all pages, containers, columns, and widgets.
///
/// Returns [MenuTree] on success, or [DomainError] on failure.
///
/// Example:
/// ```dart
/// final result = await fetchMenuTreeUseCase.execute('menu-123');
/// result.fold(
///   onSuccess: (menuTree) => print(menuTree.menu.name),
///   onFailure: (error) => print(error.message),
/// );
/// ```
Future<Result<MenuTree, DomainError>> execute(String menuId);
```

**Complex logic**: Add inline comments
```dart
// Sort pages by index to maintain order
final pages = pagesResult.valueOrNull!
  ..sort((a, b) => a.index.compareTo(b.index));
```

---

## Testing

### Test-Driven Development (TDD)

**Always follow TDD**:
1. Write failing test first
2. Write minimal code to pass
3. Refactor

**Example TDD Cycle**:

```dart
// 1. Write failing test
test('should return menu when fetch succeeds', () async {
  // Arrange
  when(() => mockRepo.getById('menu-1'))
      .thenAnswer((_) async => Success(mockMenu));

  // Act
  final result = await useCase.execute('menu-1');

  // Assert
  expect(result.isSuccess, true);
  expect(result.valueOrNull, mockMenu);
});

// 2. Write minimal code
Future<Result<MenuTree, DomainError>> execute(String menuId) async {
  final menuResult = await menuRepository.getById(menuId);
  if (menuResult.isFailure) {
    return Failure(menuResult.errorOrNull!);
  }

  return Success(MenuTree(menu: menuResult.valueOrNull!, pages: []));
}

// 3. Refactor (if needed)
```

### Unit Tests

**Location**: `test/unit/`

**Test structure**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late MenuListNotifier notifier;
  late MockMenuRepository mockRepo;

  setUp(() {
    mockRepo = MockMenuRepository();
    notifier = MenuListNotifier(mockRepo);
  });

  group('MenuListNotifier', () {
    test('should load menus successfully', () async {
      // Arrange
      final menus = [Menu(id: '1', name: 'Test Menu')];
      when(() => mockRepo.listAll(onlyPublished: true))
          .thenAnswer((_) async => Success(menus));

      // Act
      await notifier.loadMenus();

      // Assert
      expect(notifier.state.menus, menus);
      expect(notifier.state.isLoading, false);
      verify(() => mockRepo.listAll(onlyPublished: true)).called(1);
    });

    test('should handle error when load fails', () async {
      // Arrange
      const error = NetworkError('Connection failed');
      when(() => mockRepo.listAll(onlyPublished: true))
          .thenAnswer((_) async => Failure(error));

      // Act
      await notifier.loadMenus();

      // Assert
      expect(notifier.state.errorMessage, 'Connection failed');
      expect(notifier.state.isLoading, false);
    });
  });
}
```

### Widget Tests

**Location**: `test/widget/`

```dart
testWidgets('should display dish name and price', (tester) async {
  // Arrange
  const props = DishProps(name: 'Pasta', price: 12.50);

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DishWidget(
          props: props,
          context: const WidgetContext(isEditable: false),
        ),
      ),
    ),
  );

  // Assert
  expect(find.text('Pasta'), findsOneWidget);
  expect(find.text('\$12.50'), findsOneWidget);
});
```

### Integration Tests

**Location**: `integration_test/`

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete login flow', (tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Enter credentials
    await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password_field')), 'password');

    // Submit
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();

    // Verify navigation
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit/domain/usecases/fetch_menu_tree_usecase_test.dart

# With coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Integration tests
flutter test integration_test/
```

### Coverage Goals

- Domain layer: 100%
- Data layer: >90%
- Presentation layer: >70%
- Overall: >85%

---

## State Management

### Riverpod Architecture

OXO Menus uses **flutter_riverpod** for state management.

### Provider Types

**Provider** (read-only):
```dart
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl(
    dataSource: ref.watch(directusDataSourceProvider),
  );
});
```

**StateNotifierProvider** (mutable state):
```dart
final menuListProvider = StateNotifierProvider<MenuListNotifier, MenuListState>((ref) {
  return MenuListNotifier(ref.watch(menuRepositoryProvider));
});
```

**FutureProvider** (async data):
```dart
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final result = await authRepo.getCurrentUser();
  return result.valueOrNull;
});
```

### Creating a Notifier

**State class** (Freezed):
```dart
@freezed
class MenuListState with _$MenuListState {
  const factory MenuListState({
    @Default([]) List<Menu> menus,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _MenuListState;
}
```

**Notifier**:
```dart
class MenuListNotifier extends StateNotifier<MenuListState> {
  final MenuRepository _menuRepository;

  MenuListNotifier(this._menuRepository) : super(const MenuListState());

  Future<void> loadMenus({bool onlyPublished = true}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _menuRepository.listAll(onlyPublished: onlyPublished);

    result.fold(
      onSuccess: (menus) {
        state = state.copyWith(menus: menus, isLoading: false);
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }
}
```

**Provider**:
```dart
final menuListProvider = StateNotifierProvider<MenuListNotifier, MenuListState>((ref) {
  return MenuListNotifier(ref.watch(menuRepositoryProvider));
});
```

### Consuming Providers

**In ConsumerWidget**:
```dart
class MenuListPage extends ConsumerWidget {
  const MenuListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menuListProvider);

    return Scaffold(
      body: state.isLoading
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: state.menus.length,
              itemBuilder: (context, index) {
                return MenuListItem(menu: state.menus[index]);
              },
            ),
    );
  }
}
```

**Listening to changes**:
```dart
ref.listen(authProvider, (previous, next) {
  next.whenOrNull(
    authenticated: (user) => context.go('/home'),
    error: (message) => showError(message),
  );
});
```

**Calling methods**:
```dart
onPressed: () {
  ref.read(menuListProvider.notifier).loadMenus();
}
```

---

## Widget System

### Creating a New Widget Type

#### 1. Define Props (Domain)

```dart
// lib/domain/widgets/custom/custom_props.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_props.freezed.dart';
part 'custom_props.g.dart';

@freezed
class CustomProps with _$CustomProps {
  const factory CustomProps({
    required String title,
    @Default('') String subtitle,
    @Default(false) bool highlighted,
  }) = _CustomProps;

  factory CustomProps.fromJson(Map<String, dynamic> json) =>
      _$CustomPropsFromJson(json);
}
```

#### 2. Create Widget UI (Presentation)

```dart
// lib/presentation/widgets/custom_widget/custom_widget.dart
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/widgets/custom/custom_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';

class CustomWidget extends StatelessWidget {
  final CustomProps props;
  final WidgetContext context;

  const CustomWidget({
    super.key,
    required this.props,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Card(
        color: props.highlighted ? Colors.yellow[100] : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                props.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (props.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(props.subtitle),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleEdit(BuildContext buildContext) {
    // Show edit dialog
    showDialog(
      context: buildContext,
      builder: (context) => CustomEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
  }
}
```

#### 3. Create Widget Definition

```dart
// lib/presentation/widgets/custom_widget/custom_widget_definition.dart
import 'package:oxo_menus/domain/widgets/custom/custom_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'custom_widget.dart';

final customWidgetDefinition = WidgetDefinition<CustomProps>(
  type: 'custom',
  version: '1.0.0',
  parseProps: (json) => CustomProps.fromJson(json),
  render: (props, context) => CustomWidget(
    props: props,
    context: context,
  ),
  defaultProps: const CustomProps(
    title: 'New Custom Widget',
    subtitle: '',
    highlighted: false,
  ),
);
```

#### 4. Register Widget

```dart
// lib/presentation/providers/widget_registry_provider.dart
final widgetRegistryProvider = Provider<WidgetRegistry>((ref) {
  final registry = WidgetRegistry();

  // Register built-in widgets
  registry.register(dishWidgetDefinition);
  registry.register(sectionWidgetDefinition);
  registry.register(textWidgetDefinition);

  // Register custom widget
  registry.register(customWidgetDefinition);

  return registry;
});
```

#### 5. Add Tests

```dart
// test/widget/widgets/custom_widget_test.dart
testWidgets('should display title', (tester) async {
  const props = CustomProps(title: 'Test Title');

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CustomWidget(
          props: props,
          context: const WidgetContext(isEditable: false),
        ),
      ),
    ),
  );

  expect(find.text('Test Title'), findsOneWidget);
});
```

---

## API Integration

### Directus Data Source

**Location**: `lib/data/datasources/directus_data_source.dart`

**Usage**:
```dart
class DirectusDataSource {
  final DirectusAPI api;

  DirectusDataSource({required String baseUrl})
      : api = DirectusAPI(baseUrl: baseUrl);

  // Get single item
  Future<Map<String, dynamic>> getItem(
    String collection,
    String id, {
    List<String>? fields,
  }) async {
    return await api.getItemById(
      collection: collection,
      id: id,
      fields: fields,
    );
  }

  // Get multiple items
  Future<List<Map<String, dynamic>>> getItems(
    String collection, {
    Map<String, dynamic>? filter,
    List<String>? fields,
  }) async {
    return await api.getItems(
      collection: collection,
      filter: filter,
      fields: fields,
    );
  }
}
```

### Repository Implementation Pattern

```dart
class MenuRepositoryImpl implements MenuRepository {
  final DirectusDataSource dataSource;
  static const String collection = 'menu';

  const MenuRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Menu, DomainError>> getById(String id) async {
    try {
      // 1. Fetch from data source
      final data = await dataSource.getItem(collection, id);

      // 2. Map to DTO
      final dto = MenuDto.fromJson(data);

      // 3. Map to entity
      final menu = MenuMapper.toEntity(dto);

      // 4. Return success
      return Success(menu);
    } catch (e) {
      // 5. Map errors
      return Failure(mapDirectusError(e));
    }
  }
}
```

### Error Handling

```dart
// lib/data/mappers/error_mapper.dart
DomainError mapDirectusError(dynamic error) {
  if (error is DirectusException) {
    switch (error.code) {
      case 'INVALID_CREDENTIALS':
        return InvalidCredentialsError(error.message);
      case 'NOT_FOUND':
        return NotFoundError(error.message);
      case 'FORBIDDEN':
        return UnauthorizedError(error.message);
      default:
        return ServerError(error.message);
    }
  }

  if (error is NetworkException) {
    return NetworkError(error.toString());
  }

  return UnknownError(error.toString());
}
```

---

## PDF Generation

### Use Case Implementation

**Location**: `lib/domain/usecases/generate_pdf_usecase.dart`

**Key components**:
```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class GeneratePdfUseCase {
  Future<Result<Uint8List, DomainError>> execute(MenuTree menuTree) async {
    try {
      final pdf = pw.Document();

      // Add pages
      for (final pageData in menuTree.pages) {
        pdf.addPage(
          pw.Page(
            pageFormat: _getPageFormat(menuTree.menu.pageSize),
            build: (context) => _buildPage(pageData, menuTree.menu.styleConfig),
          ),
        );
      }

      final bytes = await pdf.save();
      return Success(bytes);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  pw.Widget _buildPage(PageWithContainers pageData, StyleConfig? style) {
    return pw.Column(
      children: pageData.containers.map((containerData) {
        return pw.Row(
          children: containerData.columns.map((columnData) {
            return pw.Expanded(
              flex: columnData.column.flex ?? 1,
              child: pw.Column(
                children: columnData.widgets.map((widget) {
                  return _buildWidget(widget, style);
                }).toList(),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
```

### Adding Widget to PDF

```dart
pw.Widget _buildCustomWidget(WidgetInstance widget, StyleConfig? style) {
  final props = CustomProps.fromJson(widget.props);

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    color: props.highlighted ? PdfColors.yellow100 : null,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          props.title,
          style: pw.TextStyle(
            fontSize: (style?.fontSize ?? 14) + 2,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (props.subtitle.isNotEmpty)
          pw.Text(props.subtitle),
      ],
    ),
  );
}
```

---

## Contributing

### Branching Strategy

**Main branches**:
- `main`: Production-ready code
- `develop`: Integration branch for features

**Feature branches**:
- `feature/widget-system`: New features
- `bugfix/login-error`: Bug fixes
- `refactor/repository-pattern`: Refactoring

### Commit Messages

Follow Conventional Commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Build/config changes

**Examples**:
```
feat(widget): add custom widget type

- Create CustomProps entity
- Implement CustomWidget UI
- Add widget definition
- Register in widget registry
- Add tests

Closes #123

fix(auth): handle token expiration correctly

The refresh token wasn't being called when the access token expired.
Now properly catches TokenExpiredError and refreshes.

Fixes #456
```

### Pull Request Process

1. Create feature branch from `develop`
2. Make changes following TDD
3. Run tests: `flutter test`
4. Run linter: `flutter analyze`
5. Format code: `dart format .`
6. Push branch and create PR
7. Request review from maintainer
8. Address review comments
9. Squash and merge

### Code Review Checklist

**Reviewer checks**:
- [ ] Tests pass
- [ ] Code follows guidelines
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Performance considered
- [ ] Security reviewed
- [ ] Accessibility considered

---

## Debugging

### Common Issues

**Issue**: "Build runner fails"
**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue**: "Tests fail after code generation"
**Solution**:
```bash
# Regenerate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test
```

**Issue**: "API returns 401"
**Solution**:
- Check DIRECTUS_URL environment variable
- Verify Directus is running
- Check CORS settings in Directus
- Verify authentication token

### Logging

```dart
// Use print for temporary debugging
print('Menu loaded: ${menu.name}');

// For production, use logging package
import 'package:logging/logging.dart';

final _log = Logger('MenuListNotifier');

_log.info('Loading menus');
_log.warning('No menus found');
_log.severe('Failed to load menus', error, stackTrace);
```

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Directus API Reference](https://docs.directus.io/reference/introduction)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Version**: 1.0.0
**Last Updated**: January 2024
