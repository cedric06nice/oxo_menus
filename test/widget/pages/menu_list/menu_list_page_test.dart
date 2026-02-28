import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/area_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/presentation/pages/menu_list/menu_list_page.dart';
import 'package:oxo_menus/presentation/pages/menu_list/widgets/menu_list_item.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockGoRouter extends Mock implements GoRouter {}

class MockSizeRepository extends Mock implements SizeRepository {}

class MockAreaRepository extends Mock implements AreaRepository {}

class MockDuplicateMenuUseCase extends Mock implements DuplicateMenuUseCase {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MockGoRouter mockRouter;
  late MockSizeRepository mockSizeRepository;
  late MockAreaRepository mockAreaRepository;
  late MockDuplicateMenuUseCase mockDuplicateMenuUseCase;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockRouter = MockGoRouter();
    mockSizeRepository = MockSizeRepository();
    mockAreaRepository = MockAreaRepository();
    mockDuplicateMenuUseCase = MockDuplicateMenuUseCase();

    // Default behavior for area repository
    when(
      () => mockAreaRepository.getAll(),
    ).thenAnswer((_) async => const Success([Area(id: 1, name: 'Dining')]));

    // Default behavior for size repository
    when(() => mockSizeRepository.getAll()).thenAnswer(
      (_) async => const Success([
        domain.Size(
          id: 1,
          name: 'A4',
          width: 210,
          height: 297,
          status: Status.published,
          direction: 'portrait',
        ),
      ]),
    );
  });

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  Widget createWidgetUnderTest({
    bool isAdmin = false,
    TargetPlatform platform = TargetPlatform.android,
  }) {
    final mockUser = User(
      id: 'user-1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: isAdmin ? UserRole.admin : UserRole.user,
      areas: isAdmin ? const [] : const [Area(id: 1, name: 'Dining')],
    );

    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
        areaRepositoryProvider.overrideWithValue(mockAreaRepository),
        duplicateMenuUseCaseProvider.overrideWithValue(
          mockDuplicateMenuUseCase,
        ),
        isAdminProvider.overrideWithValue(isAdmin),
        currentUserProvider.overrideWithValue(mockUser),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        home: InheritedGoRouter(
          goRouter: mockRouter,
          child: const MenuListPage(),
        ),
      ),
    );
  }

  group('MenuListPage - Initial State', () {
    testWidgets('should show loading indicator initially on Material', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => const Success([]),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should show CupertinoActivityIndicator on Apple', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer(
        (_) async => Future.delayed(
          const Duration(milliseconds: 100),
          () => const Success([]),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should have app bar with title', (tester) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Menus'), findsOneWidget);
    });

    testWidgets('should show Material add button for admin on Android', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        createWidgetUnderTest(isAdmin: true, platform: TargetPlatform.android),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show Cupertino add button for admin on iOS', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        createWidgetUnderTest(isAdmin: true, platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
    });

    testWidgets('should not show add button for regular users', (tester) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(CupertinoIcons.add), findsNothing);
    });
  });

  group('MenuListPage - Empty State', () {
    testWidgets('should show themed empty state with icon on Material', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      expect(find.text('No menus found'), findsOneWidget);
      expect(
        find.text('Browse available menus or check back later'),
        findsOneWidget,
      );
    });

    testWidgets('should show themed empty state with icon on Apple', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.doc_text), findsOneWidget);
      expect(find.text('No menus found'), findsOneWidget);
    });

    testWidgets('should not show menu list when empty', (tester) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(MenuListItem), findsNothing);
    });
  });

  group('MenuListPage - Menu List Display', () {
    testWidgets('should display menus in a full-width list', (tester) async {
      final menus = [
        const Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
        const Menu(
          id: 2,
          name: 'Winter Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Summer Menu'), findsOneWidget);
      expect(find.text('Winter Menu'), findsOneWidget);
      expect(find.byType(MenuListItem), findsNWidgets(2));
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should load only published menus for regular users', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1]),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      verify(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1]),
      ).called(1);
    });

    testWidgets('should load all menus for admin users', (tester) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      verify(() => mockMenuRepository.listAll(onlyPublished: false)).called(1);
    });
  });

  group('MenuListPage - Error Handling', () {
    testWidgets('should show themed error state with retry on Material', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Failure(NetworkError('Network error')));

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error: Network error'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show themed error state with retry on Apple', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Failure(NetworkError('Network error')));

      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      expect(
        find.byIcon(CupertinoIcons.exclamationmark_triangle),
        findsOneWidget,
      );
      expect(find.text('Error: Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should retry on button press', (tester) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Failure(NetworkError('Network error')));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // loadMenus called initially + retry = 2
      verify(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).called(2);
    });
  });

  group('MenuListPage - Navigation', () {
    testWidgets('should navigate to menu editor when menu is tapped', (
      tester,
    ) async {
      final menus = [
        const Menu(
          id: 123,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));
      when(() => mockRouter.push(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Summer Menu'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.push('/menus/123')).called(1);
    });

    testWidgets('should open create template dialog when add button tapped', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // TemplateCreateDialog should be shown
      expect(find.text('Create Template'), findsOneWidget);
    });
  });

  group('MenuListPage - Delete Menu (Admin)', () {
    testWidgets('should show delete button for admin users', (tester) async {
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
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should not show delete button for regular users', (
      tester,
    ) async {
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
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets(
      'should show AlertDialog confirmation on Material when delete tapped',
      (tester) async {
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

        await tester.pumpWidget(
          createWidgetUnderTest(
            isAdmin: true,
            platform: TargetPlatform.android,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Delete Menu'), findsOneWidget);
        expect(
          find.text('Are you sure you want to delete "Summer Menu"?'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should show CupertinoAlertDialog on Apple when delete tapped',
      (tester) async {
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

        await tester.pumpWidget(
          createWidgetUnderTest(isAdmin: true, platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(CupertinoIcons.delete));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text('Delete Menu'), findsOneWidget);
      },
    );

    testWidgets('should delete menu when confirmed', (tester) async {
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
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));
      when(
        () => mockMenuRepository.delete(1),
      ).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => mockMenuRepository.delete(1)).called(1);
      expect(find.text('Summer Menu'), findsNothing);
    });

    testWidgets('should not delete menu when cancelled', (tester) async {
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
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockMenuRepository.delete(any()));
      expect(find.text('Summer Menu'), findsOneWidget);
    });
  });

  group('MenuListPage - Pull to Refresh', () {
    testWidgets('should support pull to refresh', (tester) async {
      final menus = [
        const Menu(
          id: 1,
          name: 'Test Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Perform pull to refresh on the scrollable content
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // loadMenus called twice (initial + refresh)
      verify(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1]),
      ).called(2);
    });
  });

  group('MenuListPage - Status Filters', () {
    testWidgets('should show status filter chips for admin', (tester) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      expect(find.byType(ChoiceChip), findsNWidgets(4));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('should not show status filter chips for regular users', (
      tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      expect(find.byType(ChoiceChip), findsNothing);
    });

    testWidgets('should filter menus by status when chip is tapped', (
      tester,
    ) async {
      final menus = [
        const Menu(
          id: 1,
          name: 'Published Menu',
          status: Status.published,
          version: '1.0.0',
        ),
        const Menu(
          id: 2,
          name: 'Draft Menu',
          status: Status.draft,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Both menus shown initially
      expect(find.text('Published Menu'), findsOneWidget);
      expect(find.text('Draft Menu'), findsOneWidget);

      // Tap 'Draft' chip to filter
      await tester.tap(find.text('Draft'));
      await tester.pumpAndSettle();

      // Only draft menu shown
      expect(find.text('Draft Menu'), findsOneWidget);
      expect(find.text('Published Menu'), findsNothing);
    });

    testWidgets(
      'should show all menus when All chip is tapped after filtering',
      (tester) async {
        final menus = [
          const Menu(
            id: 1,
            name: 'Published Menu',
            status: Status.published,
            version: '1.0.0',
          ),
          const Menu(
            id: 2,
            name: 'Draft Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ];

        when(
          () => mockMenuRepository.listAll(
            onlyPublished: any(named: 'onlyPublished'),
          ),
        ).thenAnswer((_) async => Success(menus));

        await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
        await tester.pumpAndSettle();

        // Filter to Draft
        await tester.tap(find.text('Draft'));
        await tester.pumpAndSettle();
        expect(find.text('Published Menu'), findsNothing);

        // Tap All to reset
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        expect(find.text('Published Menu'), findsOneWidget);
        expect(find.text('Draft Menu'), findsOneWidget);
      },
    );
  });

  group('MenuListPage - Area Grouping', () {
    testWidgets('should group menus by area with section headers', (
      tester,
    ) async {
      final menus = [
        const Menu(
          id: 1,
          name: 'Dining Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
        const Menu(
          id: 2,
          name: 'Bar Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 2, name: 'Bar'),
        ),
        const Menu(
          id: 3,
          name: 'Unassigned Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Should show area section headers
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('Bar'), findsOneWidget);
      expect(find.text('Unassigned'), findsOneWidget);
    });

    testWidgets('should pass area IDs to repository for non-admin users', (
      tester,
    ) async {
      // Server-side filtering: mock returns only menus for user's areas
      final filteredMenus = [
        const Menu(
          id: 1,
          name: 'Dining Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];

      when(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1]),
      ).thenAnswer((_) async => Success(filteredMenus));

      // Non-admin user with only Dining area
      final mockUser = User(
        id: 'user-1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.user,
        areas: const [Area(id: 1, name: 'Dining')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            menuRepositoryProvider.overrideWithValue(mockMenuRepository),
            sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
            areaRepositoryProvider.overrideWithValue(mockAreaRepository),
            duplicateMenuUseCaseProvider.overrideWithValue(
              mockDuplicateMenuUseCase,
            ),
            isAdminProvider.overrideWithValue(false),
            currentUserProvider.overrideWithValue(mockUser),
          ],
          child: MaterialApp(
            home: InheritedGoRouter(
              goRouter: mockRouter,
              child: const MenuListPage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify areaIds were passed to repository
      verify(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1]),
      ).called(1);

      // Should only show Dining Menu (server returned only this one)
      expect(find.text('Dining Menu'), findsOneWidget);
    });

    testWidgets('should show area name in menu list item', (tester) async {
      final menus = [
        const Menu(
          id: 1,
          name: 'Dining Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];

      when(
        () => mockMenuRepository.listAll(
          onlyPublished: any(named: 'onlyPublished'),
          areaIds: any(named: 'areaIds'),
        ),
      ).thenAnswer((_) async => Success(menus));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Area name should be visible in the item
      expect(find.text('Dining'), findsWidgets);
    });
  });
}
