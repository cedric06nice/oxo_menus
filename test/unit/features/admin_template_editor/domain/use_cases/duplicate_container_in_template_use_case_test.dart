import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/duplicate_container_in_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/container.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

void main() {
  group('DuplicateContainerInTemplateUseCase — admin', () {
    test(
      'invokes inner use case and returns the duplicated container',
      () async {
        final gateway = await gatewayFor(adminUser);
        addTearDown(gateway.dispose);
        final containerRepo = FakeContainerRepository()
          ..whenGetById(const Success(Container(id: 1, pageId: 10, index: 0)))
          ..whenGetAllForPage(
            const Success([Container(id: 1, pageId: 10, index: 0)]),
          )
          ..whenGetAllForContainer(const Success([]))
          ..whenCreate(const Success(Container(id: 99, pageId: 10, index: 1)))
          ..whenUpdate(const Success(Container(id: 1, pageId: 10, index: 0)));
        final columnRepo = FakeColumnRepository()
          ..whenGetAllForContainer(const Success([]));
        final widgetRepo = FakeWidgetRepository();
        final inner = DuplicateContainerUseCase(
          containerRepository: containerRepo,
          columnRepository: columnRepo,
          widgetRepository: widgetRepo,
        );
        final useCase = DuplicateContainerInTemplateUseCase(
          authGateway: gateway,
          duplicateContainerUseCase: inner,
        );

        final result = await useCase.execute(1);

        expect(result.isSuccess, true);
        expect(result.valueOrNull?.id, 99);
      },
    );
  });

  group('DuplicateContainerInTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final containerRepo = FakeContainerRepository();
      final columnRepo = FakeColumnRepository();
      final widgetRepo = FakeWidgetRepository();
      final inner = DuplicateContainerUseCase(
        containerRepository: containerRepo,
        columnRepository: columnRepo,
        widgetRepository: widgetRepo,
      );
      final useCase = DuplicateContainerInTemplateUseCase(
        authGateway: gateway,
        duplicateContainerUseCase: inner,
      );

      final result = await useCase.execute(1);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(containerRepo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final containerRepo = FakeContainerRepository();
      final columnRepo = FakeColumnRepository();
      final widgetRepo = FakeWidgetRepository();
      final inner = DuplicateContainerUseCase(
        containerRepository: containerRepo,
        columnRepository: columnRepo,
        widgetRepository: widgetRepo,
      );
      final useCase = DuplicateContainerInTemplateUseCase(
        authGateway: gateway,
        duplicateContainerUseCase: inner,
      );

      final result = await useCase.execute(1);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(containerRepo.calls, isEmpty);
    });
  });
}
