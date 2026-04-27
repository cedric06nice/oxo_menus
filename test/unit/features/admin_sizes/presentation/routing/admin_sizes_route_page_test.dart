import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/create_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/delete_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/list_sizes_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/update_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_route_page.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_router.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/screens/admin_sizes_screen.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/view_models/admin_sizes_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

class _StubAuthRepository implements AuthRepository {
  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async =>
      const Failure(UnauthorizedError());

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async =>
      const Failure(UnauthorizedError());

  @override
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) async => const Success(null);

  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async => const Success(null);
}

class _StubConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

class _NoopRouter implements AdminSizesRouter {
  @override
  void goBack() {}
}

class _StubListUseCase implements ListSizesForAdminUseCase {
  @override
  Future<Result<List<Size>, DomainError>> execute(
    ListSizesForAdminInput input,
  ) async => const Success(<Size>[]);
}

class _StubCreateUseCase implements CreateSizeUseCase {
  @override
  Future<Result<Size, DomainError>> execute(CreateSizeInput input) async =>
      const Failure(UnauthorizedError());
}

class _StubUpdateUseCase implements UpdateSizeUseCase {
  @override
  Future<Result<Size, DomainError>> execute(UpdateSizeInput input) async =>
      const Failure(UnauthorizedError());
}

class _StubDeleteUseCase implements DeleteSizeUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

AppContainer _makeContainer() {
  final auth = AuthGateway(repository: _StubAuthRepository());
  final connectivity = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(authGateway: auth, connectivityGateway: connectivity);
}

AdminSizesViewModel _testViewModelBuilder(
  AppContainer container,
  AdminSizesRouter router,
) {
  return AdminSizesViewModel(
    listSizes: _StubListUseCase(),
    createSize: _StubCreateUseCase(),
    updateSize: _StubUpdateUseCase(),
    deleteSize: _StubDeleteUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: router,
  );
}

void main() {
  group('AdminSizesRoutePage', () {
    test('identity is the constant `admin-sizes` (stack diffing)', () {
      final page = AdminSizesRoutePage(router: _NoopRouter());

      expect(page.identity, 'admin-sizes');
    });

    testWidgets(
      'buildScreen returns an AdminSizesScreen with a live ViewModel',
      (tester) async {
        final page = AdminSizesRoutePage(
          router: _NoopRouter(),
          viewModelBuilder: _testViewModelBuilder,
        );
        final container = _makeContainer();

        await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));

        expect(find.byType(AdminSizesScreen), findsOneWidget);
      },
    );

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = AdminSizesRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as AdminSizesScreen;
      final second = page.buildScreen(container) as AdminSizesScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = AdminSizesRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as AdminSizesScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test('viewModelBuilder is invoked with the container and router on the '
        'first buildScreen call', () {
      var calls = 0;
      AppContainer? receivedContainer;
      AdminSizesRouter? receivedRouter;
      final router = _NoopRouter();
      AdminSizesViewModel customBuilder(AppContainer c, AdminSizesRouter r) {
        calls++;
        receivedContainer = c;
        receivedRouter = r;
        return _testViewModelBuilder(c, r);
      }

      final page = AdminSizesRoutePage(
        router: router,
        viewModelBuilder: customBuilder,
      );
      final container = _makeContainer();

      page.buildScreen(container);
      page.buildScreen(container);

      expect(calls, 1);
      expect(receivedContainer, same(container));
      expect(receivedRouter, same(router));
    });
  });
}
