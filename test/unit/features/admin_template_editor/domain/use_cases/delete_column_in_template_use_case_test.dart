import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_column_in_template_use_case.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../auth_helpers.dart';

void main() {
  group('DeleteColumnInTemplateUseCase — admin', () {
    test('forwards id to the repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeColumnRepository()..whenDelete(const Success(null));
      final useCase = DeleteColumnInTemplateUseCase(
        authGateway: gateway,
        columnRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.isSuccess, true);
      expect(repo.calls.single, isA<ColumnDeleteCall>());
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeColumnRepository()
        ..whenDelete(const Failure(NetworkError()));
      final useCase = DeleteColumnInTemplateUseCase(
        authGateway: gateway,
        columnRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('DeleteColumnInTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeColumnRepository();
      final useCase = DeleteColumnInTemplateUseCase(
        authGateway: gateway,
        columnRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeColumnRepository();
      final useCase = DeleteColumnInTemplateUseCase(
        authGateway: gateway,
        columnRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
