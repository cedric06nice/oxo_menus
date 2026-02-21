import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/template_create_dialog.dart';

class MockSizeRepository extends Mock implements SizeRepository {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockSizeRepository mockSizeRepository;

  setUp(() {
    mockSizeRepository = MockSizeRepository();
  });

  Widget buildApp({required MockSizeRepository sizeRepo, GoRouter? router}) {
    final goRouter =
        router ??
        GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => TemplateCreateDialog(onSave: (_) {}),
                    ),
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/admin/sizes',
              builder: (_, _) => const Scaffold(body: Text('Admin Sizes Page')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [sizeRepositoryProvider.overrideWithValue(sizeRepo)],
      child: MaterialApp.router(routerConfig: goRouter),
    );
  }

  group('TemplateCreateDialog', () {
    testWidgets(
      'should show "No page sizes available" and navigate button when sizes list is empty',
      (tester) async {
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => const Success(<domain.Size>[]));

        await tester.pumpWidget(buildApp(sizeRepo: mockSizeRepository));

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('No page sizes available.'), findsOneWidget);
        expect(find.text('Manage Page Sizes'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to /admin/sizes when "Manage Page Sizes" is tapped',
      (tester) async {
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => const Success(<domain.Size>[]));

        await tester.pumpWidget(buildApp(sizeRepo: mockSizeRepository));

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Manage Page Sizes'));
        await tester.pumpAndSettle();

        // Dialog should be closed and we should be on the admin sizes page
        expect(find.text('Admin Sizes Page'), findsOneWidget);
      },
    );

    testWidgets('should show size dropdown when sizes are available', (
      tester,
    ) async {
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

      await tester.pumpWidget(buildApp(sizeRepo: mockSizeRepository));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Manage Page Sizes'), findsNothing);
      expect(find.text('Page Size'), findsOneWidget);
    });
  });
}
