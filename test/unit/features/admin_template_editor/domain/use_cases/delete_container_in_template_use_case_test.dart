import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_container_in_template_use_case.dart';

import '../../../../../fakes/fake_container_repository.dart';
import '../../auth_helpers.dart';

void main() {
  group('DeleteContainerInTemplateUseCase — admin', () {
    test('forwards id to the repository on success', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository()..whenDelete(const Success(null));
      final useCase = DeleteContainerInTemplateUseCase(
        authGateway: gateway,
        containerRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.isSuccess, true);
      expect(repo.calls.single, isA<ContainerDeleteCall>());
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository()
        ..whenDelete(const Failure(ServerError()));
      final useCase = DeleteContainerInTemplateUseCase(
        authGateway: gateway,
        containerRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<ServerError>());
    });
  });

  group('DeleteContainerInTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository();
      final useCase = DeleteContainerInTemplateUseCase(
        authGateway: gateway,
        containerRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository();
      final useCase = DeleteContainerInTemplateUseCase(
        authGateway: gateway,
        containerRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
