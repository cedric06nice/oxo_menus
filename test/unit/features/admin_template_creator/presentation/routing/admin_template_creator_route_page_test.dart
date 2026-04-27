import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/create_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_areas_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_sizes_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_route_page.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/screens/admin_template_creator_screen.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/view_models/admin_template_creator_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
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

class _NoopRouter implements AdminTemplateCreatorRouter {
  @override
  void goBack() {}

  @override
  void goToAdminSizes() {}

  @override
  void goToAdminTemplateEditor(int menuId) {}
}

class _StubListSizes implements ListSizesForCreatorUseCase {
  @override
  Future<Result<List<Size>, DomainError>> execute(NoInput input) async =>
      const Success(<Size>[]);
}

class _StubListAreas implements ListAreasForCreatorUseCase {
  @override
  Future<Result<List<Area>, DomainError>> execute(NoInput input) async =>
      const Success(<Area>[]);
}

class _StubCreateTemplate implements CreateTemplateUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(CreateTemplateInput input) async =>
      const Failure(UnauthorizedError());
}

AppContainer _makeContainer() {
  final auth = AuthGateway(repository: _StubAuthRepository());
  final connectivity = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(authGateway: auth, connectivityGateway: connectivity);
}

AdminTemplateCreatorViewModel _testViewModelBuilder(
  AppContainer container,
  AdminTemplateCreatorRouter router,
) {
  return AdminTemplateCreatorViewModel(
    listSizes: _StubListSizes(),
    listAreas: _StubListAreas(),
    createTemplate: _StubCreateTemplate(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: router,
  );
}

void main() {
  group('AdminTemplateCreatorRoutePage', () {
    test(
      'identity is the constant `admin-template-create` (stack diffing)',
      () {
        final page = AdminTemplateCreatorRoutePage(router: _NoopRouter());

        expect(page.identity, 'admin-template-create');
      },
    );

    testWidgets(
      'buildScreen returns an AdminTemplateCreatorScreen with a live ViewModel',
      (tester) async {
        final page = AdminTemplateCreatorRoutePage(
          router: _NoopRouter(),
          viewModelBuilder: _testViewModelBuilder,
        );
        final container = _makeContainer();

        await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));
        await tester.pump();

        expect(find.byType(AdminTemplateCreatorScreen), findsOneWidget);
      },
    );

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = AdminTemplateCreatorRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as AdminTemplateCreatorScreen;
      final second = page.buildScreen(container) as AdminTemplateCreatorScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = AdminTemplateCreatorRoutePage(
        router: _NoopRouter(),
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as AdminTemplateCreatorScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test('viewModelBuilder is invoked with the container and router on the '
        'first buildScreen call', () {
      var calls = 0;
      AppContainer? receivedContainer;
      AdminTemplateCreatorRouter? receivedRouter;
      final router = _NoopRouter();
      AdminTemplateCreatorViewModel customBuilder(
        AppContainer c,
        AdminTemplateCreatorRouter r,
      ) {
        calls++;
        receivedContainer = c;
        receivedRouter = r;
        return _testViewModelBuilder(c, r);
      }

      final page = AdminTemplateCreatorRoutePage(
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
