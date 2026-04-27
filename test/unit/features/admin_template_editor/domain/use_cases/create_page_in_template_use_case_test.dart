import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_page_in_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';

import '../../../../../fakes/fake_page_repository.dart';
import '../../auth_helpers.dart';

const _content = entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0);
const _input = CreatePageInput(menuId: 1, name: 'Page 1', index: 0);

void main() {
  group('CreatePageInTemplateUseCase — admin', () {
    test('forwards input to the repository and returns the page', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakePageRepository()..whenCreate(const Success(_content));
      final useCase = CreatePageInTemplateUseCase(
        authGateway: gateway,
        pageRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.valueOrNull, _content);
      expect(repo.createCalls.single.input, _input);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakePageRepository()
        ..whenCreate(const Failure(NetworkError()));
      final useCase = CreatePageInTemplateUseCase(
        authGateway: gateway,
        pageRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('CreatePageInTemplateUseCase — non-admin', () {
    test('regular user is denied without touching the repository', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakePageRepository();
      final useCase = CreatePageInTemplateUseCase(
        authGateway: gateway,
        pageRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakePageRepository();
      final useCase = CreatePageInTemplateUseCase(
        authGateway: gateway,
        pageRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
