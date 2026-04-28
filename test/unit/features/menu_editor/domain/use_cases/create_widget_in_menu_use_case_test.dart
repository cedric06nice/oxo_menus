import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/create_widget_in_menu_use_case.dart';

import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

const _input = CreateWidgetInput(
  columnId: 1,
  type: 'dish',
  version: '1',
  index: 0,
  props: <String, dynamic>{},
);

WidgetInstance _instance() => const WidgetInstance(
  id: 7,
  columnId: 1,
  type: 'dish',
  version: '1',
  index: 0,
  props: <String, dynamic>{},
);

void main() {
  group('CreateWidgetInMenuUseCase — authenticated', () {
    test('forwards input to the repository and returns the widget', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenCreate(Success(_instance()));
      final useCase = CreateWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.valueOrNull, _instance());
      expect((repo.calls.single as WidgetCreateCall).input, _input);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()
        ..whenCreate(const Failure(NetworkError()));
      final useCase = CreateWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('CreateWidgetInMenuUseCase — anonymous', () {
    test('returns UnauthorizedError without touching the repository', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = CreateWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(_input);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
