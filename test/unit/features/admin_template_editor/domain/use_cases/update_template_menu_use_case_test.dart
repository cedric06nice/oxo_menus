import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_template_menu_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

import '../../../../../fakes/fake_menu_repository.dart';
import '../../auth_helpers.dart';

const _menu = Menu(id: 1, name: 'Template', version: '1', status: Status.draft);

const _input = UpdateMenuInput(id: 1, status: Status.published);

void main() {
  group('UpdateTemplateMenuUseCase — admin', () {
    test('forwards input to the repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()..whenUpdate(const Success(_menu));
      final useCase = UpdateTemplateMenuUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.valueOrNull, _menu);
      expect(repo.calls.single, isA<MenuUpdateCall>());
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()
        ..whenUpdate(const Failure(ServerError()));
      final useCase = UpdateTemplateMenuUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<ServerError>());
    });
  });

  group('UpdateTemplateMenuUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository();
      final useCase = UpdateTemplateMenuUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository();
      final useCase = UpdateTemplateMenuUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
