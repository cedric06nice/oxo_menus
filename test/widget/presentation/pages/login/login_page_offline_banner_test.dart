import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/presentation/pages/login/login_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/offline_banner.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.tryRestoreSession()).thenAnswer(
      (_) async => const Failure<User, DomainError>(UnauthorizedError()),
    );
  });

  Widget buildTestApp({
    required Stream<ConnectivityStatus> connectivityStream,
  }) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((_) => AuthNotifier(mockAuthRepo)),
        connectivityProvider.overrideWith((_) => connectivityStream),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage offline banner', () {
    testWidgets('shows OfflineBanner when offline', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          connectivityStream: Stream.value(ConnectivityStatus.offline),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('You are offline'), findsOneWidget);
    });

    testWidgets('does not show OfflineBanner when online', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          connectivityStream: Stream.value(ConnectivityStatus.online),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsNothing);
    });
  });
}
