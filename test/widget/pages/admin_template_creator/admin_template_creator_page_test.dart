import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_template_creator/admin_template_creator_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

class MockSizeRepository extends Mock implements SizeRepository {}

class MockMenuRepository extends Mock implements MenuRepository {}

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

Widget _buildApp({
  required MockSizeRepository mockSizeRepository,
  required MockMenuRepository mockMenuRepository,
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
      sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
      menuRepositoryProvider.overrideWithValue(mockMenuRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late MockSizeRepository mockSizeRepository;
  late MockMenuRepository mockMenuRepository;

  setUp(() {
    mockSizeRepository = MockSizeRepository();
    mockMenuRepository = MockMenuRepository();
  });

  setUpAll(() {
    registerFallbackValue(const CreateMenuInput(name: '', version: ''));
  });

  group('AdminTemplateCreatorPage', () {
    testWidgets('should display form fields for template creation', (
      WidgetTester tester,
    ) async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success(_testSizes));

      await tester.pumpWidget(
        _buildApp(
          mockSizeRepository: mockSizeRepository,
          mockMenuRepository: mockMenuRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Template'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Template Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Version'), findsOneWidget);
    });

    testWidgets('should display size dropdown with loaded sizes', (
      WidgetTester tester,
    ) async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success(_testSizes));

      await tester.pumpWidget(
        _buildApp(
          mockSizeRepository: mockSizeRepository,
          mockMenuRepository: mockMenuRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('A4 (210x297 mm)'), findsOneWidget);
    });

    testWidgets('should show loading state while sizes are loading', (
      WidgetTester tester,
    ) async {
      final completer = Completer<Result<List<domain.Size>, DomainError>>();
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        _buildApp(
          mockSizeRepository: mockSizeRepository,
          mockMenuRepository: mockMenuRepository,
        ),
      );

      await tester.pump();

      expect(find.text('Loading sizes...'), findsOneWidget);

      // Complete to avoid pending futures
      completer.complete(const Success(_testSizes));
      await tester.pumpAndSettle();
    });

    testWidgets('should show error when sizes fail to load', (
      WidgetTester tester,
    ) async {
      when(() => mockSizeRepository.getAll()).thenAnswer(
        (_) async => const Failure(ServerError('Connection failed')),
      );

      await tester.pumpWidget(
        _buildApp(
          mockSizeRepository: mockSizeRepository,
          mockMenuRepository: mockMenuRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Error loading sizes'), findsOneWidget);
    });

    testWidgets('should disable create button when form is incomplete', (
      WidgetTester tester,
    ) async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success(_testSizes));

      await tester.pumpWidget(
        _buildApp(
          mockSizeRepository: mockSizeRepository,
          mockMenuRepository: mockMenuRepository,
        ),
      );

      await tester.pumpAndSettle();

      // Name field is empty, so create button should be disabled
      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create'),
      );
      expect(createButton.onPressed, isNull);
    });

    testWidgets('should create template and navigate to editor on save', (
      WidgetTester tester,
    ) async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success(_testSizes));

      const createdMenu = Menu(
        id: 42,
        name: 'Test Template',
        status: Status.draft,
        version: '1.0.0',
      );

      when(
        () => mockMenuRepository.create(any()),
      ).thenAnswer((_) async => const Success(createdMenu));

      await tester.pumpWidget(
        _buildApp(
          mockSizeRepository: mockSizeRepository,
          mockMenuRepository: mockMenuRepository,
        ),
      );

      await tester.pumpAndSettle();

      // Fill in the name field
      await tester.enterText(
        find.widgetWithText(TextField, 'Template Name'),
        'Test Template',
      );

      await tester.pump();

      // Tap create button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      // Should navigate to editor with menu id 42
      expect(find.text('Editor 42'), findsOneWidget);
    });

    testWidgets('should navigate back on cancel', (WidgetTester tester) async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success(_testSizes));

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
            sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
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

      // Tap cancel button
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Should navigate back to templates
      expect(find.text('Templates'), findsOneWidget);
    });
  });
}
