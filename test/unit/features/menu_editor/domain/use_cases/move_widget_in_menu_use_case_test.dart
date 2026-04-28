import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/move_widget_in_menu_use_case.dart';

import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

WidgetInstance _w({int id = 1, int columnId = 1, int index = 2}) =>
    WidgetInstance(
      id: id,
      columnId: columnId,
      type: 'dish',
      version: '1',
      index: index,
      props: const <String, dynamic>{},
    );

void main() {
  group('MoveWidgetInMenuUseCase — authenticated', () {
    test('reorders within the same column with adjusted destination index '
        'when target index is greater than the source', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenReorder(const Success(null));
      final useCase = MoveWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(
        MoveWidgetInput(
          widget: _w(),
          sourceColumnId: 1,
          targetColumnId: 1,
          targetIndex: 5,
        ),
      );

      expect(result.isSuccess, isTrue);
      final reorder = repo.calls.single as WidgetReorderCall;
      expect(reorder.widgetId, 1);
      expect(reorder.newIndex, 4);
    });

    test('reorders within the same column with the original target index '
        'when target index is below the source', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenReorder(const Success(null));
      final useCase = MoveWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      await useCase.execute(
        MoveWidgetInput(
          widget: _w(index: 4),
          sourceColumnId: 1,
          targetColumnId: 1,
          targetIndex: 1,
        ),
      );

      final reorder = repo.calls.single as WidgetReorderCall;
      expect(reorder.newIndex, 1);
    });

    test('cross-column move calls moveTo with the target column id', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenMoveTo(const Success(null));
      final useCase = MoveWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      await useCase.execute(
        MoveWidgetInput(
          widget: _w(),
          sourceColumnId: 1,
          targetColumnId: 2,
          targetIndex: 0,
        ),
      );

      final moveTo = repo.calls.single as WidgetMoveToCall;
      expect(moveTo.widgetId, 1);
      expect(moveTo.newColumnId, 2);
      expect(moveTo.index, 0);
    });
  });

  group('MoveWidgetInMenuUseCase — anonymous', () {
    test('returns UnauthorizedError without touching the repository', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = MoveWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(
        MoveWidgetInput(
          widget: _w(),
          sourceColumnId: 1,
          targetColumnId: 2,
          targetIndex: 0,
        ),
      );

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });

  group('MoveWidgetInput', () {
    test('value-equal inputs hash to the same bucket', () {
      final a = MoveWidgetInput(
        widget: _w(),
        sourceColumnId: 1,
        targetColumnId: 1,
        targetIndex: 1,
      );
      final b = MoveWidgetInput(
        widget: _w(),
        sourceColumnId: 1,
        targetColumnId: 1,
        targetIndex: 1,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
