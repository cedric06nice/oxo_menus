import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_page_in_template_use_case.dart';

import '../../../../../fakes/fake_page_repository.dart';
import '../../auth_helpers.dart';

void main() {
  group('DeletePageInTemplateUseCase — admin', () {
    test('forwards id to the repository on success', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakePageRepository()..whenDelete(const Success(null));
      final useCase = DeletePageInTemplateUseCase(
        authGateway: gateway,
        pageRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.isSuccess, true);
      expect(repo.deleteCalls.single.id, 7);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakePageRepository()
        ..whenDelete(const Failure(NetworkError()));
      final useCase = DeletePageInTemplateUseCase(
        authGateway: gateway,
        pageRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('DeletePageInTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakePageRepository();
      final useCase = DeletePageInTemplateUseCase(
        authGateway: gateway,
        pageRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakePageRepository();
      final useCase = DeletePageInTemplateUseCase(
        authGateway: gateway,
        pageRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
