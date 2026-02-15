import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'app_router_test.reflectable.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockDuplicateMenuUseCase extends Mock implements DuplicateMenuUseCase {}

void main() {
  initializeReflectable();
  late MockAuthRepository mockAuthRepository;
  late MockMenuRepository mockMenuRepository;
  late MockPageRepository mockPageRepository;
  late MockContainerRepository mockContainerRepository;
  late MockColumnRepository mockColumnRepository;
  late MockWidgetRepository mockWidgetRepository;
  late MockDuplicateMenuUseCase mockDuplicateMenuUseCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockMenuRepository = MockMenuRepository();
    mockPageRepository = MockPageRepository();
    mockContainerRepository = MockContainerRepository();
    mockColumnRepository = MockColumnRepository();
    mockWidgetRepository = MockWidgetRepository();
    mockDuplicateMenuUseCase = MockDuplicateMenuUseCase();

    // Default behavior for menu repository (return empty list)
    when(
      () => mockMenuRepository.listAll(
        onlyPublished: any(named: 'onlyPublished'),
      ),
    ).thenAnswer((_) async => const Success([]));

    // Default behavior for AdminTemplateEditorPage to prevent loading timeout
    when(
      () => mockMenuRepository.getById(any()),
    ).thenAnswer((_) async => const Failure(NotFoundError()));
    when(
      () => mockPageRepository.getAllForMenu(any()),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => mockContainerRepository.getAllForPage(any()),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => mockColumnRepository.getAllForContainer(any()),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => mockWidgetRepository.getAllForColumn(any()),
    ).thenAnswer((_) async => const Success([]));
  });

  group('AppRouter - Route Configuration', () {
    testWidgets('should have /login route', (tester) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be on login page by default
      expect(find.text('OXO Menus'), findsOneWidget);
    });

    testWidgets('should have /home route', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be redirected to home
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('should have /menus route', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to menus
      router.go('/menus');
      await tester.pumpAndSettle();

      // Should show menus page
      expect(find.text('Menus'), findsOneWidget);
    });

    testWidgets('should have /menus/:id route', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to menu editor
      router.go('/menus/123');
      await tester.pumpAndSettle();

      // Should show error message from MenuEditorPage (menu not found)
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('should have /admin/templates route for admins', (
      tester,
    ) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to admin templates
      router.go('/admin/templates');
      await tester.pumpAndSettle();

      // Should show admin templates page
      expect(find.text('No templates found'), findsOneWidget);
    });

    testWidgets('should have /admin/templates/:id route for admins', (
      tester,
    ) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
            pageRepositoryProvider.overrideWithValue(mockPageRepository),
            containerRepositoryProvider.overrideWithValue(
              mockContainerRepository,
            ),
            columnRepositoryProvider.overrideWithValue(mockColumnRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to admin template editor
      router.go('/admin/templates/123');
      await tester.pumpAndSettle();

      // Should show error message from AdminTemplateEditorPage (menu not found)
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  group('AppRouter - Auth Guards', () {
    testWidgets('should redirect unauthenticated users to login', (
      tester,
    ) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to protected route
      router.go('/menus');
      await tester.pumpAndSettle();

      // Should be redirected to login
      expect(find.text('OXO Menus'), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('should redirect authenticated users away from login', (
      tester,
    ) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to login
      router.go('/login');
      await tester.pumpAndSettle();

      // Should be redirected to home
      expect(find.text('Quick Actions'), findsOneWidget);
    });
  });

  group('AppRouter - Admin Guards', () {
    testWidgets('should block non-admin users from admin routes', (
      tester,
    ) async {
      const testUser = User(
        id: '1',
        email: 'user@example.com',
        role: UserRole.user,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to admin route
      router.go('/admin/templates');
      await tester.pumpAndSettle();

      // Should be redirected to home
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('No templates found'), findsNothing);
    });

    testWidgets('should allow admin users to access admin routes', (
      tester,
    ) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to admin route
      router.go('/admin/templates');
      await tester.pumpAndSettle();

      // Should show admin page
      expect(find.text('No templates found'), findsOneWidget);
    });
  });

  group('AppRouter - Deep Linking', () {
    testWidgets('should support deep linking to menu detail', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@example.com',
        role: UserRole.user,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate deep link by programmatically navigating
      router.go('/menus/123');
      await tester.pumpAndSettle();

      // Should navigate directly to menu editor (shows error because menu not found)
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('should support deep linking to admin template editor', (
      tester,
    ) async {
      const testUser = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
      );

      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Success(testUser));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            widgetRepositoryProvider.overrideWithValue(mockWidgetRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
            pageRepositoryProvider.overrideWithValue(mockPageRepository),
            containerRepositoryProvider.overrideWithValue(
              mockContainerRepository,
            ),
            columnRepositoryProvider.overrideWithValue(mockColumnRepository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate deep link by programmatically navigating
      router.go('/admin/templates/123');
      await tester.pumpAndSettle();

      // Should navigate directly to admin template editor (shows error because menu not found)
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('should redirect deep link to login if unauthenticated', (
      tester,
    ) async {
      when(
        () => mockAuthRepository.tryRestoreSession(),
      ).thenAnswer((_) async => const Failure(UnauthorizedError()));

      late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(mockDuplicateMenuUseCase),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to protected route via deep link
      router.go('/menus/123');
      await tester.pumpAndSettle();

      // Should be redirected to login
      expect(find.text('OXO Menus'), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });
  });
}
