import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_widget_in_template_use_case.dart';

import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

void main() {
  group('DeleteWidgetInTemplateUseCase — admin', () {
    test('forwards id to the repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenDelete(const Success(null));
      final useCase = DeleteWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.isSuccess, true);
      expect(repo.calls.single, isA<WidgetDeleteCall>());
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()
        ..whenDelete(const Failure(NetworkError()));
      final useCase = DeleteWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('DeleteWidgetInTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = DeleteWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = DeleteWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
