import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/pages/admin_template_creator/admin_template_creator_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

import '../../../fakes/fake_area_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_size_repository.dart';

const _testUser = User(
  id: 'user-1',
  email: 'admin@example.com',
  firstName: 'Admin',
  lastName: 'User',
  role: UserRole.admin,
);

const _testSizes = [
  domain.Size(
    id: 1,
    name: 'A4',
    width: 210,
    height: 297,
    status: Status.published,
    direction: 'portrait',
  ),
  domain.Size(
    id: 2,
    name: 'A5',
    width: 148,
    height: 210,
    status: Status.published,
    direction: 'portrait',
  ),
];

const _testAreas = [Area(id: 1, name: 'Dining'), Area(id: 2, name: 'Bar')];

Widget _buildApp({
  required FakeSizeRepository fakeSizeRepository,
  required FakeMenuRepository fakeMenuRepository,
  required FakeAreaRepository fakeAreaRepository,
}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const AdminTemplateCreatorPage()),
      GoRoute(
        path: '/admin/templates/:id',
        builder: (_, state) =>
            Scaffold(body: Text('Editor ${state.pathParameters['id']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(_testUser),
      sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
      menuRepositoryProvider.overrideWithValue(fakeMenuRepository),
      areaRepositoryProvider.overrideWithValue(fakeAreaRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('AdminTemplateCreatorPage', () {
    testWidgets('should display form fields for template creation', (
      WidgetTester tester,
    ) async {
      // Arrange
      final fakeSize = FakeSizeRepository()
        ..whenGetAll(const Success(_testSizes));
      final fakeMenu = FakeMenuRepository();
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      // Act
      await tester.pumpWidget(
        _buildApp(
          fakeSizeRepository: fakeSize,
          fakeMenuRepository: fakeMenu,
          fakeAreaRepository: fakeArea,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create Template'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Template Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Version'), findsOneWidget);
    });

    testWidgets('should display size dropdown with loaded sizes', (
      WidgetTester tester,
    ) async {
      // Arrange
      final fakeSize = FakeSizeRepository()
        ..whenGetAll(const Success(_testSizes));
      final fakeMenu = FakeMenuRepository();
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      // Act
      await tester.pumpWidget(
        _buildApp(
          fakeSizeRepository: fakeSize,
          fakeMenuRepository: fakeMenu,
          fakeAreaRepository: fakeArea,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('A4 (210x297 mm)'), findsOneWidget);
    });

    testWidgets('should show loading state while sizes are loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      final completer = Completer<Result<List<domain.Size>, DomainError>>();
      final fakeSize = _SlowFakeSizeRepository(completer.future);
      final fakeMenu = FakeMenuRepository();
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      // Act
      await tester.pumpWidget(
        _buildApp(
          fakeSizeRepository: fakeSize,
          fakeMenuRepository: fakeMenu,
          fakeAreaRepository: fakeArea,
        ),
      );
      // Pump to trigger addPostFrameCallback (starts loadSizes, sets isLoading)
      await tester.pump();
      // Pump again to rebuild widget after provider state change
      await tester.pump();

      // Assert
      expect(find.text('Loading sizes...'), findsOneWidget);

      // Complete to avoid pending futures
      completer.complete(const Success(_testSizes));
      await tester.pumpAndSettle();
    });

    testWidgets('should show error when sizes fail to load', (
      WidgetTester tester,
    ) async {
      // Arrange
      final fakeSize = FakeSizeRepository()
        ..whenGetAll(const Failure(ServerError('Connection failed')));
      final fakeMenu = FakeMenuRepository();
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      // Act
      await tester.pumpWidget(
        _buildApp(
          fakeSizeRepository: fakeSize,
          fakeMenuRepository: fakeMenu,
          fakeAreaRepository: fakeArea,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Error loading sizes'), findsOneWidget);
    });

    testWidgets('should disable create button when form is incomplete', (
      WidgetTester tester,
    ) async {
      // Arrange
      final fakeSize = FakeSizeRepository()
        ..whenGetAll(const Success(_testSizes));
      final fakeMenu = FakeMenuRepository();
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      // Act
      await tester.pumpWidget(
        _buildApp(
          fakeSizeRepository: fakeSize,
          fakeMenuRepository: fakeMenu,
          fakeAreaRepository: fakeArea,
        ),
      );
      await tester.pumpAndSettle();

      // Assert — Name field is empty, so create button should be disabled
      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create'),
      );
      expect(createButton.onPressed, isNull);
    });

    testWidgets('should create template and navigate to editor on save', (
      WidgetTester tester,
    ) async {
      // Arrange
      const createdMenu = Menu(
        id: 42,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final fakeSize = FakeSizeRepository()
        ..whenGetAll(const Success(_testSizes));
      final fakeMenu = FakeMenuRepository()
        ..whenCreate(const Success(createdMenu));
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      await tester.pumpWidget(
        _buildApp(
          fakeSizeRepository: fakeSize,
          fakeMenuRepository: fakeMenu,
          fakeAreaRepository: fakeArea,
        ),
      );
      await tester.pumpAndSettle();

      // Act — fill in the name field
      await tester.enterText(
        find.widgetWithText(TextField, 'Template Name'),
        'Test Template',
      );
      await tester.pump();

      // Tap create button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      // Assert — should navigate to editor with menu id 42
      expect(find.text('Editor 42'), findsOneWidget);
    });

    testWidgets('should navigate back on cancel', (WidgetTester tester) async {
      // Arrange
      final fakeSize = FakeSizeRepository()
        ..whenGetAll(const Success(_testSizes));
      final fakeMenu = FakeMenuRepository();
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      late GoRouter router;
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => router.push('/create'),
                child: const Text('Templates'),
              ),
            ),
          ),
          GoRoute(
            path: '/create',
            builder: (_, _) => const AdminTemplateCreatorPage(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(_testUser),
            sizeRepositoryProvider.overrideWithValue(fakeSize),
            menuRepositoryProvider.overrideWithValue(fakeMenu),
            areaRepositoryProvider.overrideWithValue(fakeArea),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to create page
      await tester.tap(find.text('Templates'));
      await tester.pumpAndSettle();

      // Verify we're on create page
      expect(find.text('Create Template'), findsOneWidget);

      // Act — tap cancel button
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Assert — should navigate back to templates
      expect(find.text('Templates'), findsOneWidget);
    });

    testWidgets(
      'should auto-select first size when sizes load asynchronously',
      (WidgetTester tester) async {
        // Arrange
        final completer = Completer<Result<List<domain.Size>, DomainError>>();
        final fakeSize = _SlowFakeSizeRepository(completer.future);
        final fakeMenu = FakeMenuRepository();
        final fakeArea = FakeAreaRepository()
          ..whenGetAll(const Success(_testAreas));

        await tester.pumpWidget(
          _buildApp(
            fakeSizeRepository: fakeSize,
            fakeMenuRepository: fakeMenu,
            fakeAreaRepository: fakeArea,
          ),
        );

        // Trigger the addPostFrameCallback that calls loadSizes
        await tester.pump();
        await tester.pump();

        // Sizes haven't loaded yet — no dropdown visible
        expect(find.text('Loading sizes...'), findsOneWidget);

        // Act — complete the sizes future
        completer.complete(const Success(_testSizes));
        await tester.pumpAndSettle();

        // Assert — first size should be auto-selected in the dropdown
        expect(find.text('A4 (210x297 mm)'), findsOneWidget);

        // Create button should still be disabled (name is empty)
        final createButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Create'),
        );
        expect(createButton.onPressed, isNull);

        // Fill in name and verify create is now enabled
        await tester.enterText(
          find.widgetWithText(TextField, 'Template Name'),
          'My Template',
        );
        await tester.pump();

        final enabledButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Create'),
        );
        expect(enabledButton.onPressed, isNotNull);
      },
    );

    testWidgets('should display area dropdown with loaded areas', (
      WidgetTester tester,
    ) async {
      // Arrange
      final fakeSize = FakeSizeRepository()
        ..whenGetAll(const Success(_testSizes));
      final fakeMenu = FakeMenuRepository();
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      // Act
      await tester.pumpWidget(
        _buildApp(
          fakeSizeRepository: fakeSize,
          fakeMenuRepository: fakeMenu,
          fakeAreaRepository: fakeArea,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Area'), findsOneWidget);
    });

    testWidgets('should pass areaId when creating with selected area', (
      WidgetTester tester,
    ) async {
      // Arrange
      const createdMenu = Menu(
        id: 42,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );
      final fakeSize = FakeSizeRepository()
        ..whenGetAll(const Success(_testSizes));
      final fakeMenu = FakeMenuRepository()
        ..whenCreate(const Success(createdMenu));
      final fakeArea = FakeAreaRepository()
        ..whenGetAll(const Success(_testAreas));

      await tester.pumpWidget(
        _buildApp(
          fakeSizeRepository: fakeSize,
          fakeMenuRepository: fakeMenu,
          fakeAreaRepository: fakeArea,
        ),
      );
      await tester.pumpAndSettle();

      // Fill in name
      await tester.enterText(
        find.widgetWithText(TextField, 'Template Name'),
        'Test Template',
      );
      await tester.pump();

      // Select area from dropdown
      await tester.tap(find.text('Area').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dining').last);
      await tester.pumpAndSettle();

      // Act — tap create button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      // Assert — the CreateMenuInput had areaId: 1
      expect(fakeMenu.createCalls, hasLength(1));
      expect(fakeMenu.createCalls.first.input.areaId, 1);
    });
  });
}

// ---------------------------------------------------------------------------
// Helper fake for slow async responses
// ---------------------------------------------------------------------------

class _SlowFakeSizeRepository extends FakeSizeRepository {
  final Future<Result<List<domain.Size>, DomainError>> _future;

  _SlowFakeSizeRepository(this._future);

  @override
  Future<Result<List<domain.Size>, DomainError>> getAll() async {
    calls.add(const GetAllSizesCall());
    return _future;
  }
}
