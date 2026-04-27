import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_container_in_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';

import '../../../../../fakes/fake_container_repository.dart';
import '../../auth_helpers.dart';

const _container = Container(id: 1, pageId: 10, index: 0);
const _input = CreateContainerInput(
  pageId: 10,
  index: 0,
  direction: 'portrait',
);

void main() {
  group('CreateContainerInTemplateUseCase — admin', () {
    test('forwards input to the repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository()
        ..whenCreate(const Success(_container));
      final useCase = CreateContainerInTemplateUseCase(
        authGateway: gateway,
        containerRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.valueOrNull, _container);
      expect(repo.calls.single, isA<ContainerCreateCall>());
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository()
        ..whenCreate(const Failure(ServerError()));
      final useCase = CreateContainerInTemplateUseCase(
        authGateway: gateway,
        containerRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<ServerError>());
    });
  });

  group('CreateContainerInTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository();
      final useCase = CreateContainerInTemplateUseCase(
        authGateway: gateway,
        containerRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository();
      final useCase = CreateContainerInTemplateUseCase(
        authGateway: gateway,
        containerRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
