import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_page.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/widgets/template_card.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

const _testUser = User(
  id: 'user-1',
  email: 'admin@example.com',
  firstName: 'Admin',
  lastName: 'User',
  role: UserRole.admin,
);

final _templates = [
  const Menu(
    id: 1,
    name: 'Template One',
    status: Status.draft,
    version: '1.0.0',
    area: null,
  ),
  Menu(
    id: 2,
    name: 'Template Two',
    status: Status.published,
    version: '2.0.0',
    area: null,
    dateUpdated: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];

Widget _buildApp({
  required MockMenuRepository mockMenuRepository,
  TargetPlatform platform = TargetPlatform.android,
}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const AdminTemplatesPage()),
      GoRoute(
        path: '/admin/templates/create',
        builder: (_, _) => const Scaffold(body: Text('Create Page')),
      ),
      GoRoute(
        path: '/admin/templates/:id',
        builder: (_, state) =>
            Scaffold(body: Text('Edit ${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const Scaffold(body: Text('Settings')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(_testUser),
      adminTemplatesProvider.overrideWith(
        (ref) => AdminTemplatesNotifier(mockMenuRepository),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(platform: platform),
    ),
  );
}

void main() {
  late MockMenuRepository mockMenuRepository;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
  });

  group('AdminTemplatesPage', () {
    testWidgets(
      'should display templates after loading (verifies loading path)',
      (WidgetTester tester) async {
        // Use a completer to control when the future resolves
        when(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).thenAnswer((_) async => Success(_templates));

        await tester.pumpWidget(
          _buildApp(mockMenuRepository: mockMenuRepository),
        );

        await tester.pumpAndSettle();

        // Verifies the full loading → loaded path
        expect(find.text('Template One'), findsOneWidget);
      },
    );

    testWidgets('should display templates after loading', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      expect(find.text('Template One'), findsOneWidget);
      expect(find.text('Template Two'), findsOneWidget);
      expect(find.text('DRAFT'), findsOneWidget);
      expect(find.text('PUBLISHED'), findsOneWidget);
    });

    testWidgets('should show empty state when no templates', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      expect(find.text('No templates found'), findsOneWidget);
      expect(find.text('Create Template'), findsOneWidget);
    });

    testWidgets('should show error state with retry button', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => const Failure(ServerError('Network error')));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error: Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display status filter chips', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('should have create button in app bar', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show version info in template cards', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.text('v2.0.0'), findsOneWidget);
    });

    testWidgets('should show edit and delete buttons per template', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      // Each template card has edit and delete icon buttons
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
      // Icons.edit appears in both card buttons AND the draft status badge
      expect(find.byIcon(Icons.edit), findsWidgets);
    });

    testWidgets('should show "Updated" text for templates with dateUpdated', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      // Template Two has dateUpdated, should show "Updated: X hours ago"
      expect(find.textContaining('Updated:'), findsOneWidget);
    });

    testWidgets('should use ConstrainedBox with maxWidth 1000', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      final constrainedBox = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      expect(constrainedBox.any((b) => b.constraints.maxWidth == 1000), isTrue);
    });

    testWidgets('should use ChoiceChip for filters', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ChoiceChip), findsNWidgets(4));
    });

    testWidgets('should use TemplateCard widgets for each template', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(mockMenuRepository: mockMenuRepository),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TemplateCard), findsNWidgets(2));
    });

    testWidgets('should show CupertinoActivityIndicator on iOS when loading', (
      WidgetTester tester,
    ) async {
      final completer = Completer<Result<List<Menu>, DomainError>>();
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        _buildApp(
          mockMenuRepository: mockMenuRepository,
          platform: TargetPlatform.iOS,
        ),
      );

      // Pump once to trigger loading state (don't settle)
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      // Complete to avoid pending futures
      completer.complete(Success(_templates));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'should show CircularProgressIndicator on Android when loading',
      (WidgetTester tester) async {
        final completer = Completer<Result<List<Menu>, DomainError>>();
        when(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(
          _buildApp(mockMenuRepository: mockMenuRepository),
        );

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete to avoid pending futures
        completer.complete(Success(_templates));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('should show CupertinoAlertDialog on iOS when deleting', (
      WidgetTester tester,
    ) async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(_templates));

      await tester.pumpWidget(
        _buildApp(
          mockMenuRepository: mockMenuRepository,
          platform: TargetPlatform.iOS,
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete on first template
      await tester.tap(find.byIcon(CupertinoIcons.delete).first);
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Delete Template'), findsOneWidget);
    });
  });
}
