import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

const _widget = WidgetInstance(
  id: 1,
  columnId: 10,
  type: 'text',
  version: '1',
  index: 0,
  props: {},
);

const _input = UpdateWidgetInput(id: 1, props: {'value': 'new'});

void main() {
  group('UpdateWidgetInTemplateUseCase — admin', () {
    test('forwards input to the repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenUpdate(const Success(_widget));
      final useCase = UpdateWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.valueOrNull, _widget);
      expect(repo.calls.single, isA<WidgetUpdateCall>());
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()
        ..whenUpdate(const Failure(ServerError()));
      final useCase = UpdateWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<ServerError>());
    });
  });

  group('UpdateWidgetInTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = UpdateWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = UpdateWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
