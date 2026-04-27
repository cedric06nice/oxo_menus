import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/reorder_container_in_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';

import '../../../../../fakes/fake_container_repository.dart';
import '../../auth_helpers.dart';

const _input = ReorderContainerInput(
  containerId: 5,
  direction: ReorderDirection.up,
);

void main() {
  group('ReorderContainerInTemplateUseCase — admin', () {
    test('forwards to inner use case which reorders via repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository()
        ..whenGetById(const Success(Container(id: 5, pageId: 10, index: 1)))
        ..whenGetAllForPage(
          const Success([
            Container(id: 4, pageId: 10, index: 0),
            Container(id: 5, pageId: 10, index: 1),
          ]),
        )
        ..whenReorder(const Success(null));
      final inner = ReorderContainerUseCase(containerRepository: repo);
      final useCase = ReorderContainerInTemplateUseCase(
        authGateway: gateway,
        reorderContainerUseCase: inner,
      );

      final result = await useCase.execute(_input);

      expect(result.isSuccess, true);
      // Inner use case calls reorder twice (swap)
      expect(repo.calls.whereType<ContainerReorderCall>(), hasLength(2));
    });
  });

  group('ReorderContainerInTemplateUseCase — non-admin', () {
    test('regular user is denied without invoking inner use case', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository();
      final inner = ReorderContainerUseCase(containerRepository: repo);
      final useCase = ReorderContainerInTemplateUseCase(
        authGateway: gateway,
        reorderContainerUseCase: inner,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeContainerRepository();
      final inner = ReorderContainerUseCase(containerRepository: repo);
      final useCase = ReorderContainerInTemplateUseCase(
        authGateway: gateway,
        reorderContainerUseCase: inner,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
