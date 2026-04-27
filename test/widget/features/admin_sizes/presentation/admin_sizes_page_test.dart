import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/admin_sizes_page.dart';
import 'package:oxo_menus/shared/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

import '../../../../fakes/fake_size_repository.dart';

const _testUser = User(
  id: 'user-1',
  email: 'admin@example.com',
  firstName: 'Admin',
  lastName: 'User',
  role: UserRole.admin,
);

final _sizes = [
  const domain.Size(
    id: 1,
    name: 'A4',
    width: 210,
    height: 297,
    status: Status.published,
    direction: 'portrait',
  ),
  const domain.Size(
    id: 2,
    name: 'Letter',
    width: 215.9,
    height: 279.4,
    status: Status.draft,
    direction: 'landscape',
  ),
];

Widget _buildApp({
  required FakeSizeRepository fakeSizeRepository,
  TargetPlatform platform = TargetPlatform.android,
}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const AdminSizesPage()),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const Scaffold(body: Text('Settings')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(_testUser),
      sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(platform: platform),
    ),
  );
}

void main() {
  group('AdminSizesPage', () {
    testWidgets('should display sizes after loading', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(Success(_sizes));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('A4'), findsOneWidget);
      expect(find.text('Letter'), findsOneWidget);
    });

    testWidgets('should show empty state when no sizes exist', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(const Success([]));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No page sizes found'), findsOneWidget);
      expect(find.text('Create your first page size'), findsOneWidget);
    });

    testWidgets('should show error state with retry button', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(const Failure(ServerError('Network error')));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error: Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display status filter chips', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(Success(_sizes));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('should have add button in app bar', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(Success(_sizes));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show dimensions in size cards', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(Success(_sizes));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('210'), findsWidgets);
      expect(find.textContaining('297'), findsWidgets);
    });

    testWidgets('should show edit and delete buttons per size', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(Success(_sizes));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
      expect(find.byIcon(Icons.edit), findsWidgets);
    });

    testWidgets('should show create dialog when add button is tapped', (
      tester,
    ) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(Success(_sizes));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create Page Size'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(Success(_sizes));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Page Size'), findsOneWidget);
      expect(find.textContaining('Are you sure'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should show direction info in size cards', (tester) async {
      // Arrange
      final fake = FakeSizeRepository();
      fake.whenGetAll(Success(_sizes));

      // Act
      await tester.pumpWidget(_buildApp(fakeSizeRepository: fake));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Portrait'), findsWidgets);
      expect(find.textContaining('Landscape'), findsWidgets);
    });

    group('iOS platform', () {
      testWidgets('shows CupertinoActivityIndicator while loading on iOS', (
        tester,
      ) async {
        // Arrange
        final completer = Completer<Result<List<domain.Size>, DomainError>>();
        final fakeSlow = _SlowFakeSizeRepository(completer.future);

        // Act
        await tester.pumpWidget(
          _buildApp(fakeSizeRepository: fakeSlow, platform: TargetPlatform.iOS),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Complete to avoid pending timer
        completer.complete(Success(_sizes));
        await tester.pumpAndSettle();
      });

      testWidgets('shows CupertinoIcons in size cards on iOS', (tester) async {
        // Arrange
        final fake = FakeSizeRepository();
        fake.whenGetAll(Success(_sizes));

        // Act
        await tester.pumpWidget(
          _buildApp(fakeSizeRepository: fake, platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(CupertinoIcons.pencil), findsNWidgets(2));
        expect(find.byIcon(CupertinoIcons.delete), findsNWidgets(2));
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
      });

      testWidgets('shows CupertinoAlertDialog for delete confirmation on iOS', (
        tester,
      ) async {
        // Arrange
        final fake = FakeSizeRepository();
        fake.whenGetAll(Success(_sizes));

        // Act
        await tester.pumpWidget(
          _buildApp(fakeSizeRepository: fake, platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.delete).first);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text('Delete Page Size'), findsOneWidget);
      });

      testWidgets('opens SizeCreateEditDialog as full-screen on iOS', (
        tester,
      ) async {
        // Arrange
        final fake = FakeSizeRepository();
        fake.whenGetAll(Success(_sizes));

        // Act
        await tester.pumpWidget(
          _buildApp(fakeSizeRepository: fake, platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.add).first);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CupertinoPageScaffold), findsOneWidget);
        expect(find.text('Create Page Size'), findsOneWidget);
      });

      testWidgets('uses CupertinoButton.filled for error retry on iOS', (
        tester,
      ) async {
        // Arrange
        final fake = FakeSizeRepository();
        fake.whenGetAll(const Failure(ServerError('Network error')));

        // Act
        await tester.pumpWidget(
          _buildApp(fakeSizeRepository: fake, platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CupertinoButton), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
      });
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
