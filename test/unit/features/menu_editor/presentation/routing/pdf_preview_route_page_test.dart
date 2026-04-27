import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_route_page.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/pdf_preview_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/pdf_preview_view_model.dart';
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

class _NoopRouter implements PdfPreviewRouter {
  @override
  void goBack() {}
}

class _StubGeneratePdf implements GenerateMenuPdfUseCase {
  @override
  Future<Result<GenerateMenuPdfOutput, DomainError>> execute(
    GenerateMenuPdfInput input,
  ) async {
    return Success(
      GenerateMenuPdfOutput(
        bytes: Uint8List.fromList(const [0]),
        filename: 'm.pdf',
      ),
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppContainer _makeContainer() {
  final auth = AuthGateway(repository: _StubAuthRepository());
  final connectivity = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(authGateway: auth, connectivityGateway: connectivity);
}

PdfPreviewViewModel _testViewModelBuilder(
  AppContainer container,
  PdfPreviewRouter router,
  int menuId,
) {
  return PdfPreviewViewModel(
    menuId: menuId,
    generatePdf: _StubGeneratePdf(),
    router: router,
  );
}

void main() {
  group('PdfPreviewRoutePage', () {
    test('identity is namespaced with the menuId so distinct menus are '
        'distinct stack entries', () {
      final a = PdfPreviewRoutePage(router: _NoopRouter(), menuId: 7);
      final b = PdfPreviewRoutePage(router: _NoopRouter(), menuId: 7);
      final c = PdfPreviewRoutePage(router: _NoopRouter(), menuId: 8);

      expect(a.identity, b.identity);
      expect(a.identity, isNot(c.identity));
    });

    testWidgets(
      'buildScreen returns a PdfPreviewScreen with a live ViewModel',
      (tester) async {
        final page = PdfPreviewRoutePage(
          router: _NoopRouter(),
          menuId: 7,
          viewModelBuilder: _testViewModelBuilder,
        );
        final container = _makeContainer();

        await tester.pumpWidget(MaterialApp(home: page.buildScreen(container)));
        await tester.pump();

        expect(find.byType(PdfPreviewScreen), findsOneWidget);
      },
    );

    test('buildScreen is idempotent — same ViewModel survives rebuilds', () {
      final page = PdfPreviewRoutePage(
        router: _NoopRouter(),
        menuId: 7,
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as PdfPreviewScreen;
      final second = page.buildScreen(container) as PdfPreviewScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = PdfPreviewRoutePage(
        router: _NoopRouter(),
        menuId: 7,
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as PdfPreviewScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test('viewModelBuilder is invoked with container, router, menuId on the '
        'first buildScreen call', () {
      var calls = 0;
      AppContainer? receivedContainer;
      PdfPreviewRouter? receivedRouter;
      int? receivedMenuId;
      final router = _NoopRouter();
      PdfPreviewViewModel customBuilder(
        AppContainer c,
        PdfPreviewRouter r,
        int menuId,
      ) {
        calls++;
        receivedContainer = c;
        receivedRouter = r;
        receivedMenuId = menuId;
        return _testViewModelBuilder(c, r, menuId);
      }

      final page = PdfPreviewRoutePage(
        router: router,
        menuId: 11,
        viewModelBuilder: customBuilder,
      );
      final container = _makeContainer();

      page.buildScreen(container);
      page.buildScreen(container);

      expect(calls, 1);
      expect(receivedContainer, same(container));
      expect(receivedRouter, same(router));
      expect(receivedMenuId, 11);
    });
  });
}
