import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_column_in_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../auth_helpers.dart';

const _column = Column(id: 1, containerId: 10, index: 0);
const _input = UpdateColumnInput(id: 1, isDroppable: true);

void main() {
  group('UpdateColumnInTemplateUseCase — admin', () {
    test('forwards input to the repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeColumnRepository()..whenUpdate(const Success(_column));
      final useCase = UpdateColumnInTemplateUseCase(
        authGateway: gateway,
        columnRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.valueOrNull, _column);
      expect(repo.calls.single, isA<ColumnUpdateCall>());
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeColumnRepository()
        ..whenUpdate(const Failure(ServerError()));
      final useCase = UpdateColumnInTemplateUseCase(
        authGateway: gateway,
        columnRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<ServerError>());
    });
  });

  group('UpdateColumnInTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeColumnRepository();
      final useCase = UpdateColumnInTemplateUseCase(
        authGateway: gateway,
        columnRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeColumnRepository();
      final useCase = UpdateColumnInTemplateUseCase(
        authGateway: gateway,
        columnRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
