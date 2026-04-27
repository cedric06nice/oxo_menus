import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/features/auth/presentation/pages/login_page.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';

import '../../../../../fakes/fake_auth_repository.dart';
import '../../../../../fakes/result_helpers.dart';

void main() {
  late FakeAuthRepository fakeAuthRepo;

  setUp(() {
    fakeAuthRepo = FakeAuthRepository();
    // AuthNotifier calls tryRestoreSession on init — wire a default response.
    fakeAuthRepo.defaultTryRestoreSessionResponse = failure<User>(
      const UnauthorizedError(),
    );
  });

  Widget buildTestApp({
    required Stream<ConnectivityStatus> connectivityStream,
  }) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepo),
        connectivityProvider.overrideWith((_) => connectivityStream),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage offline banner', () {
    testWidgets('should show OfflineBanner when connectivity is offline', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildTestApp(
          connectivityStream: Stream.value(ConnectivityStatus.offline),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(OfflineBanner), findsOneWidget);
    });

    testWidgets(
      'should show "You are offline" text when connectivity is offline',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestApp(
            connectivityStream: Stream.value(ConnectivityStatus.offline),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('You are offline'), findsOneWidget);
      },
    );

    testWidgets('should not show OfflineBanner when connectivity is online', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildTestApp(
          connectivityStream: Stream.value(ConnectivityStatus.online),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(OfflineBanner), findsNothing);
    });

    testWidgets(
      'should hide OfflineBanner when status changes from offline to online',
      (tester) async {
        // Arrange — start offline
        final controller = StreamController<ConnectivityStatus>();
        addTearDown(controller.close);

        await tester.pumpWidget(
          buildTestApp(connectivityStream: controller.stream),
        );
        controller.add(ConnectivityStatus.offline);
        await tester.pumpAndSettle();

        expect(find.byType(OfflineBanner), findsOneWidget);

        // Act — go online
        controller.add(ConnectivityStatus.online);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(OfflineBanner), findsNothing);
      },
    );

    testWidgets(
      'should show OfflineBanner when status changes from online to offline',
      (tester) async {
        // Arrange — start online
        final controller = StreamController<ConnectivityStatus>();
        addTearDown(controller.close);

        await tester.pumpWidget(
          buildTestApp(connectivityStream: controller.stream),
        );
        controller.add(ConnectivityStatus.online);
        await tester.pumpAndSettle();

        expect(find.byType(OfflineBanner), findsNothing);

        // Act — go offline
        controller.add(ConnectivityStatus.offline);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(OfflineBanner), findsOneWidget);
      },
    );
  });
}
