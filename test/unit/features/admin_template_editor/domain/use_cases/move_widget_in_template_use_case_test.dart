import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/move_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';

import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

const _widget = WidgetInstance(
  id: 1,
  columnId: 10,
  type: 'text',
  version: '1',
  index: 2,
  props: {},
);

void main() {
  group('MoveWidgetInTemplateUseCase — admin same-column', () {
    test('reorders with adjusted index when target above current', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenReorder(const Success(null));
      final useCase = MoveWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(
        const MoveWidgetInput(
          widget: _widget,
          sourceColumnId: 10,
          targetColumnId: 10,
          targetIndex: 0,
        ),
      );

      expect(result.isSuccess, true);
      final reorder = repo.calls.single as WidgetReorderCall;
      expect(reorder.newIndex, 0);
    });

    test('reorders with index-1 when target below current', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenReorder(const Success(null));
      final useCase = MoveWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(
        const MoveWidgetInput(
          widget: _widget,
          sourceColumnId: 10,
          targetColumnId: 10,
          targetIndex: 5,
        ),
      );

      expect(result.isSuccess, true);
      final reorder = repo.calls.single as WidgetReorderCall;
      expect(reorder.newIndex, 4);
    });
  });

  group('MoveWidgetInTemplateUseCase — admin cross-column', () {
    test('uses moveTo when source and target columns differ', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenMoveTo(const Success(null));
      final useCase = MoveWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(
        const MoveWidgetInput(
          widget: _widget,
          sourceColumnId: 10,
          targetColumnId: 20,
          targetIndex: 1,
        ),
      );

      expect(result.isSuccess, true);
      final move = repo.calls.single as WidgetMoveToCall;
      expect(move.newColumnId, 20);
      expect(move.index, 1);
    });
  });

  group('MoveWidgetInTemplateUseCase — non-admin', () {
    test('regular user is denied without invoking the repository', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = MoveWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(
        const MoveWidgetInput(
          widget: _widget,
          sourceColumnId: 10,
          targetColumnId: 10,
          targetIndex: 0,
        ),
      );

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = MoveWidgetInTemplateUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(
        const MoveWidgetInput(
          widget: _widget,
          sourceColumnId: 10,
          targetColumnId: 10,
          targetIndex: 0,
        ),
      );

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
