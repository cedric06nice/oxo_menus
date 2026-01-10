# Flutter Migration Guide - OXO Menus

This document provides complete guidance for recreating the OXO Menus application in Flutter from scratch using Test-Driven Development (TDD).

## Table of Contents

1. [Project Overview](#project-overview)
2. [User Roles & Workflows](#user-roles--workflows)
3. [Architecture](#architecture)
4. [Domain Model](#domain-model)
5. [Testing Strategy (TDD)](#testing-strategy-tdd)
6. [Directus Integration](#directus-integration)
7. [State Management with Riverpod](#state-management-with-riverpod)
8. [UI/UX Implementation](#uiux-implementation)
9. [Widget System](#widget-system)
10. [PDF Generation](#pdf-generation)
11. [Implementation Roadmap](#implementation-roadmap)
12. [Package Dependencies](#package-dependencies)

---

## Project Overview

OXO Menus is a menu template management application where:

- **Admin users** create and manage reusable menu templates with customizable layouts
- **Regular users** use these templates to create actual menus by placing and editing widgets (dishes, sections, etc.)
- **Output** is a printable PDF menu matching the exact visual layout

### Key Characteristics

- **Backend**: Directus CMS (existing schema)
- **Architecture**: Clean Architecture with clear layer separation
- **State Management**: flutter_riverpod
- **Development**: Test-Driven Development (TDD)
- **Platforms**: iOS, Android, Web
- **Offline**: Not required initially

---

## User Roles & Workflows

### Admin Users

**Goal**: Create and publish reusable menu templates

**Capabilities**:

1. Create new menu templates
2. Define template structure:
   - Add/remove/reorder pages
   - Add/remove/reorder containers (sections) within pages
   - Add/remove/reorder columns within containers
   - Set column widths/layouts
3. Configure which widget types are available in the template
4. Create new custom widget types (extensible palette)
5. Set template styling (colors, fonts, spacing, page size, margins)
6. Publish templates (draft → published status)
7. Version templates

**Access**: Admin-only screens for template editing

### Regular Users

**Goal**: Use published templates to create actual menus

**Capabilities**:

1. Browse and select from published templates
2. Drag widgets from palette into containers/columns
3. Edit widget data (dish name, price, allergens, etc.)
4. Reorder widgets within and across columns/containers
5. Customize styling (colors, fonts, spacing)
6. Generate PDF menu matching the exact visual layout

**Restrictions**:

- Cannot modify template structure (pages, containers, columns)
- Can only see published templates
- Cannot create new widget types

---

## Architecture

The Flutter application follows **Clean Architecture** with strict layer separation and dependency inversion.

### Layer Structure

```
lib/
├── domain/              # Business logic (pure Dart, no external dependencies)
│   ├── entities/        # Core business entities
│   ├── repositories/    # Repository interfaces (abstract classes)
│   ├── usecases/        # Business use cases
│   └── core/            # Result type, errors, value objects
├── data/                # Data layer (implements domain contracts)
│   ├── repositories/    # Repository implementations
│   ├── datasources/     # Remote/local data sources
│   ├── models/          # DTOs (Data Transfer Objects)
│   └── mappers/         # DTO ↔ Entity mappers
├── presentation/        # UI layer
│   ├── pages/           # Full screens
│   ├── widgets/         # Reusable UI components
│   ├── providers/       # Riverpod providers
│   └── viewmodels/      # Screen state management
└── core/                # App-level configuration
    ├── di/              # Dependency injection setup
    ├── routing/         # Navigation configuration
    └── constants/       # App constants
```

### Dependency Rule

- **Domain** depends on nothing (pure Dart)
- **Data** depends on Domain only
- **Presentation** depends on Domain only (not Data)
- Dependencies point inward

### Key Architectural Patterns

#### 1. Result Type (Railway-Oriented Programming)

All operations that can fail return a `Result<T, E>` instead of throwing exceptions.

```dart
sealed class Result<T, E> {
  const Result();
}

class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

class Failure<T, E> extends Result<T, E> {
  final E error;
  const Failure(this.error);
}

// Extension methods for convenience
extension ResultX<T, E> on Result<T, E> {
  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        Failure(:final error) => onFailure(error),
      };
}
```

#### 2. Domain Errors

All errors are modeled as domain-specific types:

```dart
sealed class DomainError {
  final String message;
  final dynamic details;
  const DomainError(this.message, {this.details});
}

// Authentication errors
class InvalidCredentialsError extends DomainError {
  const InvalidCredentialsError([String message = 'Invalid credentials'])
      : super(message);
}

class TokenExpiredError extends DomainError {
  const TokenExpiredError([String message = 'Token expired']) : super(message);
}

class UnauthorizedError extends DomainError {
  const UnauthorizedError([String message = 'Unauthorized']) : super(message);
}

// Network errors
class NetworkError extends DomainError {
  const NetworkError([String message = 'Network error']) : super(message);
}

class NetworkUnavailableError extends DomainError {
  const NetworkUnavailableError([String message = 'Network unavailable'])
      : super(message);
}

// Data errors
class NotFoundError extends DomainError {
  const NotFoundError([String message = 'Resource not found']) : super(message);
}

class ValidationError extends DomainError {
  const ValidationError(String message, {dynamic details})
      : super(message, details: details);
}

// Server errors
class ServerError extends DomainError {
  const ServerError([String message = 'Server error']) : super(message);
}

class UnknownError extends DomainError {
  const UnknownError([String message = 'Unknown error'], {dynamic details})
      : super(message, details: details);
}
```

---

## Domain Model

### Entity Hierarchy

The application manages a hierarchical structure:

```
Menu (root entity)
  ├── Pages (ordered list)
  │   └── Containers/Sections (ordered list)
  │       └── Columns (ordered list)
  │           └── Widgets (ordered list)
  └── Metadata (styling, versioning, status)
```

### Core Entities

#### Menu Entity

Represents a menu template (created by admin) or menu instance (used by regular user).

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu.freezed.dart';
part 'menu.g.dart';

@freezed
class Menu with _$Menu {
  const factory Menu({
    required String id,
    required String name,
    required MenuStatus status,
    required String version,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? userCreated,
    String? userUpdated,
    StyleConfig? styleConfig,
    PageSize? pageSize,
    String? area,
    // Relations loaded separately
  }) = _Menu;

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
}

enum MenuStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('archived')
  archived;
}

@freezed
class StyleConfig with _$StyleConfig {
  const factory StyleConfig({
    String? fontFamily,
    double? fontSize,
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    double? marginTop,
    double? marginBottom,
    double? marginLeft,
    double? marginRight,
    double? padding,
    // Additional style properties as needed
  }) = _StyleConfig;

  factory StyleConfig.fromJson(Map<String, dynamic> json) =>
      _$StyleConfigFromJson(json);
}

@freezed
class PageSize with _$PageSize {
  const factory PageSize({
    required String name, // e.g., "A4", "Letter", "Custom"
    required double width, // in mm or points
    required double height,
  }) = _PageSize;

  factory PageSize.fromJson(Map<String, dynamic> json) =>
      _$PageSizeFromJson(json);
}
```

#### Page Entity

Represents a page within a menu.

```dart
@freezed
class Page with _$Page {
  const factory Page({
    required String id,
    required String menuId,
    required String name,
    required int index, // Sort order
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _Page;

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);
}
```

#### Container Entity

Represents a section/container on a page (horizontal grouping of columns).

```dart
@freezed
class Container with _$Container {
  const factory Container({
    required String id,
    required String pageId,
    required int index, // Sort order
    String? name,
    LayoutConfig? layout,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _Container;

  factory Container.fromJson(Map<String, dynamic> json) =>
      _$ContainerFromJson(json);
}

@freezed
class LayoutConfig with _$LayoutConfig {
  const factory LayoutConfig({
    String? direction, // 'row', 'column'
    String? alignment,
    double? spacing,
  }) = _LayoutConfig;

  factory LayoutConfig.fromJson(Map<String, dynamic> json) =>
      _$LayoutConfigFromJson(json);
}
```

#### Column Entity

Represents a column within a container.

```dart
@freezed
class Column with _$Column {
  const factory Column({
    required String id,
    required String containerId,
    required int index, // Sort order
    int? flex, // Flex factor for width distribution
    double? width, // Fixed width (alternative to flex)
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _Column;

  factory Column.fromJson(Map<String, dynamic> json) => _$ColumnFromJson(json);
}
```

#### Widget Entity

Represents a widget instance placed in a column.

```dart
@freezed
class WidgetInstance with _$WidgetInstance {
  const factory WidgetInstance({
    required String id,
    required String columnId,
    required String type, // Widget type identifier (e.g., 'dish', 'separator')
    required String version, // Semver version for migrations
    required int index, // Sort order
    required Map<String, dynamic> props, // Widget-specific data
    WidgetStyle? style, // Widget-specific styling overrides
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _WidgetInstance;

  factory WidgetInstance.fromJson(Map<String, dynamic> json) =>
      _$WidgetInstanceFromJson(json);
}

@freezed
class WidgetStyle with _$WidgetStyle {
  const factory WidgetStyle({
    String? fontFamily,
    double? fontSize,
    String? color,
    String? backgroundColor,
    String? border,
    double? padding,
    // Additional style properties
  }) = _WidgetStyle;

  factory WidgetStyle.fromJson(Map<String, dynamic> json) =>
      _$WidgetStyleFromJson(json);
}
```

#### User Entity

Represents a user (admin or regular).

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? avatar,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('user')
  user;
}
```

### Repository Interfaces

All repository interfaces are defined in the domain layer as abstract classes.

```dart
// domain/repositories/menu_repository.dart
abstract class MenuRepository {
  Future<Result<Menu, DomainError>> create(CreateMenuInput input);
  Future<Result<List<Menu>, DomainError>> listAll({bool onlyPublished = true});
  Future<Result<Menu, DomainError>> getById(String id);
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input);
  Future<Result<void, DomainError>> delete(String id);
}

// domain/repositories/page_repository.dart
abstract class PageRepository {
  Future<Result<Page, DomainError>> create(CreatePageInput input);
  Future<Result<List<Page>, DomainError>> getAllForMenu(String menuId);
  Future<Result<Page, DomainError>> getById(String id);
  Future<Result<Page, DomainError>> update(UpdatePageInput input);
  Future<Result<void, DomainError>> delete(String id);
  Future<Result<void, DomainError>> reorder(String pageId, int newIndex);
}

// domain/repositories/container_repository.dart
abstract class ContainerRepository {
  Future<Result<Container, DomainError>> create(CreateContainerInput input);
  Future<Result<List<Container>, DomainError>> getAllForPage(String pageId);
  Future<Result<Container, DomainError>> getById(String id);
  Future<Result<Container, DomainError>> update(UpdateContainerInput input);
  Future<Result<void, DomainError>> delete(String id);
  Future<Result<void, DomainError>> reorder(String containerId, int newIndex);
  Future<Result<void, DomainError>> moveTo(String containerId, String newPageId, int index);
}

// domain/repositories/column_repository.dart
abstract class ColumnRepository {
  Future<Result<Column, DomainError>> create(CreateColumnInput input);
  Future<Result<List<Column>, DomainError>> getAllForContainer(String containerId);
  Future<Result<Column, DomainError>> getById(String id);
  Future<Result<Column, DomainError>> update(UpdateColumnInput input);
  Future<Result<void, DomainError>> delete(String id);
  Future<Result<void, DomainError>> reorder(String columnId, int newIndex);
}

// domain/repositories/widget_repository.dart
abstract class WidgetRepository {
  Future<Result<WidgetInstance, DomainError>> create(CreateWidgetInput input);
  Future<Result<List<WidgetInstance>, DomainError>> getAllForColumn(String columnId);
  Future<Result<WidgetInstance, DomainError>> getById(String id);
  Future<Result<WidgetInstance, DomainError>> update(UpdateWidgetInput input);
  Future<Result<void, DomainError>> delete(String id);
  Future<Result<void, DomainError>> reorder(String widgetId, int newIndex);
  Future<Result<void, DomainError>> moveTo(String widgetId, String newColumnId, int index);
}

// domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Result<User, DomainError>> login(String email, String password);
  Future<Result<void, DomainError>> logout();
  Future<Result<User, DomainError>> getCurrentUser();
  Future<Result<void, DomainError>> refreshSession();
}
```

### Use Cases

Use cases encapsulate complex business operations.

```dart
// domain/usecases/fetch_menu_tree_usecase.dart
class FetchMenuTreeUseCase {
  final MenuRepository menuRepository;
  final PageRepository pageRepository;
  final ContainerRepository containerRepository;
  final ColumnRepository columnRepository;
  final WidgetRepository widgetRepository;

  const FetchMenuTreeUseCase({
    required this.menuRepository,
    required this.pageRepository,
    required this.containerRepository,
    required this.columnRepository,
    required this.widgetRepository,
  });

  Future<Result<MenuTree, DomainError>> execute(String menuId) async {
    // 1. Fetch menu
    final menuResult = await menuRepository.getById(menuId);
    if (menuResult.isFailure) {
      return Failure(menuResult.errorOrNull!);
    }
    final menu = menuResult.valueOrNull!;

    // 2. Fetch pages for menu, sorted by index
    final pagesResult = await pageRepository.getAllForMenu(menuId);
    if (pagesResult.isFailure) {
      return Failure(pagesResult.errorOrNull!);
    }
    final pages = pagesResult.valueOrNull!..sort((a, b) => a.index.compareTo(b.index));

    // 3. For each page, fetch containers
    final List<PageWithContainers> pagesWithContainers = [];
    for (final page in pages) {
      final containersResult = await containerRepository.getAllForPage(page.id);
      if (containersResult.isFailure) {
        return Failure(containersResult.errorOrNull!);
      }
      final containers = containersResult.valueOrNull!
        ..sort((a, b) => a.index.compareTo(b.index));

      // 4. For each container, fetch columns
      final List<ContainerWithColumns> containersWithColumns = [];
      for (final container in containers) {
        final columnsResult = await columnRepository.getAllForContainer(container.id);
        if (columnsResult.isFailure) {
          return Failure(columnsResult.errorOrNull!);
        }
        final columns = columnsResult.valueOrNull!
          ..sort((a, b) => a.index.compareTo(b.index));

        // 5. For each column, fetch widgets
        final List<ColumnWithWidgets> columnsWithWidgets = [];
        for (final column in columns) {
          final widgetsResult = await widgetRepository.getAllForColumn(column.id);
          if (widgetsResult.isFailure) {
            return Failure(widgetsResult.errorOrNull!);
          }
          final widgets = widgetsResult.valueOrNull!
            ..sort((a, b) => a.index.compareTo(b.index));

          columnsWithWidgets.add(ColumnWithWidgets(
            column: column,
            widgets: widgets,
          ));
        }

        containersWithColumns.add(ContainerWithColumns(
          container: container,
          columns: columnsWithWidgets,
        ));
      }

      pagesWithContainers.add(PageWithContainers(
        page: page,
        containers: containersWithColumns,
      ));
    }

    return Success(MenuTree(
      menu: menu,
      pages: pagesWithContainers,
    ));
  }
}

// Supporting data structures
@freezed
class MenuTree with _$MenuTree {
  const factory MenuTree({
    required Menu menu,
    required List<PageWithContainers> pages,
  }) = _MenuTree;
}

@freezed
class PageWithContainers with _$PageWithContainers {
  const factory PageWithContainers({
    required Page page,
    required List<ContainerWithColumns> containers,
  }) = _PageWithContainers;
}

@freezed
class ContainerWithColumns with _$ContainerWithColumns {
  const factory ContainerWithColumns({
    required Container container,
    required List<ColumnWithWidgets> columns,
  }) = _ContainerWithColumns;
}

@freezed
class ColumnWithWidgets with _$ColumnWithWidgets {
  const factory ColumnWithWidgets({
    required Column column,
    required List<WidgetInstance> widgets,
  }) = _ColumnWithWidgets;
}
```

---

## Testing Strategy (TDD)

All code must be written using Test-Driven Development:

1. Write a failing test first
2. Write minimal code to pass the test
3. Refactor while keeping tests green

### Testing Pyramid

```
    /\
   /  \    E2E/Integration Tests (Few, critical flows)
  /────\
 /      \   Widget Tests (UI components)
/────────\
Unit Tests  (Most tests - domain logic, repositories, use cases)
```

### Unit Tests (Domain & Data Layers)

**Location**: `test/unit/`

**Coverage**:

- Domain entities (value objects, validation)
- Use cases (business logic)
- Repository implementations
- Mappers (DTO ↔ Entity)
- Result type utilities

**Example: Use Case Test**

```dart
// test/unit/usecases/fetch_menu_tree_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMenuRepository extends Mock implements MenuRepository {}
class MockPageRepository extends Mock implements PageRepository {}
class MockContainerRepository extends Mock implements ContainerRepository {}
class MockColumnRepository extends Mock implements ColumnRepository {}
class MockWidgetRepository extends Mock implements WidgetRepository {}

void main() {
  late FetchMenuTreeUseCase useCase;
  late MockMenuRepository mockMenuRepo;
  late MockPageRepository mockPageRepo;
  late MockContainerRepository mockContainerRepo;
  late MockColumnRepository mockColumnRepo;
  late MockWidgetRepository mockWidgetRepo;

  setUp(() {
    mockMenuRepo = MockMenuRepository();
    mockPageRepo = MockPageRepository();
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    mockWidgetRepo = MockWidgetRepository();

    useCase = FetchMenuTreeUseCase(
      menuRepository: mockMenuRepo,
      pageRepository: mockPageRepo,
      containerRepository: mockContainerRepo,
      columnRepository: mockColumnRepo,
      widgetRepository: mockWidgetRepo,
    );
  });

  group('FetchMenuTreeUseCase', () {
    const menuId = 'menu-1';
    final mockMenu = Menu(
      id: menuId,
      name: 'Test Menu',
      status: MenuStatus.published,
      version: '1.0.0',
    );

    test('should return menu tree when all fetches succeed', () async {
      // Arrange
      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.menu, mockMenu);
      expect(result.valueOrNull?.pages, isEmpty);

      verify(() => mockMenuRepo.getById(menuId)).called(1);
      verify(() => mockPageRepo.getAllForMenu(menuId)).called(1);
    });

    test('should return failure when menu fetch fails', () async {
      // Arrange
      const error = NotFoundError('Menu not found');
      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => Failure(error));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, error);

      verify(() => mockMenuRepo.getById(menuId)).called(1);
      verifyNever(() => mockPageRepo.getAllForMenu(any()));
    });

    test('should sort pages by index', () async {
      // Arrange
      final pages = [
        Page(id: 'p2', menuId: menuId, name: 'Page 2', index: 2),
        Page(id: 'p1', menuId: menuId, name: 'Page 1', index: 1),
        Page(id: 'p3', menuId: menuId, name: 'Page 3', index: 3),
      ];

      when(() => mockMenuRepo.getById(menuId))
          .thenAnswer((_) async => Success(mockMenu));
      when(() => mockPageRepo.getAllForMenu(menuId))
          .thenAnswer((_) async => Success(pages));
      when(() => mockContainerRepo.getAllForPage(any()))
          .thenAnswer((_) async => Success([]));

      // Act
      final result = await useCase.execute(menuId);

      // Assert
      expect(result.isSuccess, true);
      final sortedPages = result.valueOrNull!.pages.map((p) => p.page).toList();
      expect(sortedPages[0].id, 'p1');
      expect(sortedPages[1].id, 'p2');
      expect(sortedPages[2].id, 'p3');
    });
  });
}
```

**Example: Repository Test**

```dart
// test/unit/data/repositories/menu_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late MenuRepositoryImpl repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = MenuRepositoryImpl(dataSource: mockDataSource);
  });

  group('MenuRepositoryImpl.getById', () {
    const menuId = 'menu-1';
    final menuDto = MenuDto(
      id: menuId,
      name: 'Test Menu',
      status: 'published',
      version: '1.0.0',
    );

    test('should return Menu entity when fetch succeeds', () async {
      // Arrange
      when(() => mockDataSource.getItem('menu', menuId))
          .thenAnswer((_) async => menuDto.toJson());

      // Act
      final result = await repository.getById(menuId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.id, menuId);
      expect(result.valueOrNull?.name, 'Test Menu');
      expect(result.valueOrNull?.status, MenuStatus.published);

      verify(() => mockDataSource.getItem('menu', menuId)).called(1);
    });

    test('should return NotFoundError when menu does not exist', () async {
      // Arrange
      when(() => mockDataSource.getItem('menu', menuId))
          .thenThrow(DirectusException(code: 'NOT_FOUND', message: 'Not found'));

      // Act
      final result = await repository.getById(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('should return NetworkError when network fails', () async {
      // Arrange
      when(() => mockDataSource.getItem('menu', menuId))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getById(menuId);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<NetworkError>());
    });
  });
}
```

### Widget Tests (Presentation Layer)

**Location**: `test/widget/`

**Coverage**:

- Individual UI components
- Widget rendering from widget registry
- User interactions (tap, drag, text input)
- Widget state changes

**Example: Widget Test**

```dart
// test/widget/widgets/dish_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DishWidget', () {
    testWidgets('should display dish name and price', (tester) async {
      // Arrange
      const dish = Dish(name: 'Pasta Carbonara', price: 12.50);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DishWidget(
              dish: dish,
              showPrice: true,
              onEdit: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('\$12.50'), findsOneWidget);
    });

    testWidgets('should hide price when showPrice is false', (tester) async {
      // Arrange
      const dish = Dish(name: 'Pasta Carbonara', price: 12.50);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DishWidget(
              dish: dish,
              showPrice: false,
              onEdit: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('\$12.50'), findsNothing);
    });

    testWidgets('should call onEdit when tapped', (tester) async {
      // Arrange
      const dish = Dish(name: 'Pasta Carbonara', price: 12.50);
      bool editCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DishWidget(
              dish: dish,
              showPrice: true,
              onEdit: () => editCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DishWidget));
      await tester.pump();

      // Assert
      expect(editCalled, true);
    });
  });
}
```

### Integration Tests

**Location**: `integration_test/`

**Coverage**:

- Complete user flows
- Navigation between screens
- API integration with real/mock backend
- State persistence

**Example: Integration Test**

```dart
// integration_test/admin_template_creation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Template Creation Flow', () {
    testWidgets('admin can create and publish a template', (tester) async {
      // Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Login as admin
      await tester.enterText(find.byKey(Key('email_field')), 'admin@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Navigate to template editor
      await tester.tap(find.text('Create Template'));
      await tester.pumpAndSettle();

      // Enter template name
      await tester.enterText(find.byKey(Key('template_name')), 'Lunch Menu');

      // Add a page
      await tester.tap(find.byKey(Key('add_page_button')));
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);

      // Add a container to page
      await tester.tap(find.byKey(Key('add_container_button')));
      await tester.pumpAndSettle();

      // Add a column to container
      await tester.tap(find.byKey(Key('add_column_button')));
      await tester.pumpAndSettle();

      // Save as draft
      await tester.tap(find.byKey(Key('save_draft_button')));
      await tester.pumpAndSettle();
      expect(find.text('Template saved'), findsOneWidget);

      // Publish template
      await tester.tap(find.byKey(Key('publish_button')));
      await tester.pumpAndSettle();
      expect(find.text('Template published'), findsOneWidget);
    });
  });
}
```

### Test Coverage Goals

- **Domain layer**: 100%
- **Data layer**: >90%
- **Presentation layer**: >70%
- **Overall**: >85%

### Running Tests

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run widget tests only
flutter test test/widget

# Run integration tests
flutter test integration_test

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Directus Integration

### Using directus_api_manager Package

The application uses the [`directus_api_manager`](./directus-api-manager.md) package (https://github.com/maxbritto/directus_api_manager) for all Directus backend communication.

**Key Features**:

- Authentication with built-in persistence
- Type-safe CRUD operations
- File upload/download
- Error handling
- Token refresh

### Setup

```dart
// data/datasources/directus_data_source.dart
import 'package:directus_api_manager/directus_api_manager.dart';

class DirectusDataSource {
  final DirectusAPI api;

  DirectusDataSource({required String baseUrl})
      : api = DirectusAPI(baseUrl: baseUrl);

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await api.login(email: email, password: password);
  }

  Future<void> logout() async {
    await api.logout();
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await api.getCurrentUser();
  }

  // CRUD operations
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

  Future<List<Map<String, dynamic>>> getItems(
    String collection, {
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    return await api.getItems(
      collection: collection,
      filter: filter,
      fields: fields,
      sort: sort,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>> createItem(
    String collection,
    Map<String, dynamic> data,
  ) async {
    return await api.createItem(
      collection: collection,
      data: data,
    );
  }

  Future<Map<String, dynamic>> updateItem(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    return await api.updateItem(
      collection: collection,
      id: id,
      data: data,
    );
  }

  Future<void> deleteItem(String collection, String id) async {
    await api.deleteItem(collection: collection, id: id);
  }
}
```

### Directus Collections Schema

The existing Directus backend has these collections:

#### `menu` Collection

```json
{
  "id": "uuid",
  "status": "string (draft|published|archived)",
  "date_created": "timestamp",
  "date_updated": "timestamp",
  "user_created": "uuid (relation to directus_users)",
  "user_updated": "uuid (relation to directus_users)",
  "name": "string",
  "version": "string",
  "style_json": "json",
  "area": "string (optional)",
  "size": "json (optional, page size config)",
  "pages": "o2m relation to page collection",
  "versions": "o2m relation to version collection (optional)"
}
```

#### `page` Collection

```json
{
  "id": "uuid",
  "date_created": "timestamp",
  "date_updated": "timestamp",
  "menu_id": "uuid (m2o relation to menu)",
  "name": "string",
  "index": "integer (sort order)"
}
```

#### `container` Collection

```json
{
  "id": "uuid",
  "date_created": "timestamp",
  "date_updated": "timestamp",
  "page_id": "uuid (m2o relation to page)",
  "index": "integer (sort order)",
  "name": "string (optional)",
  "layout_json": "json (optional, layout config)"
}
```

#### `column` Collection

```json
{
  "id": "uuid",
  "date_created": "timestamp",
  "date_updated": "timestamp",
  "container_id": "uuid (m2o relation to container)",
  "index": "integer (sort order)",
  "flex": "integer (optional, flex factor)",
  "width": "decimal (optional, fixed width)"
}
```

#### `widget` Collection

```json
{
  "id": "uuid",
  "date_created": "timestamp",
  "date_updated": "timestamp",
  "column_id": "uuid (m2o relation to column)",
  "type": "string (widget type identifier)",
  "version": "string (semver)",
  "index": "integer (sort order)",
  "props": "json (widget-specific data)",
  "style_json": "json (optional, widget styling)"
}
```

### Error Mapping

Map Directus exceptions to domain errors:

```dart
// data/mappers/error_mapper.dart
DomainError mapDirectusError(dynamic error) {
  if (error is DirectusException) {
    switch (error.code) {
      case 'INVALID_CREDENTIALS':
      case 'INVALID_PAYLOAD':
        return InvalidCredentialsError(error.message);

      case 'TOKEN_EXPIRED':
        return TokenExpiredError(error.message);

      case 'FORBIDDEN':
        return UnauthorizedError(error.message);

      case 'NOT_FOUND':
        return NotFoundError(error.message);

      case 'INVALID_QUERY':
      case 'RECORD_NOT_UNIQUE':
      case 'INVALID_FOREIGN_KEY':
        return ValidationError(error.message, details: error.extensions);

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

### Repository Implementation Example

```dart
// data/repositories/menu_repository_impl.dart
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/data/mappers/menu_mapper.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';

class MenuRepositoryImpl implements MenuRepository {
  final DirectusDataSource dataSource;
  static const String collection = 'menu';

  const MenuRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Menu, DomainError>> getById(String id) async {
    try {
      final data = await dataSource.getItem(
        collection,
        id,
        fields: [
          'id',
          'name',
          'status',
          'version',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'style_json',
          'area',
          'size',
        ],
      );

      final dto = MenuDto.fromJson(data);
      final menu = MenuMapper.toEntity(dto);

      return Success(menu);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
  }) async {
    try {
      final filter = onlyPublished
          ? {'status': {'_eq': 'published'}}
          : null;

      final data = await dataSource.getItems(
        collection,
        filter: filter,
        fields: [
          'id',
          'name',
          'status',
          'version',
          'date_created',
          'date_updated',
          'style_json',
        ],
        sort: ['-date_updated'],
      );

      final menus = data
          .map((json) => MenuDto.fromJson(json))
          .map((dto) => MenuMapper.toEntity(dto))
          .toList();

      return Success(menus);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Menu, DomainError>> create(CreateMenuInput input) async {
    try {
      final data = await dataSource.createItem(
        collection,
        MenuMapper.toCreateDto(input),
      );

      final dto = MenuDto.fromJson(data);
      final menu = MenuMapper.toEntity(dto);

      return Success(menu);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input) async {
    try {
      final data = await dataSource.updateItem(
        collection,
        input.id,
        MenuMapper.toUpdateDto(input),
      );

      final dto = MenuDto.fromJson(data);
      final menu = MenuMapper.toEntity(dto);

      return Success(menu);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(String id) async {
    try {
      await dataSource.deleteItem(collection, id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
```

---

## State Management with Riverpod

The application uses `flutter_riverpod` for state management.

### Provider Structure

```dart
// presentation/providers/repositories_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data source provider
final directusDataSourceProvider = Provider<DirectusDataSource>((ref) {
  return DirectusDataSource(
    baseUrl: const String.fromEnvironment('DIRECTUS_URL'),
  );
});

// Repository providers
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl(
    dataSource: ref.watch(directusDataSourceProvider),
  );
});

final pageRepositoryProvider = Provider<PageRepository>((ref) {
  return PageRepositoryImpl(
    dataSource: ref.watch(directusDataSourceProvider),
  );
});

final containerRepositoryProvider = Provider<ContainerRepository>((ref) {
  return ContainerRepositoryImpl(
    dataSource: ref.watch(directusDataSourceProvider),
  );
});

final columnRepositoryProvider = Provider<ColumnRepository>((ref) {
  return ColumnRepositoryImpl(
    dataSource: ref.watch(directusDataSourceProvider),
  );
});

final widgetRepositoryProvider = Provider<WidgetRepository>((ref) {
  return WidgetRepositoryImpl(
    dataSource: ref.watch(directusDataSourceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dataSource: ref.watch(directusDataSourceProvider),
  );
});
```

```dart
// presentation/providers/usecases_provider.dart
final fetchMenuTreeUseCaseProvider = Provider<FetchMenuTreeUseCase>((ref) {
  return FetchMenuTreeUseCase(
    menuRepository: ref.watch(menuRepositoryProvider),
    pageRepository: ref.watch(pageRepositoryProvider),
    containerRepository: ref.watch(containerRepositoryProvider),
    columnRepository: ref.watch(columnRepositoryProvider),
    widgetRepository: ref.watch(widgetRepositoryProvider),
  );
});
```

### Authentication State

```dart
// presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    final result = await _authRepository.getCurrentUser();

    result.fold(
      onSuccess: (user) => state = AuthState.authenticated(user),
      onFailure: (_) => state = const AuthState.unauthenticated(),
    );
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    final result = await _authRepository.login(email, password);

    result.fold(
      onSuccess: (user) => state = AuthState.authenticated(user),
      onFailure: (error) => state = AuthState.error(error.message),
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// Convenience provider for current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});

// Check if user is admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == UserRole.admin;
});
```

### Screen State Example

```dart
// presentation/pages/menu_list/menu_list_state.dart
@freezed
class MenuListState with _$MenuListState {
  const factory MenuListState({
    @Default([]) List<Menu> menus,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _MenuListState;
}

// presentation/pages/menu_list/menu_list_notifier.dart
class MenuListNotifier extends StateNotifier<MenuListState> {
  final MenuRepository _menuRepository;

  MenuListNotifier(this._menuRepository) : super(const MenuListState());

  Future<void> loadMenus({bool onlyPublished = true}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _menuRepository.listAll(onlyPublished: onlyPublished);

    result.fold(
      onSuccess: (menus) {
        state = state.copyWith(
          menus: menus,
          isLoading: false,
        );
      },
      onFailure: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> deleteMenu(String menuId) async {
    final result = await _menuRepository.delete(menuId);

    result.fold(
      onSuccess: (_) {
        // Remove from local state
        state = state.copyWith(
          menus: state.menus.where((m) => m.id != menuId).toList(),
        );
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }
}

final menuListProvider =
    StateNotifierProvider<MenuListNotifier, MenuListState>((ref) {
  return MenuListNotifier(ref.watch(menuRepositoryProvider));
});
```

---

## UI/UX Implementation

### Pages/Screens

#### 1. Login Page

**Route**: `/login`
**Access**: Public

**Features**:

- Email/password input fields
- Login button
- Error message display
- Loading indicator
- Auto-redirect if already authenticated

```dart
// presentation/pages/login/login_page.dart
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Auto-redirect on successful auth
    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (_) => context.go('/home'),
      );
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                Text(
                  'OXO Menus',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  key: const Key('email_field'),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  key: const Key('password_field'),
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('login_button'),
                    onPressed: authState.maybeWhen(
                      loading: () => null,
                      orElse: () => _handleLogin,
                    ),
                    child: authState.maybeWhen(
                      loading: () => const CircularProgressIndicator(),
                      orElse: () => const Text('Login'),
                    ),
                  ),
                ),

                // Error message
                if (authState is _Error)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      (authState as _Error).message,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 2. Home/Dashboard Page

**Route**: `/home`
**Access**: Authenticated users

**Features**:

- Welcome message
- Quick actions based on user role:
  - Admin: Create Template, View All Templates
  - User: Browse Templates, View My Menus

#### 3. Menu List Page

**Route**: `/menus`
**Access**: Authenticated users

**Features**:

- Display list of menus (published for users, all for admins)
- Filter by status (admin only)
- Search by name
- Create new menu button (admin only)
- Delete menu (admin only)
- Navigate to menu editor/viewer

```dart
// presentation/pages/menu_list/menu_list_page.dart
class MenuListPage extends ConsumerWidget {
  const MenuListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menuListProvider);
    final isAdmin = ref.watch(isAdminProvider);

    useEffect(() {
      // Load menus on mount
      Future.microtask(() {
        ref.read(menuListProvider.notifier).loadMenus(
              onlyPublished: !isAdmin,
            );
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menus'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/menus/create'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text('Error: ${state.errorMessage}'))
              : state.menus.isEmpty
                  ? const Center(child: Text('No menus found'))
                  : ListView.builder(
                      itemCount: state.menus.length,
                      itemBuilder: (context, index) {
                        final menu = state.menus[index];
                        return MenuListItem(
                          menu: menu,
                          isAdmin: isAdmin,
                          onTap: () => context.push('/menus/${menu.id}'),
                          onDelete: isAdmin
                              ? () => _confirmDelete(context, ref, menu)
                              : null,
                        );
                      },
                    ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Menu menu,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu'),
        content: Text('Are you sure you want to delete "${menu.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(menuListProvider.notifier).deleteMenu(menu.id);
    }
  }
}
```

#### 4. Admin Template Editor Page

**Route**: `/admin/templates/:id`
**Access**: Admin only

**Features**:

- Visual template builder
- Drag-and-drop interface for:
  - Adding/removing/reordering pages
  - Adding/removing/reordering containers
  - Adding/removing/reordering columns
  - Setting column widths
- Widget type selector (which widgets are available in this template)
- Style editor (colors, fonts, spacing, page size)
- Save as draft
- Publish template
- Version management

**Layout**:

```
┌─────────────────────────────────────────────────────┐
│ AppBar: Template Name | Save | Publish             │
├──────────────┬──────────────────────────────────────┤
│              │                                      │
│  Left Panel  │         Canvas Preview               │
│              │                                      │
│  - Pages     │    ┌──────────────────────┐          │
│  - Widgets   │    │ Page 1               │          │
│  - Styles    │    │ ┌────────┬─────────┐ │          │
│              │    │ │Col 1   │ Col 2   │ │          │
│              │    │ └────────┴─────────┘ │          │
│              │    └──────────────────────┘          │
│              │                                      │
└──────────────┴──────────────────────────────────────┘
```

#### 5. User Menu Editor Page

**Route**: `/menus/:id/edit`
**Access**: All authenticated users

**Features**:

- Select template (if creating new menu)
- View template structure (pages, containers, columns)
- Drag widgets from palette into columns
- Edit widget data (inline or dialog)
- Reorder widgets
- Move widgets between columns/containers
- Style customization (colors, fonts)
- Save menu
- Generate PDF

**Layout**:

```
┌─────────────────────────────────────────────────────┐
│ AppBar: Menu Name | Save | Generate PDF            │
├──────────────┬──────────────────────────────────────┤
│              │                                      │
│ Widget       │         Canvas Preview               │
│ Palette      │                                      │
│              │    ┌──────────────────────┐          │
│ [Dish]       │    │ Page 1               │          │
│ [Section]    │    │ ┌────────┬─────────┐ │          │
│ [Image]      │    │ │[Dish 1]│         │ │          │
│ [Text]       │    │ │[Dish 2]│ [Text]  │ │          │
│              │    │ └────────┴─────────┘ │          │
│              │    └──────────────────────┘          │
│              │                                      │
└──────────────┴──────────────────────────────────────┘
```

### Key Components

#### Template Canvas

Renders the full menu template with all pages, containers, columns, and widgets.

```dart
// presentation/widgets/template_canvas.dart
class TemplateCanvas extends ConsumerWidget {
  final MenuTree menuTree;
  final bool isEditable;
  final VoidCallback? onWidgetTap;

  const TemplateCanvas({
    super.key,
    required this.menuTree,
    this.isEditable = false,
    this.onWidgetTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageView.builder(
      itemCount: menuTree.pages.length,
      itemBuilder: (context, pageIndex) {
        final pageData = menuTree.pages[pageIndex];
        return PageCanvas(
          page: pageData,
          isEditable: isEditable,
        );
      },
    );
  }
}

class PageCanvas extends StatelessWidget {
  final PageWithContainers page;
  final bool isEditable;

  const PageCanvas({
    super.key,
    required this.page,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: page.containers.map((containerData) {
          return ContainerCanvas(
            container: containerData,
            isEditable: isEditable,
          );
        }).toList(),
      ),
    );
  }
}

class ContainerCanvas extends StatelessWidget {
  final ContainerWithColumns container;
  final bool isEditable;

  const ContainerCanvas({
    super.key,
    required this.container,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: container.columns.map((columnData) {
          final column = columnData.column;
          return Expanded(
            flex: column.flex ?? 1,
            child: ColumnCanvas(
              column: columnData,
              isEditable: isEditable,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ColumnCanvas extends StatelessWidget {
  final ColumnWithWidgets column;
  final bool isEditable;

  const ColumnCanvas({
    super.key,
    required this.column,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: column.widgets.map((widget) {
          return WidgetRenderer(
            widgetInstance: widget,
            isEditable: isEditable,
          );
        }).toList(),
      ),
    );
  }
}
```

#### Widget Renderer

Renders a widget instance using the widget registry.

```dart
// presentation/widgets/widget_renderer.dart
class WidgetRenderer extends ConsumerWidget {
  final WidgetInstance widgetInstance;
  final bool isEditable;

  const WidgetRenderer({
    super.key,
    required this.widgetInstance,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgetDef = ref.watch(
      widgetRegistryProvider.select(
        (registry) => registry.getDefinition(widgetInstance.type),
      ),
    );

    if (widgetDef == null) {
      return Text('Unknown widget: ${widgetInstance.type}');
    }

    // Parse and migrate props
    final props = widgetDef.parseProps(widgetInstance.props);

    return widgetDef.render(
      props,
      WidgetContext(
        isEditable: isEditable,
        onUpdate: isEditable
            ? (updatedProps) => _handleUpdate(ref, updatedProps)
            : null,
        onDelete: isEditable ? () => _handleDelete(ref) : null,
      ),
    );
  }

  void _handleUpdate(WidgetRef ref, Map<String, dynamic> updatedProps) {
    ref.read(widgetRepositoryProvider).update(
          UpdateWidgetInput(
            id: widgetInstance.id,
            props: {...widgetInstance.props, ...updatedProps},
          ),
        );
  }

  void _handleDelete(WidgetRef ref) {
    ref.read(widgetRepositoryProvider).delete(widgetInstance.id);
  }
}
```

#### Drag and Drop System

For admin template editing and user widget placement.

```dart
// presentation/widgets/draggable_widget.dart
class DraggableWidget extends StatelessWidget {
  final Widget child;
  final String widgetId;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const DraggableWidget({
    super.key,
    required this.child,
    required this.widgetId,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<String>(
      data: widgetId,
      feedback: Material(
        elevation: 4.0,
        child: Opacity(
          opacity: 0.7,
          child: child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      onDragStarted: onDragStart,
      onDragEnd: (_) => onDragEnd?.call(),
      child: child,
    );
  }
}

// presentation/widgets/drop_zone.dart
class DropZone extends StatefulWidget {
  final Widget child;
  final String columnId;
  final int targetIndex;
  final void Function(String widgetId, String columnId, int index)? onAccept;

  const DropZone({
    super.key,
    required this.child,
    required this.columnId,
    required this.targetIndex,
    this.onAccept,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        widget.onAccept?.call(
          details.data,
          widget.columnId,
          widget.targetIndex,
        );
        setState(() => _isHovering = false);
      },
      onMove: (_) => setState(() => _isHovering = true),
      onLeave: (_) => setState(() => _isHovering = false),
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: _isHovering
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                )
              : null,
          child: widget.child,
        );
      },
    );
  }
}
```

---

## Widget System

The widget system allows for extensible, pluggable UI components with versioning and migration support.

### Widget Registry

```dart
// domain/widget_system/widget_definition.dart
class WidgetDefinition<P> {
  final String type;
  final String version;
  final P Function(Map<String, dynamic>) parseProps;
  final Widget Function(P props, WidgetContext context) render;
  final P defaultProps;
  final P Function(Map<String, dynamic>)? migrate;

  const WidgetDefinition({
    required this.type,
    required this.version,
    required this.parseProps,
    required this.render,
    required this.defaultProps,
    this.migrate,
  });
}

class WidgetContext {
  final bool isEditable;
  final void Function(Map<String, dynamic>)? onUpdate;
  final VoidCallback? onDelete;

  const WidgetContext({
    required this.isEditable,
    this.onUpdate,
    this.onDelete,
  });
}

// domain/widget_system/widget_registry.dart
class WidgetRegistry {
  final Map<String, WidgetDefinition> _registry = {};

  void register<P>(WidgetDefinition<P> definition) {
    _registry[definition.type] = definition as WidgetDefinition<dynamic>;
  }

  WidgetDefinition? getDefinition(String type) {
    return _registry[type];
  }

  List<String> get registeredTypes => _registry.keys.toList();
}

// Riverpod provider
final widgetRegistryProvider = Provider<WidgetRegistry>((ref) {
  final registry = WidgetRegistry();

  // Register built-in widgets
  registry.register(dishWidgetDefinition);
  registry.register(sectionWidgetDefinition);
  registry.register(imageWidgetDefinition);
  registry.register(textWidgetDefinition);

  return registry;
});
```

### Example Widget: DishWidget

```dart
// domain/widgets/dish/dish_props.dart
@freezed
class DishProps with _$DishProps {
  const factory DishProps({
    required String name,
    required double price,
    String? description,
    List<String>? allergens,
    List<String>? dietary,
    bool? showPrice,
    bool? showAllergens,
  }) = _DishProps;

  factory DishProps.fromJson(Map<String, dynamic> json) =>
      _$DishPropsFromJson(json);
}

// presentation/widgets/dish_widget/dish_widget.dart
class DishWidget extends StatelessWidget {
  final DishProps props;
  final WidgetContext context;

  const DishWidget({
    super.key,
    required this.props,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.isEditable ? _handleEdit : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      props.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (props.showPrice ?? true)
                    Text(
                      '\$${props.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              if (props.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  props.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if ((props.showAllergens ?? true) &&
                  (props.allergens?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: props.allergens!
                      .map((allergen) => Chip(
                            label: Text(allergen),
                            backgroundColor: Colors.orange[100],
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleEdit() {
    // Show edit dialog
    showDialog(
      context: context as BuildContext,
      builder: (dialogContext) => DishEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
  }
}

// Widget definition registration
final dishWidgetDefinition = WidgetDefinition<DishProps>(
  type: 'dish',
  version: '1.0.0',
  parseProps: (json) => DishProps.fromJson(json),
  render: (props, context) => DishWidget(
    props: props,
    context: context,
  ),
  defaultProps: const DishProps(
    name: 'New Dish',
    price: 0.0,
    showPrice: true,
    showAllergens: true,
  ),
);
```

### Widget Migration System

For handling schema changes across widget versions:

```dart
// domain/widget_system/widget_migrator.dart
class WidgetMigrator {
  static Map<String, dynamic> migrate(
    WidgetInstance instance,
    WidgetDefinition definition,
  ) {
    var props = instance.props;

    // If there's a migrate function, apply it
    if (definition.migrate != null) {
      final migratedProps = definition.migrate!(props);
      props = (migratedProps as dynamic).toJson();
    }

    return props;
  }
}
```

---

## PDF Generation

Generate PDF menus matching the exact visual layout.

### Approach

Use the `pdf` package for Flutter to generate PDFs client-side. This provides maximum control over layout and styling.

### Implementation

```dart
// domain/usecases/generate_pdf_usecase.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GeneratePdfUseCase {
  Future<Result<Uint8List, DomainError>> execute(MenuTree menuTree) async {
    try {
      final pdf = pw.Document();

      // Apply page size from menu config
      final pageFormat = _getPageFormat(menuTree.menu.pageSize);

      // Generate pages
      for (final pageData in menuTree.pages) {
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
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

  PdfPageFormat _getPageFormat(PageSize? pageSize) {
    if (pageSize == null) return PdfPageFormat.a4;

    return PdfPageFormat(
      pageSize.width * PdfPageFormat.mm,
      pageSize.height * PdfPageFormat.mm,
    );
  }

  pw.Widget _buildPage(
    PageWithContainers pageData,
    StyleConfig? styleConfig,
  ) {
    return pw.Container(
      padding: pw.EdgeInsets.all(
        styleConfig?.padding ?? 16,
      ),
      child: pw.Column(
        children: pageData.containers.map((containerData) {
          return _buildContainer(containerData, styleConfig);
        }).toList(),
      ),
    );
  }

  pw.Widget _buildContainer(
    ContainerWithColumns containerData,
    StyleConfig? styleConfig,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: containerData.columns.map((columnData) {
          return pw.Expanded(
            flex: columnData.column.flex ?? 1,
            child: _buildColumn(columnData, styleConfig),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildColumn(
    ColumnWithWidgets columnData,
    StyleConfig? styleConfig,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: columnData.widgets.map((widget) {
        return _buildWidget(widget, styleConfig);
      }).toList(),
    );
  }

  pw.Widget _buildWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
  ) {
    // Render widget based on type
    switch (widget.type) {
      case 'dish':
        return _buildDishWidget(widget, styleConfig);
      case 'text':
        return _buildTextWidget(widget, styleConfig);
      case 'section':
        return _buildSectionWidget(widget, styleConfig);
      default:
        return pw.SizedBox();
    }
  }

  pw.Widget _buildDishWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
  ) {
    final props = DishProps.fromJson(widget.props);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  props.name,
                  style: pw.TextStyle(
                    fontSize: styleConfig?.fontSize ?? 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (props.showPrice ?? true)
                pw.Text(
                  '\$${props.price.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: styleConfig?.fontSize ?? 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (props.description != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              props.description!,
              style: pw.TextStyle(
                fontSize: (styleConfig?.fontSize ?? 14) - 2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildTextWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
  ) {
    final text = widget.props['text'] as String? ?? '';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: styleConfig?.fontSize ?? 14,
        ),
      ),
    );
  }

  pw.Widget _buildSectionWidget(
    WidgetInstance widget,
    StyleConfig? styleConfig,
  ) {
    final title = widget.props['title'] as String? ?? '';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12, top: 8),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: (styleConfig?.fontSize ?? 14) + 2,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
```

### PDF Preview and Download

```dart
// presentation/pages/menu_editor/pdf_preview_dialog.dart
class PdfPreviewDialog extends ConsumerWidget {
  final String menuId;

  const PdfPreviewDialog({super.key, required this.menuId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 800,
        child: Column(
          children: [
            AppBar(
              title: const Text('PDF Preview'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadPdf(ref),
                ),
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () => _printPdf(ref),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<Uint8List>(
                future: _generatePdf(ref),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  return PdfPreview(
                    build: (format) => snapshot.data!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(WidgetRef ref) async {
    final menuTree = await ref.read(
      fetchMenuTreeUseCaseProvider,
    ).execute(menuId);

    if (menuTree.isFailure) {
      throw Exception(menuTree.errorOrNull?.message);
    }

    final result = await ref.read(generatePdfUseCaseProvider).execute(
          menuTree.valueOrNull!,
        );

    if (result.isFailure) {
      throw Exception(result.errorOrNull?.message);
    }

    return result.valueOrNull!;
  }

  Future<void> _downloadPdf(WidgetRef ref) async {
    final bytes = await _generatePdf(ref);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'menu_${DateTime.now().toIso8601String()}.pdf',
    );
  }

  Future<void> _printPdf(WidgetRef ref) async {
    final bytes = await _generatePdf(ref);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
    );
  }
}
```

---

## Implementation Roadmap

### Phase 1: Foundation & Setup (Week 1-2)

**Goal**: Set up project structure, dependencies, and core architecture

**Tasks**:

- [ ] Create Flutter project with proper folder structure
- [ ] Add dependencies (riverpod, freezed, directus_api_manager, pdf, etc.)
- [ ] Set up code generation (build_runner)
- [ ] Configure environment variables
- [ ] Implement Result type
- [ ] Define DomainError hierarchy
- [ ] Write tests for Result type and errors

**Test Coverage**: 100% for core utilities

### Phase 2: Domain Layer (Week 2-3)

**Goal**: Define all business entities, repository interfaces, and use cases

**Tasks**:

- [ ] Define all entity models with Freezed (Menu, Page, Container, Column, Widget, User)
- [ ] Write tests for entity validation
- [ ] Define all repository interfaces
- [ ] Implement core use cases:
  - [ ] FetchMenuTreeUseCase
  - [ ] CreateMenuUseCase
  - [ ] UpdateMenuUseCase
  - [ ] DeleteMenuUseCase
  - [ ] Reorder/Move use cases
- [ ] Write unit tests for all use cases (100% coverage)

**Test Coverage**: 100% for domain layer

### Phase 3: Data Layer (Week 3-5)

**Goal**: Implement repository contracts and Directus integration

**Tasks**:

- [ ] Set up DirectusDataSource with directus_api_manager
- [ ] Create DTOs for all entities
- [ ] Implement mappers (DTO ↔ Entity)
- [ ] Write tests for mappers
- [ ] Implement error mapping
- [ ] Implement all repository classes:
  - [ ] MenuRepositoryImpl
  - [ ] PageRepositoryImpl
  - [ ] ContainerRepositoryImpl
  - [ ] ColumnRepositoryImpl
  - [ ] WidgetRepositoryImpl
  - [ ] AuthRepositoryImpl
- [ ] Write unit tests for all repositories (>90% coverage)
- [ ] Integration tests with mock Directus API

**Test Coverage**: >90% for data layer

### Phase 4: Widget System (Week 5-6)

**Goal**: Build extensible widget registry and implement core widgets

**Tasks**:

- [ ] Implement WidgetRegistry
- [ ] Implement WidgetDefinition structure
- [ ] Write tests for widget system
- [ ] Create core widgets:
  - [ ] DishWidget
  - [ ] SectionWidget
  - [ ] TextWidget
  - [ ] ImageWidget (if needed)
- [ ] Implement widget migration system
- [ ] Write widget tests for each widget type
- [ ] Test widget rendering in isolation

**Test Coverage**: >80% for widget system

### Phase 5: State Management (Week 6-7)

**Goal**: Set up Riverpod providers and state management

**Tasks**:

- [ ] Create repository providers
- [ ] Create use case providers
- [ ] Implement AuthNotifier and authProvider
- [ ] Implement screen-specific notifiers:
  - [ ] MenuListNotifier
  - [ ] TemplateEditorNotifier
  - [ ] MenuEditorNotifier
- [ ] Write tests for all notifiers
- [ ] Test provider dependencies

**Test Coverage**: >85% for state management

### Phase 6: Authentication UI (Week 7-8)

**Goal**: Build login and authentication flow

**Tasks**:

- [ ] Create LoginPage
- [ ] Implement form validation
- [ ] Handle auth state transitions
- [ ] Add loading states
- [ ] Add error handling
- [ ] Widget tests for LoginPage
- [ ] Integration test for login flow

**Test Coverage**: >70% for auth UI

### Phase 7: Navigation & Routing (Week 8)

**Goal**: Set up app-wide navigation

**Tasks**:

- [ ] Configure go_router
- [ ] Define all routes
- [ ] Implement route guards (auth, admin-only)
- [ ] Add deep linking support (web)
- [ ] Test navigation flows

### Phase 8: Menu List UI (Week 8-9)

**Goal**: Build menu browsing and management

**Tasks**:

- [ ] Create MenuListPage
- [ ] Implement menu cards/list items
- [ ] Add filtering (admin/user views)
- [ ] Add search functionality
- [ ] Implement delete confirmation
- [ ] Widget tests for MenuListPage
- [ ] Integration test for menu list flow

**Test Coverage**: >70% for menu list UI

### Phase 9: Admin Template Editor (Week 9-12)

**Goal**: Build visual template editor for admins

**Tasks**:

- [ ] Create AdminTemplateEditorPage layout
- [ ] Implement page management (add/remove/reorder)
- [ ] Implement container management
- [ ] Implement column management
- [ ] Add column width controls
- [ ] Implement drag-and-drop for structural elements
- [ ] Create style editor panel
- [ ] Add widget type selector
- [ ] Implement save/publish functionality
- [ ] Widget tests for editor components
- [ ] Integration test for template creation

**Test Coverage**: >70% for admin editor

### Phase 10: User Menu Editor (Week 12-14)

**Goal**: Build menu editor for regular users

**Tasks**:

- [ ] Create MenuEditorPage layout
- [ ] Implement widget palette
- [ ] Implement drag-and-drop for widgets
- [ ] Add widget editing dialogs
- [ ] Implement widget reordering
- [ ] Implement cross-column/container widget movement
- [ ] Add style customization panel
- [ ] Widget tests for editor components
- [ ] Integration test for menu editing

**Test Coverage**: >70% for menu editor

### Phase 11: Template Canvas Renderer (Week 14-15)

**Goal**: Build the visual canvas that renders menus

**Tasks**:

- [ ] Create TemplateCanvas component
- [ ] Implement PageCanvas
- [ ] Implement ContainerCanvas
- [ ] Implement ColumnCanvas
- [ ] Implement WidgetRenderer
- [ ] Add responsive layout handling
- [ ] Widget tests for canvas components
- [ ] Snapshot tests for rendering

**Test Coverage**: >75% for canvas

### Phase 12: PDF Generation (Week 15-16)

**Goal**: Implement PDF export functionality

**Tasks**:

- [ ] Implement GeneratePdfUseCase
- [ ] Build PDF layout matching canvas
- [ ] Add support for all widget types in PDF
- [ ] Apply styling from menu config
- [ ] Create PDF preview dialog
- [ ] Add download functionality
- [ ] Add print functionality
- [ ] Test PDF generation with various layouts
- [ ] Test PDF on different platforms (iOS, Android, Web)

**Test Coverage**: >80% for PDF generation

### Phase 13: Polish & Optimization (Week 16-17)

**Goal**: Refine UX and optimize performance

**Tasks**:

- [ ] Add loading skeletons
- [ ] Improve error messages
- [ ] Add success notifications
- [ ] Optimize list rendering (ListView.builder)
- [ ] Add image caching
- [ ] Implement pagination for large menu lists
- [ ] Add pull-to-refresh
- [ ] Accessibility improvements
- [ ] Responsive design for web/tablet

### Phase 14: Testing & QA (Week 17-18)

**Goal**: Comprehensive testing and bug fixes

**Tasks**:

- [ ] Achieve overall >85% code coverage
- [ ] End-to-end testing on all platforms
- [ ] Performance testing
- [ ] User acceptance testing
- [ ] Fix identified bugs
- [ ] Security audit (auth, data validation)

### Phase 15: Deployment (Week 18-19)

**Goal**: Deploy to production

**Tasks**:

- [ ] Set up CI/CD pipelines
- [ ] Configure production environment variables
- [ ] Build and test iOS app
- [ ] Build and test Android app
- [ ] Deploy web app
- [ ] App store submissions (if needed)
- [ ] Documentation
- [ ] User training materials

---

## Package Dependencies

```yaml
# pubspec.yaml
name: oxo_menus
description: OXO Menus application
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Functional Programming
  fpdart: ^1.1.0 # For Result type and functional utilities

  # Data Models
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0

  # Directus Integration
  directus_api_manager:
    git:
      url: https://github.com/maxbritto/directus_api_manager.git
      ref: main

  # Routing
  go_router: ^13.0.0

  # HTTP & Networking
  http: ^1.2.0

  # PDF Generation
  pdf: ^3.10.0
  printing: ^5.12.0

  # UI Components
  flutter_form_builder: ^9.1.0

  # Image Handling
  cached_network_image: ^3.3.0

  # Utilities
  equatable: ^2.0.5
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Testing
  mocktail: ^1.0.0
  integration_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0

  # Linting
  flutter_lints: ^3.0.0

  # Dev Tools
  flutter_launcher_icons: ^0.13.0
```

### Installation & Setup

```bash
# Get dependencies
flutter pub get

# Generate code (entities, providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Run code generation in watch mode during development
flutter pub run build_runner watch --delete-conflicting-outputs

# Run tests
flutter test

# Run with environment variables
flutter run --dart-define=DIRECTUS_URL=https://your-directus-instance.com
```

---

## Additional Notes

### Code Organization Best Practices

1. **One entity per file**: Each entity should be in its own file
2. **Repository interface and implementation separation**: Keep interfaces in domain, implementations in data
3. **Use barrel files**: Export public APIs from `index.dart` files
4. **Naming conventions**:
   - Entities: `Menu`, `Page`, etc.
   - DTOs: `MenuDto`, `PageDto`, etc.
   - Repositories: `MenuRepository` (interface), `MenuRepositoryImpl` (implementation)
   - Use cases: `FetchMenuTreeUseCase`, `CreateMenuUseCase`, etc.
   - Notifiers: `MenuListNotifier`, `AuthNotifier`, etc.

### Performance Considerations

1. **Lazy loading**: Only fetch data when needed
2. **Pagination**: For large lists of menus/widgets
3. **Caching**: Cache menu trees in memory with Riverpod
4. **Debouncing**: For search/filter inputs
5. **Image optimization**: Use cached_network_image with proper sizing

### Security Considerations

1. **Input validation**: Validate all user inputs on client and server
2. **Authentication**: Use Directus built-in auth with secure token storage
3. **Authorization**: Check user roles before sensitive operations
4. **HTTPS**: Always use HTTPS for API communication
5. **XSS Prevention**: Sanitize user-generated content in widgets

### Accessibility

1. **Semantic widgets**: Use proper Flutter widgets (Semantics)
2. **Screen reader support**: Test with TalkBack/VoiceOver
3. **Color contrast**: Ensure WCAG AA compliance
4. **Touch targets**: Minimum 48x48 dp
5. **Keyboard navigation**: Support tab navigation for web

### Platform-Specific Considerations

**iOS**:

- Test drag-and-drop with iOS gestures
- Ensure PDF generation works on iOS
- Test authentication persistence

**Android**:

- Test back button navigation
- Test drag-and-drop with Android gestures
- Ensure PDF sharing works

**Web**:

- Responsive design for desktop/tablet
- Keyboard shortcuts for power users
- Browser compatibility testing
- Deep linking support

---

## Summary

This guide provides a complete blueprint for recreating the OXO Menus application in Flutter using:

- **Clean Architecture** with strict layer separation
- **Test-Driven Development** with comprehensive test coverage
- **Riverpod** for state management
- **Directus API Manager** for backend integration
- **Extensible widget system** for custom content types
- **PDF generation** for menu export

Follow the implementation roadmap phase by phase, maintaining test coverage and code quality throughout the development process.
