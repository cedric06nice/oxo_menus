import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_route_page.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/screens/admin_templates_screen.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
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

class _NoopRouter implements AdminTemplatesRouter {
  @override
  void goToAdminTemplateCreate() {}

  @override
  void goToAdminTemplateEditor(int menuId) {}

  @override
  void goBack() {}
}

class _StubListUseCase implements ListTemplatesForAdminUseCase {
  @override
  Future<Result<List<Menu>, DomainError>> execute(
    ListTemplatesForAdminInput input,
  ) async => const Success(<Menu>[]);
}

class _StubDeleteUseCase implements DeleteTemplateUseCase {
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

AdminTemplatesViewModel _testViewModelBuilder(
  AppContainer container,
  AdminTemplatesRouter router,
) {
  return AdminTemplatesViewModel(
    listTemplates: _StubListUseCase(),
    deleteTemplate: _StubDeleteUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: router,
  );
}

void main() {
  group('AdminTemplatesRoutePage', () {
    test('identity is the constant `admin-templates` (stack diffing)', () {
      final page = AdminTemplatesRoutePage(router: _NoopRouter());

      expect(page.identity, 'admin-templates');
    });

    testWidgets(
      'buildScreen returns an AdminTemplatesScreen with a live ViewModel',
      (tester) async {
        final page = AdminTemplatesRoutePage(
          router: _NoopRouter(),
          viewModelBuilder: _testViewModelBuilder,
        );
        final container = _makeContainer();

        await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));

        expect(find.byType(AdminTemplatesScreen), findsOneWidget);
      },
    );

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = AdminTemplatesRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as AdminTemplatesScreen;
      final second = page.buildScreen(container) as AdminTemplatesScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = AdminTemplatesRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as AdminTemplatesScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test('viewModelBuilder is invoked with the container and router on the '
        'first buildScreen call', () {
      var calls = 0;
      AppContainer? receivedContainer;
      AdminTemplatesRouter? receivedRouter;
      final router = _NoopRouter();
      AdminTemplatesViewModel customBuilder(
        AppContainer c,
        AdminTemplatesRouter r,
      ) {
        calls++;
        receivedContainer = c;
        receivedRouter = r;
        return _testViewModelBuilder(c, r);
      }

      final page = AdminTemplatesRoutePage(
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
