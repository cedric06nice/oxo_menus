import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/update_widget_in_menu_use_case.dart';

import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

const _input = UpdateWidgetInput(
  id: 1,
  props: <String, dynamic>{'name': 'Steak'},
);

WidgetInstance _instance() => const WidgetInstance(
  id: 1,
  columnId: 1,
  type: 'dish',
  version: '1',
  index: 0,
  props: <String, dynamic>{'name': 'Steak'},
);

void main() {
  group('UpdateWidgetInMenuUseCase — authenticated', () {
    test('forwards input to the repository', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenUpdate(Success(_instance()));
      final useCase = UpdateWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.valueOrNull, _instance());
      expect((repo.calls.single as WidgetUpdateCall).input, _input);
    });
  });

  group('UpdateWidgetInMenuUseCase — anonymous', () {
    test('returns UnauthorizedError without touching the repository', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = UpdateWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
