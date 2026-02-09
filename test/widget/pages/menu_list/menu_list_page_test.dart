import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/pages/menu_list/menu_list_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockGoRouter extends Mock implements GoRouter {}

class MockSizeRepository extends Mock implements SizeRepository {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MockGoRouter mockRouter;
  late MockSizeRepository mockSizeRepository;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockRouter = MockGoRouter();
    mockSizeRepository = MockSizeRepository();

    // Default behavior for size repository
    when(() => mockSizeRepository.getAll()).thenAnswer(
      (_) async => const Success([
        domain.Size(id: 1, name: 'A4', width: 210, height: 297),
      ]),
    );
  });

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  Widget createWidgetUnderTest({bool isAdmin = false}) {
    final mockUser = User(
      id: 'user-1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: isAdmin ? UserRole.admin : UserRole.user,
    );

    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
        isAdminProvider.overrideWithValue(isAdmin),
        currentUserProvider.overrideWithValue(mockUser),
      ],
      child: MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockRouter,
          child: const MenuListPage(),
        ),
      ),
    );
  }

  group('MenuListPage - Initial State', () {
    testWidgets('should show loading indicator initially', (tester) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => const Success([]),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Let the widget initialize and trigger loadMenus

      // Assert - should show loading indicator before data loads
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up - let the future complete
      await tester.pumpAndSettle();
    });

    testWidgets('should have app bar with title', (tester) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.widgetWithText(AppBar, 'Menus'), findsOneWidget);
    });

    testWidgets('should show add button for admin users', (tester) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should not show add button for regular users', (tester) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.add), findsNothing);
    });
  });

  group('MenuListPage - Empty State', () {
    testWidgets('should show empty message when no menus', (tester) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No menus found'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('MenuListPage - Menu List Display', () {
    testWidgets('should display list of menus', (tester) async {
      // Arrange
      final menus = [
        const Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
        const Menu(
          id: 2,
          name: 'Winter Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => Success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Summer Menu'), findsOneWidget);
      expect(find.text('Winter Menu'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should load only published menus for regular users', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(onlyPublished: true),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockMenuRepository.listAll(onlyPublished: true)).called(1);
    });

    testWidgets('should load all menus for admin users', (tester) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockMenuRepository.listAll(onlyPublished: false)).called(1);
    });
  });

  group('MenuListPage - Error Handling', () {
    testWidgets('should show error message when loading fails', (tester) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => const Failure(NetworkError('Network error')));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Network error'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('MenuListPage - Navigation', () {
    testWidgets('should navigate to menu editor when menu is tapped', (
      tester,
    ) async {
      // Arrange
      final menus = [
        const Menu(
          id: 123,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => Success(menus));
      when(() => mockRouter.push(any())).thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Summer Menu'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRouter.push('/menus/123')).called(1);
    });

    testWidgets('should open create template dialog when add button tapped', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => const Success([]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert — TemplateCreateDialog should be shown
      expect(find.text('Create Template'), findsOneWidget);
    });
  });

  group('MenuListPage - Delete Menu (Admin)', () {
    testWidgets('should show delete button for admin users', (tester) async {
      // Arrange
      final menus = [
        const Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => Success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should not show delete button for regular users', (
      tester,
    ) async {
      // Arrange
      final menus = [
        const Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => Success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('should show confirmation dialog when delete is tapped', (
      tester,
    ) async {
      // Arrange
      final menus = [
        const Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => Success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete Menu'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete "Summer Menu"?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should delete menu when confirmed', (tester) async {
      // Arrange
      final menus = [
        const Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => Success(menus));
      when(
        () => mockMenuRepository.delete(1),
      ).thenAnswer((_) async => const Success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockMenuRepository.delete(1)).called(1);
      expect(
        find.text('Summer Menu'),
        findsNothing,
      ); // Menu should be removed from list
    });

    testWidgets('should not delete menu when cancelled', (tester) async {
      // Arrange
      final menus = [
        const Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => Success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      verifyNever(() => mockMenuRepository.delete(any()));
      expect(
        find.text('Summer Menu'),
        findsOneWidget,
      ); // Menu should still be there
    });
  });

  group('MenuListPage - Pull to Refresh', () {
    testWidgets('should support pull to refresh', (tester) async {
      // Arrange
      final menus = [
        const Menu(
          id: 1,
          name: 'Test Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
        ),
      ).thenAnswer((_) async => Success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Perform pull to refresh gesture on the scrollable content
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      // Assert - loadMenus should be called twice (initial + refresh)
      verify(() => mockMenuRepository.listAll(onlyPublished: true)).called(2);
    });
  });
}
